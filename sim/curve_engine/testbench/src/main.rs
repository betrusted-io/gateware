#![no_std]
#![no_main]

extern crate volatile;
use volatile::Volatile;

pub fn report(p: &pac::Peripherals, data: u32) {
    unsafe{
        p.SIMSTATUS.report.write(|w| w.bits( data ));
    }
}

fn run_x25519() -> (bool, [u8; 32]) {
    // vector 111
    //"public" : "e96d2780e5469a74620ab5aa2f62151d140c473320dbe1b028f1a48f8e76f95f",
    //"private" : "60a3a4f130b98a5be4b1cedb7cb85584a3520e142d474dc9ccb909a073a9767f",
    //"shared" : "e5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7f",
    // converted using python3 one-liner in REPL: list(bytes.fromhex("hexstringhere"))
    let public_u8: [u8; 32] = [233, 109, 39, 128, 229, 70, 154, 116, 98, 10, 181, 170, 47, 98, 21, 29, 20, 12, 71, 51, 32, 219, 225, 176, 40, 241, 164, 143, 142, 118, 249, 95];
    let private_u8: [u8; 32] = [96, 163, 164, 241, 48, 185, 138, 91, 228, 177, 206, 219, 124, 184, 85, 132, 163, 82, 14, 20, 45, 71, 77, 201, 204, 185, 9, 160, 115, 169, 118, 127];
    let secret_u8: [u8; 32] = [229, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 127];

    use x25519_dalek::{PublicKey, StaticSecret};
    let private = StaticSecret::from(private_u8);
    let public = PublicKey::from(public_u8);
    let shared = private.diffie_hellman(&public).to_bytes();
    if shared != secret_u8 {
        (false, shared)
    } else {
        (true, shared)
    }
}

#[cfg(not(test))]
use sim_bios::*;
#[no_mangle]
pub extern "Rust" fn run(p: &pac::Peripherals) {
    let microcode_ptr: *mut u32 = 0xe002_0000 as *mut u32;
    let microcode = microcode_ptr as *mut Volatile<u32>;

    let rf_ptr: *mut u32 = 0xe003_0000 as *mut u32;
    let rf = rf_ptr as *mut Volatile<u32>;

    let vectors_ptr: *mut u32 = 0x3000_0000 as *mut u32;
    let vectors = vectors_ptr as *mut Volatile<u32>;

    let mut pass = true;
    let mut phase: u32 = 0x8000_0000;

    report(&p, phase);  phase += 1;

    //// run a single point diffie hellman test - created to debug https://github.com/betrusted-io/xous-core/issues/76
    if false {
        let (result, vector) = run_x25519();
        for &b in vector.iter() {
            report(&p, b as u32);
        }
        if result {
            report(&p, 0x1111_1111);
        } else {
            report(&p, 0xdddd_dddd);
        }
        p.SIMSTATUS.simstatus.modify(|_r, w| w.success().bit(pass));
        return;
    }

    ///////////////  APPLY AND RUN ARITHMETIC TEST VECTORS
    let mut test_offset: usize = 0x0;
    let mut magic_number: u32;
    loop {
        unsafe{ magic_number = (*(vectors.add(test_offset))).read(); }
        report(&p, magic_number);
        if magic_number != 0x5645_4354 {
            break;
        }
        test_offset += 1;
        unsafe {
            let load_addr = ((*(vectors.add(test_offset))).read() >> 16) & 0xFFFF;
            let code_len = (*(vectors.add(test_offset))).read() & 0xFFFF;
            test_offset += 1;
            let num_args = ((*(vectors.add(test_offset))).read() >> 27) & 0x1F;
            let window = ((*(vectors.add(test_offset))).read() >> 23) & 0xF;
            let num_vectors = ((*(vectors.add(test_offset))).read() >> 0) & 0x3F_FFFF;
            test_offset += 1;
            for i in 0..code_len as usize {
                (*(microcode.add(i))).write( (*(vectors.add(test_offset))).read() );
                test_offset += 1;
            }

            test_offset = test_offset + (8 - (test_offset % 8)); // skip over padding

            report(&p, phase);  phase += 1;

            // copy in the arguments
            for _vector in 0..num_vectors {
                for argcnt in 0..num_args {
                    for word in 0..8 {
                       (*( rf.add( (window * 32 * 8 + argcnt * 8 + word) as usize )) ).write( (*(vectors.add(test_offset))).read() );
                       test_offset += 1;
                    }
                }

                // setup the engine to run
                p.ENGINE.window.write(|w| w.bits(window));
                p.ENGINE.mpstart.write(|w| w.bits(load_addr));
                p.ENGINE.mplen.write(|w| w.bits(code_len));
                // start the run
                p.ENGINE.control.write(|w| w.go().set_bit());

                // test pause for suspend/resume
                let mut pause_cnt = 0;
                loop {
                    if pause_cnt != 50 {
                        let status = p.ENGINE.status.read().bits();
                        report(&p, status);
                        if (status & 1) == 0 {
                            break;
                        }
                    } else {
                        // on the 50th cycle, do a quick pause/resume test
                        p.ENGINE.power.write(|w| w.pause_req().set_bit());
                        while p.ENGINE.status.read().pause_gnt().bit_is_clear() {
                        }
                        // read from microcode & rf
                        report(&p, (*(rf.add(0x4))).read());
                        report(&p, (*(rf.add(0x0))).read());
                        report(&p, (*(rf.add(0x8))).read());
                        report(&p, (*(microcode.add(0x4))).read());
                        report(&p, (*(microcode.add(0x0))).read());
                        report(&p, (*(microcode.add(0x8))).read());
                        // now resume
                        p.ENGINE.power.write(|w| w.pause_req().clear_bit());
                    }
                    pause_cnt += 1;
                }

                // check result
                let mut vect_pass = true;
                for word in 0..8 {
                    let expect = (*(vectors.add(test_offset))).read();
                    test_offset += 1;
                    let actual = (*( rf.add( (window * 32 * 8 + 31 * 8 + word) as usize ))).read();
                    if expect != actual {
                        vect_pass = false;
                    }
                }
                if vect_pass {
                    report(&p, 0xC0DE_600D);
                } else {
                    report(&p, 0xDEAD_2551);
                    pass = false;
                }
                report(&p, phase);  phase += 1;
            }
        }
    }
    /*  // for historical reference
    for i in 0..96/4 {
        unsafe {
            report(&p, (*(vectors.add(i))).read());
        }
    }
    */
    phase += 0x1000_0000;

    ///////////////  TEST ACCESS TO REGISTERFILE AND MICROCODE SPACE

    // check microcode space
    report(&p, phase);  phase += 1;
    for i in 0..0x400 {
        unsafe {
            (*(microcode.add(i))).write(i as u32);
        }
    }

    report(&p, phase);  phase += 1;
    for i in 0..0x400 {
        let rbk: u32;
        unsafe {
            rbk = (*(microcode.add(i))).read();
        }
        if rbk != i as u32 {
            report(&p, rbk);
            pass = false;
        }
    }

    // check register file space
    report(&p, phase);  phase += 1;
    for i in 0..0x1000 {
        unsafe {
            (*(rf.add(i))).write(i as u32 + 0xA000_0000);
        }
    }

    report(&p, phase);  phase += 1;
    for i in 0..0x1000 {
        let rbk: u32;
        unsafe {
            rbk = (*(rf.add(i))).read();
        }
        if rbk != i as u32 + 0xA000_0000 {
            report(&p, rbk);
            pass = false;
        }
    }

    // check that unaddressed space is escaped
    report(&p, phase);  phase += 1;
    unsafe{
        (*(microcode.add(0x1000 / 4))).write(0x1234_5678);
        (*(microcode.add(0x1_0000 / 4 - 1))).write(0x8765_4321);
        (*(rf.add(0x4000 / 4))).write(0x3141_5926);

        if (*(microcode.add(0x1000 / 4))).read() != 0xC0DE_BADD {  // check that we get the catch-all return value
            pass = false;
        }
        if (*(microcode.add(0x1_0000 / 4 - 1))).read() != 0xC0DE_BADD {  // check that we get the catch-all return value
            pass = false;
        }
        if (*(rf.add(0x4000 / 4))).read() != 0xC0DE_BADD {
            pass = false;
        }
    }

    report(&p, phase);

    if pass {
        report(&p, 0xC0DE_600D);
    } else {
        report(&p, 0xC0DE_DEAD);
    }

    // set success to indicate to the CI framework that the test has passed
    p.SIMSTATUS.simstatus.modify(|_r, w| w.success().bit(pass));
}
