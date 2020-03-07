#![no_std]
#![no_main]

use sim_bios::sim_test;
extern crate volatile;
use volatile::Volatile;

fn lfsr(state: u16) -> u16 {
	/* taps: 16 14 13 11; feedback polynomial: x^16 + x^14 + x^13 + x^11 + 1 */
    let bit = ((state >> 0) ^ (state >> 2) ^ (state >> 3) ^ (state >> 5) ) & 1;
    (state >> 1) | (bit << 15)
}

#[sim_test]
fn run(p: &pac::Peripherals) {
    let rom_ptr: *mut u32 = 0x2000_0000 as *mut u32;
    let rom = rom_ptr as *mut Volatile<u32>;

    let mut dest: [u32; 1024] = [0; 1024];

    // sequential read of 64 words starting at 0; this should be 8 cache lines (8x32 words/cache line)
    for j in 0..64 {
        unsafe{ dest[j] = (*(rom.add(j))).read(); }
    }

    let mut r: u16 = 0xF0AA;
    // do a simple, random read
    for j in 0..32 {
        unsafe{ dest[j] = (*(rom.add((r as usize) & (1024-1)))).read(); }
        r = lfsr(r);
    }

    // sanity check on LFSR and caching
    r = 1;
    for j in 0..32 {
        r = lfsr(r);
        dest[(r as usize) & (1024-1)] = 0xBEEF_0000 + j;
    }
    
    // grab the return code embedded in the SPI ROM image
    let ret: u32;
    
    unsafe{ ret = (*(rom.add(1024*64 / 4))).read(); }

    // example of updating the "report" bits monitored by the CI framework
    unsafe {
        p.SIMSTATUS.report.write(|w| w.bits(ret));
    }

    // set success to indicate to the CI framework that the test has passed
    p.SIMSTATUS.simstatus.modify(|_r, w| w.success().bit(true));
}
