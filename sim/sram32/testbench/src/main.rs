#![no_std]
#![no_main]

extern crate volatile;
use volatile::Volatile;

// allocate a global, unsafe static string. You can use this to force writes to RAM.
#[used] // This is necessary to keep DBGSTR from being optimized out
static mut DBGSTR: [u32; 8] = [0, 0, 0, 0, 0, 0, 0, 0];

use sim_bios::*;
#[no_mangle]
pub extern "Rust" fn run(p: &pac::Peripherals) {
    let ram_ptr: *mut u32 = 0x4000_0000 as *mut u32;
    let ram = ram_ptr as *mut Volatile<u32>;

    let byte_ptr: *mut u8 = 0x4000_0000 as *mut u8;
    let byte = byte_ptr as *mut Volatile<u8>;

    // this is less a CI test and more a series of instructions designed to allow us to
    // manually check the timing results of the SRAM implementation

    p.SRAM_EXT.read_config.write(|w| w.trigger().bit(true));

    // delay while the config write runs
    for j in 0..20 {
        unsafe {
            p.SIMSTATUS.report.write(|w| w.bits(j));
        }
    }

    unsafe {
        // test word-writes
        (*(ram.add( 0x4))).write( (*(ram.add(0x20))).read() + (*(ram.add(0x31))).read() + 0xfeedface );
        (*(ram.add(0x50))).write( (*(ram.add(0x64))).read() + (*(ram.add(0x75))).read() + 0xdeadbeef );
        
        // test byte-writes
        (*(byte.add(0x00))).write( (*(byte.add(0x180))).read() + (*(byte.add(0x1a1))).read() + 0xaa );
        (*(byte.add(0x11))).write( (*(byte.add(0x1b2))).read() + (*(byte.add(0x1c3))).read() + 0x55 );
        (*(byte.add(0x22))).write( (*(byte.add(0x1d4))).read() + (*(byte.add(0x1e5))).read() + 0x33 );
        (*(byte.add(0x33))).write( (*(byte.add(0x1f6))).read() + (*(byte.add(0x207))).read() + 0xcc );
    }
    // p.SRAM_EXT.config_status.read().bits() // this reads the status bits from SRAM, but not modeled right now

    // return one of the computed RAM values
    unsafe {
        let ret: u32 = (*ram.add(0xc0de)).read();
        p.SIMSTATUS.report.write(|w| w.bits( ret ));
    }

    // set success to indicate to the CI framework that the test has passed
    p.SIMSTATUS.simstatus.modify(|_r, w| w.success().bit(true));
}
