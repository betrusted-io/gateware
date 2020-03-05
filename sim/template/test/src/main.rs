#![no_std]
#![no_main]

use sim_bios::sim_test;

// allocate a global, unsafe static string for debug output
#[used] // This is necessary to keep DBGSTR from being optimized out
static mut DBGSTR: [u32; 8] = [0, 0, 0, 0, 0, 0, 0, 0];

#[sim_test]
fn run(p: &pac::Peripherals) {
    unsafe {
        DBGSTR[0] = 0xface;
    };

    for _ in 0..4 {
        p.DEMO.demo.write(|w| w.pin().bit(true));
        p.DEMO.demo.write(|w| w.pin().bit(false));
    }
    unsafe{
        p.DEMO.demo.write(|w| w.bus().bits(0xA));
        p.DEMO.demo.write(|w| w.bus().bits(0x5));
    }
    
    p.SIMSTATUS.simstatus.write(|w| w.success().bit(true));
    
}
