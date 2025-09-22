#![no_std]
#![no_main]

use utralib::{generated::*};

// allocate a global, unsafe static string. You can use this to force writes to RAM.
#[used] // This is necessary to keep DBGSTR from being optimized out
static mut DBGSTR: [u32; 8] = [0, 0, 0, 0, 0, 0, 0, 0];

pub fn report(p: &pac::Peripherals, data: u32) {
    unsafe{
        p.SIMSTATUS.report.write(|w| w.bits( data ));
    }
}

use sim_bios::*;
#[no_mangle]
pub extern "Rust" fn run(p: &pac::Peripherals) {
    let mut perf_csr = CSR::new(HW_PERFCOUNTER_BASE as *mut u32);
    let mut event0_csr = CSR::new(HW_EVENT_SOURCE0_BASE as *mut u32);
    let mut event1_csr = CSR::new(HW_EVENT_SOURCE1_BASE as *mut u32);

    // this stops the performance counter. mostly saves power.
    perf_csr.wfo(utra::perfcounter::RUN_STOP, 1);

    // short saturate limit to test the mechanism. this must be set before saturate is set.
    perf_csr.wo(utra::perfcounter::SATURATE_LIMIT0, 0x320);
    perf_csr.wo(utra::perfcounter::SATURATE_LIMIT1, 0);

    // configure the system
    perf_csr.wo(utra::perfcounter::CONFIG,
        perf_csr.ms(utra::perfcounter::CONFIG_PRESCALER, 0)
        | perf_csr.ms(utra::perfcounter::CONFIG_SATURATE, 1)
        | perf_csr.ms(utra::perfcounter::CONFIG_EVENT_WIDTH_MINUS_ONE, 15)
    );

    // this starts the performance counter
    perf_csr.wfo(utra::perfcounter::RUN_RESET_RUN, 1);

    // register some events
    for i in 0..16 {
        event0_csr.wfo(utra::event_source0::PERFEVENT_CODE, i * 2);
        event1_csr.wfo(utra::event_source1::PERFEVENT_CODE, i * 2 + 1);
    }

    // "waste some time"
    for i in 1024..1024 + 32 {
        report(&p, i);
    }
    // should be no overflow at this point
    report(&p, perf_csr.rf(utra::perfcounter::STATUS_OVERFLOW));

    // register some more events
    for i in 128..128 + 8 {
        event0_csr.wfo(utra::event_source0::PERFEVENT_CODE, i * 2);
        event1_csr.wfo(utra::event_source1::PERFEVENT_CODE, i * 2 + 1);
    }

    // "waste more time"
    for i in 1024..1024 + 32 {
        report(&p, i);
    }

    // these should saturate out
    for i in 256..256 + 4 {
        event0_csr.wfo(utra::event_source0::PERFEVENT_CODE, i * 2);
        event1_csr.wfo(utra::event_source1::PERFEVENT_CODE, i * 2 + 1);
    }

    // stop the timer
    perf_csr.wfo(utra::perfcounter::RUN_STOP, 1);

    // read out the fifo - should read only exactly as many records as we have available
    while perf_csr.rf(utra::perfcounter::STATUS_READABLE) == 1  {
        report(&p, perf_csr.r(utra::perfcounter::EVENT_RAW0));
        report(&p, perf_csr.r(utra::perfcounter::EVENT_RAW1));
        report(&p, perf_csr.r(utra::perfcounter::EVENT_INDEX));
    }
    // report the overflow status -- should have overflowed
    report(&p, perf_csr.rf(utra::perfcounter::STATUS_OVERFLOW));

    // ------------ reset the engine and try with a different prescaler ----------
    let mut event2_csr = CSR::new(HW_EVENT_SOURCE2_BASE as *mut u32);
    let mut event3_csr = CSR::new(HW_EVENT_SOURCE3_BASE as *mut u32);
    let mut event4_csr = CSR::new(HW_EVENT_SOURCE4_BASE as *mut u32);
    //let mut event5_csr = CSR::new(HW_EVENT_SOURCE5_BASE as *mut u32);
    perf_csr.wfo(utra::perfcounter::RUN_STOP, 1);

    // configure the system
    perf_csr.wo(utra::perfcounter::CONFIG,
        perf_csr.ms(utra::perfcounter::CONFIG_PRESCALER, 3)
        | perf_csr.ms(utra::perfcounter::CONFIG_SATURATE, 1)
        | perf_csr.ms(utra::perfcounter::CONFIG_EVENT_WIDTH_MINUS_ONE, 31)
    );

    // this starts the performance counter
    perf_csr.wfo(utra::perfcounter::RUN_RESET_RUN, 1);

    // register some events
    for i in 0..16 {
        event2_csr.wfo(utra::event_source0::PERFEVENT_CODE, i * 4);
        event3_csr.wfo(utra::event_source1::PERFEVENT_CODE, i * 4 + 1);
        event4_csr.wfo(utra::event_source1::PERFEVENT_CODE, i * 4 + 2);
        //event5_csr.wfo(utra::event_source1::PERFEVENT_CODE, i * 4 + 3);
    }

    // stop the timer
    perf_csr.wfo(utra::perfcounter::RUN_STOP, 1);

    // read out the fifo - should read only exactly as many records as we have available
    while perf_csr.rf(utra::perfcounter::STATUS_READABLE) == 1  {
        report(&p, perf_csr.r(utra::perfcounter::EVENT_RAW0));
        report(&p, perf_csr.r(utra::perfcounter::EVENT_RAW1));
        report(&p, perf_csr.r(utra::perfcounter::EVENT_INDEX));
    }
    // report the overflow status -- should have overflowed
    report(&p, perf_csr.rf(utra::perfcounter::STATUS_OVERFLOW));

    // example of updating the "report" bits monitored by the CI framework
    report(&p, 0xFEEDC0DE);

    // set success to indicate to the CI framework that the test has passed
    p.SIMSTATUS.simstatus.modify(|_r, w| w.success().bit(true));
}
