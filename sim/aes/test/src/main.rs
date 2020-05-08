#![no_std]
#![no_main]

use sim_bios::sim_test;
extern crate volatile;
use volatile::Volatile;

// allocate a global, unsafe static string. You can use this to force writes to RAM.
#[used] // This is necessary to keep DBGSTR from being optimized out
static mut DBGSTR: [u32; 8] = [0, 0, 0, 0, 0, 0, 0, 0];

use betrusted_hal::hal_aes::*;

mod aes_test;
use aes_test::*;

#[sim_test]
fn run(p: &pac::Peripherals) {
    let ram_ptr: *mut u32 = 0x0100_0000 as *mut u32;
    let ram = ram_ptr as *mut Volatile<u32>;

    // example of using the DBGSTR to stash a variable from a raw pointer
    unsafe {
        DBGSTR[0] = (*(ram.add(4))).read();
    };

    let mut aes: BtAes = BtAes::new();

    let (pass, data) = test_aes_enc(&mut aes);

    for( reg, chunk) in data.chunks(4).enumerate() {
        let mut temp: [u8; 4] = Default::default();
        temp.copy_from_slice(chunk);
        let dword: u32 = u32::from_be_bytes(temp);
        unsafe{ p.SIMSTATUS.report.write(|w| w.bits(dword)); }
    }

    // set success to indicate to the CI framework that the test has passed
    if pass {
        p.SIMSTATUS.simstatus.modify(|_r, w| w.success().bit(true));
    }
}
