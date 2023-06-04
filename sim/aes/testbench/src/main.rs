#![no_std]
#![no_main]

extern crate volatile;
use volatile::Volatile;

// allocate a global, unsafe static string. You can use this to force writes to RAM.
#[used] // This is necessary to keep DBGSTR from being optimized out
static mut DBGSTR: [u32; 8] = [0, 0, 0, 0, 0, 0, 0, 0];

use betrusted_hal::hal_aes::*;

mod aes_test;
use aes_test::*;

use sim_bios::*;
#[no_mangle]
pub extern "Rust" fn run(p: &pac::Peripherals) {
    let ram_ptr: *mut u32 = 0x0100_0000 as *mut u32;
    let ram = ram_ptr as *mut Volatile<u32>;

    // example of using the DBGSTR to stash a variable from a raw pointer
    unsafe {
        DBGSTR[0] = (*(ram.add(4))).read();
    };

    let mut aes: BtAes = BtAes::new();
    let mut final_result = 0;

    let (pass, data) = test_aes_enc(&mut aes);
    if pass {
        final_result += 1;
    }

    for( reg, chunk) in data.chunks(4).enumerate() {
        let mut temp: [u8; 4] = Default::default();
        temp.copy_from_slice(chunk);
        let dword: u32 = u32::from_le_bytes(temp);
        unsafe{ p.SIMSTATUS.report.write(|w| w.bits(dword)); }
    }

    let (pass, data) = test_aes_dec(&mut aes);
    if pass {
        final_result += 1;
    }
    unsafe{ p.SIMSTATUS.report.write(|w| {w.bits(final_result)}); }

    for( reg, chunk) in data.chunks(4).enumerate() {
        let mut temp: [u8; 4] = Default::default();
        temp.copy_from_slice(chunk);
        let dword: u32 = u32::from_le_bytes(temp);
        unsafe{ p.SIMSTATUS.report.write(|w| w.bits(dword)); }
    }
    unsafe{ p.SIMSTATUS.report.write(|w| {w.bits(final_result)}); }

    // set success to indicate to the CI framework that the test has passed
    if final_result == 2 {
        p.SIMSTATUS.simstatus.modify(|_r, w| w.success().bit(true));
    } else {
        p.SIMSTATUS.simstatus.modify(|_r, w| w.success().bit(false));
    }
    // dummy update to let simulation flush value to register
    unsafe{ p.SIMSTATUS.report.write(|w| {w.bits(final_result)}); }
}
