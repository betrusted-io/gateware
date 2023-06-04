#![no_std]
use betrusted_rt::entry;
extern "Rust" {
    pub fn run(p: &pac::Peripherals);
}

#[entry]
fn main() -> ! {
    // Initialize the no-MMU version of Xous, which will give us
    // basic access to tasks and interrupts.
    xous_nommu::init();

    // extern functions are unsafe, even if they're Rust
    let p = unsafe { pac::Peripherals::steal() };
    unsafe { run(&p) };

    // set the done bit
    p.SIMSTATUS.simstatus.modify(|_r, w| w.done().bit(true));
    loop {}
}

use core::panic::PanicInfo;
#[panic_handler]
pub fn panic(_panic_info: &PanicInfo<'_>) -> ! {
    unsafe{ pac::Peripherals::steal().SIMSTATUS.report.write(|w| w.bits(0xC0DE_DEAD)); }
    unsafe{ pac::Peripherals::steal().SIMSTATUS.simstatus.write(|w| w.success().bit(false).done().bit(true)); }
    loop {}
}
