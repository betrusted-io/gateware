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

    for i in 0..255 {
        unsafe{p.KEYROM.address.write(|w| w.bits(i));}
        report(&p, p.KEYROM.data.read().bits());
    }

    for i in 16..32 {
        unsafe{p.KEYROM.lockaddr.write(|w| w.bits(i));}
    }

    for i in 0..48 {
        unsafe{p.KEYROM.address.write(|w| w.bits(i));}
        let data = p.KEYROM.data.read().bits();
        report(&p, data);
        report(&p, p.KEYROM.lockstat.read().bits());
        if i >= 16 && i < 32 {
            assert!(data == 0, "lockout did not work correctly!");
        }
    }

    // set success to indicate to the CI framework that the test has passed
    p.SIMSTATUS.simstatus.modify(|_r, w| w.success().bit(true));
}
