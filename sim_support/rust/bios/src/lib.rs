#![no_std]

use betrusted_rt::entry;
pub use sim_bios_macros::sim_test;

extern "Rust" {
    pub fn run_test(p: &pac::Peripherals);
}

#[entry]
fn main() -> ! {
    // Initialize the no-MMU version of Xous, which will give us
    // basic access to tasks and interrupts.
    xous_nommu::init();

    // extern functions are unsafe, even if they're Rust
    let p = unsafe { pac::Peripherals::steal() };
    unsafe { run_test(&p) };

    // set the done bit
    p.SIMSTATUS.simstatus.modify(|_r, w| w.done().bit(true));
    loop {}
}
