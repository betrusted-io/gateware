#![no_std]
#![no_main]

use sim_bios::sim_test;

// allocate a global, unsafe static string. You can use this to force writes to RAM.
#[used] // This is necessary to keep DBGSTR from being optimized out
static mut DBGSTR: [u32; 8] = [0, 0, 0, 0, 0, 0, 0, 0];

#[sim_test]
fn run(p: &pac::Peripherals) {
    // example of using the DBGSTR
    unsafe {
        DBGSTR[0] = 0xface;
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
    
    // you can use this to end the simulation early, or you can also toggle 'failure()' instead of success as needed
    p.SIMSTATUS.simstatus.write(|w| w.success().bit(true));
    
}
