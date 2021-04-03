#![no_std]
#![no_main]

use sim_bios::sim_test;

#[sim_test]
fn run(p: &pac::Peripherals) {
    // first key-down
    while p.KEYBOARD.ev_pending.read().bits() == 0 { }

    unsafe{ p.KEYBOARD.ev_pending.write(|w| w.bits(1)); }
    
    // copy the read out keycode
    let key: u32 = p.KEYBOARD.row3dat.read().bits();

    unsafe {
        p.SIMSTATUS.report.write(|w| w.bits(key));
    }

    // key-up
    while p.KEYBOARD.ev_pending.read().bits() == 0 { }

    unsafe{ p.KEYBOARD.ev_pending.write(|w| w.bits(1)); }

    // copy the read out keycode
    let key: u32 = p.KEYBOARD.row3dat.read().bits();

    unsafe {
        p.SIMSTATUS.report.write(|w| w.bits(key));
    }

    // third keyhit - keydown
    while p.KEYBOARD.ev_pending.read().bits() == 0 { }

    unsafe{ p.KEYBOARD.ev_pending.write(|w| w.bits(1)); }

    // copy the read out keycode - note we've changed rows
    let key: u32 = p.KEYBOARD.row2dat.read().bits();

    unsafe {
        p.SIMSTATUS.report.write(|w| w.bits(key));
    }

    // setting this indicates that the simulation was a success
    p.SIMSTATUS.simstatus.modify(|_r, w| w.success().bit(true));
}
