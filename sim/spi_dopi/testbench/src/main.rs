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

pub fn report(p: &pac::Peripherals, data: u32) {
    unsafe{
        p.SIMSTATUS.report.write(|w| w.bits( data ));
    }
}

// locate this in the "data" section so it's running out of RAM. Cannot XIP & program flash at the same time!
#[no_mangle]
#[link_section = ".data"]
#[inline(never)]
pub fn write_tests(p: &pac::Peripherals) {
    let rom_ptr: *mut u32 = 0x2000_0000 as *mut u32;
    let rom = rom_ptr as *mut Volatile<u32>;

    let mut phase = 0x5000_0000;
    report(&p, phase); phase += 1;

    unsafe {
        p.SPINOR.cmd_arg.write(|w| w.cmd_arg().bits(0));
        p.SPINOR.command.write(|w| w
            .exec_cmd().set_bit()
            .cmd_code().bits(0x9f) // RDID
            .dummy_cycles().bits(4)
            .data_words().bits(2)
            .has_arg().set_bit()
        );
    }
    while p.SPINOR.status.read().wip().bit_is_set() {}

    let status = p.SPINOR.cmd_rbk_data.read().bits();
    report(&p, status);

    unsafe {
        p.SPINOR.command.write(|w| w
            .lock_reads().set_bit()
            .exec_cmd().set_bit()
            .cmd_code().bits(0x06) // WREN
        );
     }
     report(&p, phase); phase += 1;
     while p.SPINOR.status.read().wip().bit_is_set() {}
     report(&p, phase); phase += 1;
     unsafe {
        p.SPINOR.cmd_arg.write(|w| w.cmd_arg().bits(0));
        p.SPINOR.command.write(|w| w
            .lock_reads().set_bit()
            .exec_cmd().set_bit()
            .cmd_code().bits(0x05) // RDSR
            .dummy_cycles().bits(4)
            .data_words().bits(1)
            .has_arg().set_bit()
        );
     }
     report(&p, phase); phase += 1;
     while p.SPINOR.status.read().wip().bit_is_set() {}
     report(&p, p.SPINOR.cmd_rbk_data.read().bits());

    // sector erase
    let mut phase = 0x6000_0000;
    report(&p, phase); phase += 1;
    unsafe {
        p.SPINOR.cmd_arg.write(|w| w.cmd_arg().bits(0x03_CC00));
        p.SPINOR.command.write(|w| w
            .lock_reads().set_bit()
            .exec_cmd().set_bit()
            .cmd_code().bits(0x21) // SE4B
            //.dummy_cycles().bits(0)
            //.data_words().bits(0)
            .has_arg().set_bit()
        );
     }
     report(&p, phase); phase += 1;
     while p.SPINOR.status.read().wip().bit_is_set() {}
     report(&p, phase); phase += 1;

    // try to do a read, should be locked out -- bus will freeze until timeout, but at least it doesn't crash the state machine
    report(&p, unsafe{(*(rom.add(0x1140))).read()});

     // status register readback, wait until sector erase is done
     loop {
        unsafe {
            p.SPINOR.cmd_arg.write(|w| w.cmd_arg().bits(0));
            p.SPINOR.command.write(|w| w
                .lock_reads().set_bit()
                .exec_cmd().set_bit()
                .cmd_code().bits(0x05) // RDSR
                .dummy_cycles().bits(4)
                .data_words().bits(1)
                .has_arg().set_bit()
            );
        }
        while p.SPINOR.status.read().wip().bit_is_set() {}
        let status = p.SPINOR.cmd_rbk_data.read().bits();
        report(&p, status);
        if (status & 1) == 0 {
            break;
        }
    }

    unsafe {
        p.SPINOR.command.write(|w| w
            .lock_reads().set_bit()
            .exec_cmd().set_bit()
            .cmd_code().bits(0x06) // WREN
        );
     }
     report(&p, phase); phase += 1;
     while p.SPINOR.status.read().wip().bit_is_set() {}

    let mut phase = 0x8000_0000;
     // page program some data
     // CSR is provided for non-cached writes
     unsafe {
        p.SPINOR.wdata.write(|w| w
            .wdata().bits(0xbeef)
        );
        p.SPINOR.wdata.write(|w| w
            .wdata().bits(0xc0de)
        );
    }
        for i in 0..16 {  // overfill a bit to flush cache
            /*
            p.SPINOR.wdata.write(|w| w
                .wdata().bits(0x6000 + i)
            );*/
            unsafe {
                // this is not actually reliable in the test bench because it's cached from the CPU
                (*rom.add(i)).write( (0x5500 + i*2 | (0x5500 + i*2 + 1) << 16) as u32);
            }
        }

    report(&p, phase); phase += 1;
    unsafe {
        p.SPINOR.cmd_arg.write(|w| w.cmd_arg().bits(0x03_CC00));
        p.SPINOR.command.write(|w| w
            .lock_reads().set_bit()
            .exec_cmd().set_bit()
            .cmd_code().bits(0x12) // PP4B
            .has_arg().set_bit()
            .data_words().bits(16)
        );
     }
     report(&p, phase); phase += 1;
     while p.SPINOR.status.read().wip().bit_is_set() {}
     report(&p, phase); phase += 1;

     // status register readback, wait until page program is done
     loop {
        unsafe {
            p.SPINOR.cmd_arg.write(|w| w.cmd_arg().bits(0));
            p.SPINOR.command.write(|w| w
                .lock_reads().set_bit()
                .exec_cmd().set_bit()
                .cmd_code().bits(0x05) // RDSR
                .dummy_cycles().bits(4)
                .data_words().bits(1)
                .has_arg().set_bit()
            );
        }
        while p.SPINOR.status.read().wip().bit_is_set() {}
        let status = p.SPINOR.cmd_rbk_data.read().bits();
        report(&p, status);
        if (status & 1) == 0 {
            break;
        }
    }
    p.SPINOR.command.write(|w| w
        .lock_reads().clear_bit()
    );

    report(&p, phase);
}

#[sim_test]
fn run(p: &pac::Peripherals) {
    let rom_ptr: *mut u32 = 0x2000_0000 as *mut u32;
    let rom = rom_ptr as *mut Volatile<u32>;

    let mut dest: [u32; 1024] = [0; 1024];

    // sequential read of 64 words starting at 0; this should be 8 cache lines (8x32 words/cache line)
    for j in 0..64 {
        unsafe{ dest[j] = (*(rom.add(j))).read(); }
        report(&p, dest[j]);
    }

    let mut r: u16 = 0xF0AA;
    // do a simple, random read
    for j in 0..32 {
        unsafe{ dest[j] = (*(rom.add((r as usize) & (1024-1)))).read(); }
        report(&p, dest[j]);
        r = lfsr(r);
    }

    // sanity check on LFSR and caching
    r = 1;
    for j in 0..32 {
        r = lfsr(r);
        report(&p, r as u32);
        dest[(r as usize) & (1024-1)] = 0xBEEF_0000 + j;
    }

    // grab the return code embedded in the SPI ROM image
    let ret: u32;
    unsafe{ ret = (*(rom.add(1024*64 / 4))).read(); }
    report(&p, ret);

    report(&p, 0x7000_0000);

    // call the write tests -- they run out of RAM, because you can't read ROM pages while doing writes
    write_tests(&p);

    report(&p, 0x9000_0000);

    // a second set of reads to just make sure that the read state machine is in good standing after writing
    report(&p, unsafe{(*(rom.add(0x2140))).read()});
    // read back the data that was written
    for i in 0..8 {
        let readcheck =  unsafe{ (*(rom.add((0x03_cc00 / 4) + i))).read() };
        report(&p, readcheck);
    }

    for j in 0..64 {
        unsafe{ dest[j] = (*(rom.add(j))).read(); }
        report(&p, dest[j]);
    }

    report(&p, 0xc0de_600d);
    // set success to indicate to the CI framework that the test has passed
    p.SIMSTATUS.simstatus.modify(|_r, w| w.success().bit(true));
}
