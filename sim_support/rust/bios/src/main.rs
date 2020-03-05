#![no_main]
#![feature(lang_items)]
#![no_std]

use core::panic::PanicInfo;
use betrusted_rt::entry;

#[panic_handler]
fn panic(_panic_info: &PanicInfo<'_>) -> ! {
    loop {}
}

extern crate test;
use test::Test;

#[entry]
fn main() -> ! {
    // Initialize the no-MMU version of Xous, which will give us
    // basic access to tasks and interrupts.
    xous_nommu::init();

    let mut t: Test = Test::new();
    
    t.run();

    loop {
      // idle the CPU at end of test
    }
}
