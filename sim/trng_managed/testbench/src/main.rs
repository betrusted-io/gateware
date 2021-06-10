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

    // setup the TRNG to run "fast" so the simulation finishes in a reasonable amount of time, but "required" so we can check that the self-test passes in simulation
    // the ring oscillator is just a bodge so it tests much faster than the avalanche generator in this test bench
    unsafe{p.TRNG_SERVER.av_config.write(|w| w.samples().bits(0x1).required().bit(true));}
    unsafe{p.TRNG_SERVER.chacha.write(|w| w.reseed_interval().bits(1));} // make it reseed every block for this test

    // this turns off the ring oscillator
    // p.TRNG_SERVER.control.write(|w| w.ro_dis().set_bit());

    // wait until the FIFO is full
    while p.TRNG_KERNEL.status.read().avail().bit_is_clear() {
        step += 1;
        report(&p, step);
    }

    //////////// CHACHA generator tests
    let mut i = 0;
    while i < 128 {
        while p.TRNG_SERVER.urandom_valid.read().bits() == 0 {}
        report(&p, p.TRNG_SERVER.urandom.read().bits());
        i += 1;
    }
    unsafe{p.TRNG_SERVER.seed.write(|w| w.bits(0xfeed_face))};
    unsafe{p.TRNG_SERVER.seed.write(|w| w.bits(0xcafe_f00d))};
    i = 0;
    while i < 128 {
        while p.TRNG_KERNEL.urandom_valid.read().bits() == 0 {}
        report(&p, p.TRNG_KERNEL.urandom.read().bits());
        i += 1;
    }
    unsafe{p.TRNG_SERVER.seed.write(|w| w.bits(0xfeed_face))};
    unsafe{p.TRNG_SERVER.seed.write(|w| w.bits(0xcafe_f00d))};
    i = 0;
    while i < 128 {
        while p.TRNG_KERNEL.urandom_valid.read().bits() == 0 || p.TRNG_SERVER.urandom_valid.read().bits() == 0 {}
        p.TRNG_SERVER.test.write(|w| w.simultaneous().bit(true));
        i += 1;
    }
    i = 0;
    for _ in 0..64 {report(&p, 0x8888_8888);} // leave a marker so we can find this test in a trace
    while i < 8 {
        p.TRNG_SERVER.urandom.read().bits(); // realistic worst-case: one reader doing a fully unrolled read loop, and not doing anything with the data (store to register)
        p.TRNG_SERVER.urandom.read().bits(); // this completes at 40ns per request *but* you have cache fill misses in between, so aggregate rate is ~51ns/request
        p.TRNG_SERVER.urandom.read().bits();
        p.TRNG_SERVER.urandom.read().bits();
        p.TRNG_SERVER.urandom.read().bits();
        p.TRNG_SERVER.urandom.read().bits();
        p.TRNG_SERVER.urandom.read().bits();
        p.TRNG_SERVER.urandom.read().bits();
        p.TRNG_SERVER.urandom.read().bits();
        p.TRNG_SERVER.urandom.read().bits();
        p.TRNG_SERVER.urandom.read().bits();
        p.TRNG_SERVER.urandom.read().bits();
        p.TRNG_SERVER.urandom.read().bits();
        p.TRNG_SERVER.urandom.read().bits();
        p.TRNG_SERVER.urandom.read().bits();
        p.TRNG_SERVER.urandom.read().bits();
        // plus two more to ensure a failure
        p.TRNG_SERVER.urandom.read().bits();
        p.TRNG_SERVER.urandom.read().bits();
        i += 1;
    }
    for _ in 0..64 {report(&p, 0x12345678);} // leave a marker so we can find this test in a trace
    i = 0;
    while i < 8 {
        p.TRNG_SERVER.test.write(|w| w.simultaneous().bit(true)); // synthetic worst-case read rate
        p.TRNG_SERVER.test.write(|w| w.simultaneous().bit(true)); // fully-unrolled read loop of 2x buffers at once
        p.TRNG_SERVER.test.write(|w| w.simultaneous().bit(true));
        p.TRNG_SERVER.test.write(|w| w.simultaneous().bit(true));
        p.TRNG_SERVER.test.write(|w| w.simultaneous().bit(true));
        p.TRNG_SERVER.test.write(|w| w.simultaneous().bit(true));
        p.TRNG_SERVER.test.write(|w| w.simultaneous().bit(true));
        p.TRNG_SERVER.test.write(|w| w.simultaneous().bit(true));
        p.TRNG_SERVER.test.write(|w| w.simultaneous().bit(true));
        p.TRNG_SERVER.test.write(|w| w.simultaneous().bit(true));
        p.TRNG_SERVER.test.write(|w| w.simultaneous().bit(true));
        p.TRNG_SERVER.test.write(|w| w.simultaneous().bit(true));
        p.TRNG_SERVER.test.write(|w| w.simultaneous().bit(true));
        p.TRNG_SERVER.test.write(|w| w.simultaneous().bit(true));
        p.TRNG_SERVER.test.write(|w| w.simultaneous().bit(true));
        p.TRNG_SERVER.test.write(|w| w.simultaneous().bit(true)); // buffer exhausted here
        // these would extend beyond a refill and should fail
        p.TRNG_SERVER.test.write(|w| w.simultaneous().bit(true));
        p.TRNG_SERVER.test.write(|w| w.simultaneous().bit(true));
        i += 1;
        // ChaCha next-to-ready time is 78 cycles
        // buffer holds 16 blocks, so to exhaust the TRNG supply, you have to read in a loop that is tighter than 5 cycles long.
        // a fully unrolled loop like above takes 20 cycles per unrolled iteration, so this breaks without checking valid
    }
    for _ in 0..64 {report(&p, 0xDDDD_DDDD);} // leave a marker so we can find this test in a trace
    i = 0;
    while i < 64 {
        p.TRNG_SERVER.test.write(|w| w.simultaneous().bit(true)); // odd-multiple pattern
        report(&p, p.TRNG_SERVER.urandom.read().bits());
        i += 1;
    }
    unsafe{p.TRNG_SERVER.chacha.write(|w| w.reseed_interval().bits(2));} // make it reseed every two blocks to confirm the counter works right
    for _ in 0..64 {report(&p, 0xCCCC_CCCC);} // leave a marker so we can find this test in a trace
    i = 0;
    while i < 256 { // random pattern
        let val = p.TRNG_SERVER.urandom.read().bits();
        match val & 3 {
            0 => p.TRNG_SERVER.test.write(|w| w.simultaneous().bit(true)),
            1 => report(&p, p.TRNG_SERVER.urandom.read().bits()),
            2 => report(&p, p.TRNG_KERNEL.urandom.read().bits()),
            _ => ()
        }
        i += 1;
    }
    //////////// end CHACHA generator tests

    // we continue on here to test various aspects of filling/emptying FIFOs reading raw entropy
    step = 0x2000_0000;
    report(&p, step);

    report(&p, p.TRNG_KERNEL.data.read().bits());

    step = 0x3000_0000;
    report(&p, step);

    // check the fresh bit
    report(&p, p.TRNG_SERVER.nist_ro_stat0.read().bits());
    report(&p, p.TRNG_SERVER.nist_ro_stat0.read().bits());

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
