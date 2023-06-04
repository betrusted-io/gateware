#![no_std]
#![no_main]

fn row_read(p: &pac::Peripherals, row: u32) -> u32 {
    unsafe {
        match row {
            0 => p.KEYBOARD.row0dat.read().bits(),
            1 => p.KEYBOARD.row1dat.read().bits(),
            2 => p.KEYBOARD.row2dat.read().bits(),
            3 => p.KEYBOARD.row3dat.read().bits(),
            4 => p.KEYBOARD.row4dat.read().bits(),
            5 => p.KEYBOARD.row5dat.read().bits(),
            6 => p.KEYBOARD.row6dat.read().bits(),
            7 => p.KEYBOARD.row7dat.read().bits(),
            _ => p.KEYBOARD.row8dat.read().bits(),
        }
    }
}

fn do_key_event(p: &pac::Peripherals) {
    while p.KEYBOARD.ev_pending.read().bits() == 0 { }
    for row in 0..9 {
        let val = row_read(&p, row);
        if val != 0 {
            unsafe {p.SIMSTATUS.report.write(|w| w.bits(val));}
        }
    }
    unsafe{ p.KEYBOARD.ev_pending.write(|w| w.bits(1)); }
}

use sim_bios::*;
#[no_mangle]
pub extern "Rust" fn run(p: &pac::Peripherals) {
    let mut state = 0x8000_0000;
    // first key-down
    let mut count = 0;
    // ignore the first keydown/keyup event
    while p.KEYBOARD.ev_pending.read().bits() == 0 {
        count += 1;
    }
    let mut second_count = 0;
    while second_count < count * 5 {
        second_count += 1;
        unsafe {
            p.SIMSTATUS.report.write(|w| w.bits(second_count));
        }
    }
    do_key_event(&p);

    unsafe {p.SIMSTATUS.report.write(|w| w.bits(state));}
    state += 1;


    do_key_event(&p);
    unsafe {p.SIMSTATUS.report.write(|w| w.bits(state));}
    state += 1;
    do_key_event(&p);
    unsafe {p.SIMSTATUS.report.write(|w| w.bits(state));}
    state += 1;
    do_key_event(&p);
    unsafe {p.SIMSTATUS.report.write(|w| w.bits(state));}
    state += 1;
    do_key_event(&p);
    unsafe {p.SIMSTATUS.report.write(|w| w.bits(state));}
    state += 1;

    // setting this indicates that the simulation was a success
    p.SIMSTATUS.simstatus.modify(|_r, w| w.success().bit(true));
}
