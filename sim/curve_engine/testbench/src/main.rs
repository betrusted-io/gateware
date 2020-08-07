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

#[sim_test]
fn run(p: &pac::Peripherals) {
    let microcode_ptr: *mut u32 = 0xe002_0000 as *mut u32;
    let microcode = microcode_ptr as *mut Volatile<u32>;

    let rf_ptr: *mut u32 = 0xe003_0000 as *mut u32;
    let rf = rf_ptr as *mut Volatile<u32>;

    let vectors_ptr: *mut u32 = 0x3000_0000 as *mut u32;
    let vectors = vectors_ptr as *mut Volatile<u32>;

    let mut pass = true;
    let mut phase: u32 = 0x1;

    ///////////////  CONFIRM THAT VECTOR ROM IS ACCESSIBLE, AND IN CORRECT BYTE ORDER
    for i in 0..96/4 {
        unsafe {
            report(&p, (*(vectors.add(i))).read());
        }
    }

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

    ////////////////////////// TEST EXECUTION UNITS
    // first we need some simple assembly programs

    report(&p, phase);

    if pass {
        report(&p, 0xC0DE_600D);
    } else {
        report(&p, 0xC0DE_DEAD);
    }

    // set success to indicate to the CI framework that the test has passed
    p.SIMSTATUS.simstatus.modify(|_r, w| w.success().bit(true));
}
