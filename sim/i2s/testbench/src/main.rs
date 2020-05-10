#![no_std]
#![no_main]

use sim_bios::sim_test;
extern crate volatile;
use volatile::Volatile;

#[used] // This is necessary to keep DBGSTR from being optimized out
static mut DBGSTR: [u32; 8] = [0, 0, 0, 0, 0, 0, 0, 0];

#[sim_test]
fn run(p: &pac::Peripherals) {
    const FIFODEPTH: usize = 8;

    let duplex_ptr: *mut u32 = 0xe000_0020 as *mut u32;
    let duplex = duplex_ptr as *mut Volatile<u32>;

    let spkr_ptr: *mut u32 = 0xe000_0000 as *mut u32; // called "audio" in the RTL
    let spkr = spkr_ptr as *mut Volatile<u32>;

    p.AUDIO.tx_ctl.write(|w| w.reset().bit(true));
    p.I2S_DUPLEX.tx_ctl.write(|w| w.reset().bit(true));
    p.I2S_DUPLEX.rx_ctl.write(|w| w.reset().bit(true));

    // insert dummy delays, because Rust is really good at optimizing and
    // the array operation below is optimized out, which causes a timing
    // DRC on FIFO reset
    unsafe {
        p.SIMSTATUS.report.write(|w| w.bits( 4 ));
        p.SIMSTATUS.report.write(|w| w.bits( 3 ));
        p.SIMSTATUS.report.write(|w| w.bits( 2 ));
        p.SIMSTATUS.report.write(|w| w.bits( 1 ));
    }

    // initialize an audio buffer with some synthetic data
    let mut audio: [u32; FIFODEPTH*2] = [0; FIFODEPTH*2];
    for j in 0..FIFODEPTH*2 {
        audio[j] = ((j << 16) | (FIFODEPTH-j)) as u32;
    }
    
    for j in 0..FIFODEPTH*2 {
        unsafe {
            (*duplex).write(audio[j]);
            (*spkr).write(audio[FIFODEPTH*2 - 1 -j]);
        }
    }

    p.AUDIO.tx_ctl.write(|w| w.enable().bit(true));
    p.I2S_DUPLEX.tx_ctl.write(|w| w.enable().bit(true));
    p.I2S_DUPLEX.rx_ctl.write(|w| w.enable().bit(true));

    // test a read when FIFO is empty
    unsafe{ DBGSTR[0] = (*duplex).read(); }
    
    let mut count: usize = 0;
    let mut sample: u32 = 0;
    loop {
        if p.I2S_DUPLEX.tx_stat.read().free().bit() {
            for _ in 0 ..FIFODEPTH {
                unsafe {
                    sample = (*duplex).read();
                    (*duplex).write(sample + 0x2000_3000);
                    (*spkr).write(sample + 0x4000_5000);
                }
            }
            count += 1;
            if count > 4 {
                break;            
            }
        }
    }

    unsafe {
        p.SIMSTATUS.report.write(|w| w.bits( sample ));
    }

    // set success to indicate to the CI framework that the test has passed
    p.SIMSTATUS.simstatus.modify(|_r, w| w.success().bit(true));
}
