#![no_std]
#![no_main]

use sim_bios::sim_test;

#[sim_test]
fn run(p: &pac::Peripherals) {
    while p.KEYBOARD.ev_pending.read().bits() == 0 { }

    unsafe{ p.KEYBOARD.ev_pending.write(|w| w.bits(1)); }
    
    // copy the read out keycode
    let key: u32 = p.KEYBOARD.row3dat.read().bits();

    unsafe {
        p.SIMSTATUS.report.write(|w| w.bits(key));
    }

    // setting this indicates that the simulation was a success
    p.SIMSTATUS.simstatus.modify(|_r, w| w.success().bit(true));
}
