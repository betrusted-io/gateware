#![no_std]
#![no_main]

extern crate volatile;
use volatile::Volatile;

// work around a compiler bug in rustc-1.58: https://github.com/rust-lang/rust/issues/92897
#[no_mangle]
pub fn __atomic_load_4(arg: *const usize, _ordering: usize) -> usize {
    unsafe { *arg }
}

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
    let ram_ptr: *mut u32 = 0x0100_1000 as *mut u32;
    let ram = ram_ptr as *mut Volatile<u32>;

//    let com_ptr: *mut u32 = 0xe0010000 as *mut u32;
    let com_ptr: *mut u32 = 0xd000_0000 as *mut u32;
    let com = com_ptr as *mut Volatile<u32>;

    unsafe { // just punt -- look, this is going to be all unsafe code!
        p.COM.control.write( |w| w.reset().bit(true) ); // reset fifos
        p.COM.control.write( |w| w.clrerr().bit(true) ); // clear all error flags

        //p.COM.ev_enable.write(|w| w.bits(0x7));  // enable interrupts

        //(*com).write(0x0f0f);

        p.SPICONTROLLER.tx.write(|w| w.bits(0xf055));


        while p.COM.status.read().rx_avail().bit() == false { }

        (*(ram.add(0))).write( p.SPICONTROLLER.rx.read().bits() );
        report(&p, 0x8000_0001);
        (*(ram.add(1))).write( (*com).read() );
        report(&p, 0x8000_0002);
        report(&p, (*(ram.add(1))).read());

        // split write
        for i in 0..16 {
            (*com).write( i + 0x6900 );
        }

        // write performance benchmark
        for i in 0..16 {
            p.SPICONTROLLER.tx.write(|w| w.bits(i + 0x4c00));

            while p.SPICONTROLLER.status.read().tip().bit() { }
        }

        // split read
        for i in 0..16 {
            (*ram.add(i+10)).write( (*com).read() );
            report(&p, (*(ram.add(i+10))).read());
        }

        report(&p, 0x8000_0003);
        // establish an out-of-phase condition: put 8 elements into the queue for Tx, but only take 4 out
        for i in 0..8 {
            (*com).write( i + 0xFAF0 );
        }
        for i in 0..4 {
            p.SPICONTROLLER.tx.write(|w| w.bits(i + 0x6960));

      	    // simulations show the below is critical in poll loops for sysclk=100MHz, spclk=25MHz
            while p.SPICONTROLLER.status.read().tip().bit() { }
        }

        report(&p, 0x8000_0004);
        if true {
            // latest version just resets the pointers
            p.COM.control.write( |w| w.reset().bit(true) ); // reset fifos
            p.COM.control.write( |w| w.clrerr().bit(true) ); // clear all error flags
        } else {
            // drain read fifo
            let mut offset = 4;
            while p.COM.status.read().rx_avail().bit() {
                (*ram.add(offset+10)).write( (*com).read() );
                report(&p, (*(ram.add(offset+10))).read());
                offset += 1;
            }
            // whoops! we should have a few items left over
            while p.COM.status.read().tx_empty().bit() == false {
//                p.COM.control.write(|w| w.pump().bit(true));
            }
        }

        // test what happens if we read an empty read fifo
        (*ram.add(50)).write( (*com).read() );
        report(&p, (*(ram.add(50))).read());

        // test what happens if we have a SPI transaction but no actual data
        p.SPICONTROLLER.tx.write(|w| w.bits(0xDEAD));

        // quick post-amble so we can quickly recognize the end of the simulation staring at the waveforms
        for i in 0..3 {
            (*ram.add(i + 127)).write( (*com).read() );
            report(&p, (*(ram.add(i + 127))).read());
        }

        // test error flag clearing
        p.COM.control.write(|w| w.clrerr().bit(true));

    }

    // example of updating the "report" bits monitored by the CI framework
    report(&p, 0x8000_0005);

    // set success to indicate to the CI framework that the test has passed
    p.SIMSTATUS.simstatus.modify(|_r, w| w.success().bit(true));

    p.SIMSTATUS.simstatus.modify(|_r, w| w.success().bit(true).done().bit(true)); // work around a VexMinDebug issue by setting the done bit here
    p.SIMSTATUS.simstatus.modify(|_r, w| w.success().bit(true).done().bit(true)); // work around a VexMinDebug issue by setting the done bit here
}
