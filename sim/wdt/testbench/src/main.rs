#![no_std]
#![no_main]

extern crate volatile;
use volatile::Volatile;

// allocate a global, unsafe static string. You can use this to force writes to RAM.
#[used] // This is necessary to keep DBGSTR from being optimized out
static mut DBGSTR: [u32; 8] = [0, 0, 0, 0, 0, 0, 0, 0];

pub fn report(p: &pac::Peripherals, data: u32) {
    unsafe{
        p.SIMSTATUS.report.write(|w| w.bits( data ));
    }
}

use sim_bios::*;
#[no_mangle]
pub extern "Rust" fn run(p: &pac::Peripherals) {
    let ram_ptr: *mut u32 = 0x0100_0000 as *mut u32;
    let ram = ram_ptr as *mut Volatile<u32>;

    report(&p, 0x1000_0000);
    p.WDT.period.write(|w| unsafe {w.bits(1000)});

    report(&p, 0x2000_0000);
    p.WDT.watchdog.write(|w| w.enable().set_bit());

    let mut wait = 0x3000_0000;
    for i in 0..1_000 {
        p.WDT.watchdog.write(|w| w.reset_wdt().set_bit());
        // p.WDT.watchdog.write(|w| unsafe{w.reset_code().bits(0x600d)});
        report(&p, wait + i); // should WDT reset sometime in here
        report(&p, wait + i + 0x100_000);
        report(&p, wait + i + 0x200_000);
        report(&p, wait + i + 0x300_000);
        //p.WDT.watchdog.write(|w| unsafe{w.reset_code().bits(0xc0de)});
    }

    // set success to indicate to the CI framework that the test has passed
    p.SIMSTATUS.simstatus.modify(|_r, w| w.success().bit(true));
}
