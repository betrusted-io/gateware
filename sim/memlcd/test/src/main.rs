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

    p.SIMSTATUS.simstatus.write(|w| w.success().bit(true));
    
}
