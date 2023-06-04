#![no_std]
#![no_main]

extern crate volatile;
use volatile::Volatile;

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

    let rom_ptr: *mut u32 = 0x8000_0000 as *mut u32;
    let rom = rom_ptr as *mut Volatile<u32>;

    // caching test
    unsafe {
        for i in 0..8 {
            report(&p, rom_ptr.add(i).read());
        }
    }

    // timing test
    unsafe {
        for i in 0..32 {
            report(&p, rom_ptr.add(i).read());
        }
    }

    // set success to indicate to the CI framework that the test has passed
    p.SIMSTATUS.simstatus.modify(|_r, w| w.success().bit(true));
}
