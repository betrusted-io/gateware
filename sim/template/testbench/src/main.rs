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

    // example of using the DBGSTR to stash a variable from a raw pointer
    unsafe {
        DBGSTR[0] = (*(ram.add(4))).read();
    };

    // example of toggling a bit
    for _ in 0..4 {
        p.DEMO.demo.write(|w| w.pin().bit(true));
        p.DEMO.demo.write(|w| w.pin().bit(false));
    }
    // example of changing a bus item
    unsafe{
        p.DEMO.demo.write(|w| w.bus().bits(0xA));
        p.DEMO.demo.write(|w| w.bus().bits(0x5));
    }

    // example of updating the "report" bits monitored by the CI framework
    unsafe {
        p.SIMSTATUS.report.write(|w| w.bits(0x00C0FFEE));
        p.SIMSTATUS.report.write(|w| w.bits(0xADDCACA0));
        p.SIMSTATUS.report.write(|w| w.bits(0x55555555));
        report(&p, 0xFEEDC0DE);
    }

    // set success to indicate to the CI framework that the test has passed
    p.SIMSTATUS.simstatus.modify(|_r, w| w.success().bit(true));
}
