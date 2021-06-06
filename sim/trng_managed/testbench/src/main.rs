#![no_std]
#![no_main]

use sim_bios::sim_test;
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

#[sim_test]
fn run(p: &pac::Peripherals) {
    let ram_ptr: *mut u32 = 0x0100_0000 as *mut u32;
    let ram = ram_ptr as *mut Volatile<u32>;

    let mut step = 0x1000_0000;
    report(&p, step);

    // setup the TRNG to run "fast" so the simulation finishes in a reasonable amount of time
    unsafe{p.TRNG_SERVER.av_config.write(|w| w.samples().bits(0x1));}

    // this turns off the ring oscillator
    // p.TRNG_SERVER.control.write(|w| w.ro_dis().set_bit());

    while p.TRNG_KERNEL.status.read().avail().bit_is_clear() {
        step += 1;
        report(&p, step);
    }

    step = 0x2000_0000;
    report(&p, step);

    report(&p, p.TRNG_KERNEL.data.read().bits());

    step = 0x3000_0000;
    report(&p, step);

    while p.TRNG_SERVER.status.read().full().bit_is_clear() {
        step += 1;
        report(&p, step);
    }

    report(&p, 0xFFFF_FFFF);
    report(&p, 0xFFFF_FFFF);
    report(&p, 0xFFFF_FFFF);
    report(&p, 0xFFFF_FFFF);

    while p.TRNG_KERNEL.status.read().avail().bit_is_clear() {}
    report(&p, p.TRNG_KERNEL.data.read().bits());
    while p.TRNG_KERNEL.status.read().avail().bit_is_clear() {}
    report(&p, p.TRNG_KERNEL.data.read().bits());


    report(&p, 0xEEEE_EEEE);
    report(&p, 0xEEEE_EEEE);
    report(&p, 0xEEEE_EEEE);
    report(&p, 0xEEEE_EEEE);

    for _ in 0..72 {
        while p.TRNG_SERVER.status.read().avail().bit_is_clear() {}
        report(&p, p.TRNG_SERVER.data.read().bits());
    }

    report(&p, 0xDDDD_DDDD);
    report(&p, 0xDDDD_DDDD);
    report(&p, 0xDDDD_DDDD);
    report(&p, 0xDDDD_DDDD);

    step = 0x4000_0000;
    report(&p, step);

    while p.TRNG_SERVER.status.read().full().bit_is_clear() {
        step += 1;
        report(&p, step);
    }

    while p.TRNG_KERNEL.status.read().avail().bit_is_clear() {}
    report(&p, p.TRNG_KERNEL.data.read().bits());

    // add a delay so we can confirm that the TRNG manager idle state is also good.
    for i in 0..10000 {
        report(&p, i);
    }

    // set success to indicate to the CI framework that the test has passed
    p.SIMSTATUS.simstatus.modify(|_r, w| w.success().bit(true));
}
