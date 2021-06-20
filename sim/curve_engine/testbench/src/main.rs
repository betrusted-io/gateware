#![no_std]
#![no_main]

use sim_bios::sim_test;
extern crate volatile;
use volatile::Volatile;

pub fn report(p: &pac::Peripherals, data: u32) {
    unsafe{
        p.SIMSTATUS.report.write(|w| w.bits( data ));
    }
}

#[cfg(not(test))]
#[sim_test]
fn run(p: &pac::Peripherals) {
    let microcode_ptr: *mut u32 = 0xe002_0000 as *mut u32;
    let microcode = microcode_ptr as *mut Volatile<u32>;

    let rf_ptr: *mut u32 = 0xe003_0000 as *mut u32;
    let rf = rf_ptr as *mut Volatile<u32>;

    let vectors_ptr: *mut u32 = 0x3000_0000 as *mut u32;
    let vectors = vectors_ptr as *mut Volatile<u32>;

    let mut pass = true;
    let mut phase: u32 = 0x8000_0000;

    report(&p, phase);  phase += 1;

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
                loop {
                    let status = p.ENGINE.status.read().bits();
                    report(&p, status);
                    if (status & 1) == 0 {
                        break;
                    }
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
