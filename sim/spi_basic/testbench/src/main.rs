#![no_std]
#![no_main]

use sim_bios::sim_test;
extern crate volatile;
use volatile::Volatile;

// allocate a global, unsafe static string. You can use this to force writes to RAM.
#[used] // This is necessary to keep DBGSTR from being optimized out
static mut DBGSTR: [u32; 8] = [0, 0, 0, 0, 0, 0, 0, 0];

pub fn report(p: &pac::Peripherals, data: u32) {
    unsafe{
        p.SIMSTATUS.report.write(|w| w.bits( data ));
    }
}

#[sim_test]
fn run(p: &pac::Peripherals) {
    let ram_ptr: *mut u32 = 0x0101_0000 as *mut u32;
    let ram = ram_ptr as *mut Volatile<u32>;

    unsafe { // it's all unsafe
        p.SPIPERIPHERAL.control.write(|w| w.intena().bit(true));

        p.SPIPERIPHERAL.tx.write(|w| w.bits(0x0F0F));
        p.SPICONTROLLER.tx.write(|w| w.bits(0xF055));
        // p.SPICONTROLLER.control.write(|w| w.go().bit(true));
    	// note: if spiclk > cpuclock, the below line should be commented out on all transactons
        // while !p.SPICONTROLLER.status.read().tip().bit() { }
        while p.SPICONTROLLER.status.read().tip().bit() { }
        (*ram.add(0)).write( p.SPICONTROLLER.rx.read().bits() );
        (*ram.add(1)).write( p.SPIPERIPHERAL.rx.read().bits() );
        report(&p, (*ram.add(0)).read());
        report(&p, (*ram.add(1)).read());

        p.SPIPERIPHERAL.tx.write(|w| w.bits(0x1234));
        p.SPICONTROLLER.tx.write(|w| w.bits(0x90F1));
        //p.SPICONTROLLER.control.write(|w| w.go().bit(true));
    	// note: if spiclk > cpuclock, the below line should be commented out on all transactons
        // while !p.SPICONTROLLER.status.read().tip().bit() { }
        while p.SPICONTROLLER.status.read().tip().bit() { }
        (*ram.add(2)).write( p.SPICONTROLLER.rx.read().bits() );
        // (*ram.add(3)).write( p.SPIPERIPHERAL.rx.read().bits() );     // test overrun flag
        report(&p, (*ram.add(2)).read());


        p.SPIPERIPHERAL.tx.write(|w| w.bits(0x89ab));
        p.SPICONTROLLER.tx.write(|w| w.bits(0xbabe));
        //p.SPICONTROLLER.control.write(|w| w.go().bit(true));
    	// note: if spiclk > cpuclock, the below line should be commented out on all transactons
        // while !p.SPICONTROLLER.status.read().tip().bit() { }
        while p.SPICONTROLLER.status.read().tip().bit() { }
        (*ram.add(4)).write( p.SPICONTROLLER.rx.read().bits() );
        (*ram.add(5)).write( p.SPIPERIPHERAL.rx.read().bits() );
        report(&p, (*ram.add(4)).read());
        report(&p, (*ram.add(5)).read());


        p.SPIPERIPHERAL.tx.write(|w| w.bits(0xcdef));
        p.SPICONTROLLER.tx.write(|w| w.bits(0x3c06));
        //p.SPICONTROLLER.control.write(|w| w.go().bit(true));
    	// note: if spiclk > cpuclock, the below line should be commented out on all transactons
        // while !p.SPICONTROLLER.status.read().tip().bit() { }
        while p.SPICONTROLLER.status.read().tip().bit() { }
        (*ram.add(6)).write( p.SPICONTROLLER.rx.read().bits() );
        (*ram.add(7)).write( p.SPIPERIPHERAL.rx.read().bits() );
        report(&p, (*ram.add(6)).read());
        report(&p, (*ram.add(7)).read());


        p.SPIPERIPHERAL.tx.write(|w| w.bits(0xff00));
        p.SPICONTROLLER.tx.write(|w| w.bits(0x5a5a));
        //p.SPICONTROLLER.control.write(|w| w.go().bit(true));
    	// note: if spiclk > cpuclock, the below line should be commented out on all transactons
        // while !p.SPICONTROLLER.status.read().tip().bit() { }
        while p.SPICONTROLLER.status.read().tip().bit() { }
        (*ram.add(8)).write( p.SPICONTROLLER.rx.read().bits() );
        (*ram.add(9)).write( p.SPIPERIPHERAL.rx.read().bits() );
        report(&p, (*ram.add(8)).read());
        report(&p, (*ram.add(9)).read());

        // write performance benchmark
        for i in 0..16 {
            p.SPICONTROLLER.tx.write(|w| w.bits(i + 0x4c00));
            //p.SPICONTROLLER.control.write(|w| w.go().bit(true));
            // note: if spiclk > cpuclock, the below line should be commented out on all transactons
            // while !p.SPICONTROLLER.status.read().tip().bit() { }
            while p.SPICONTROLLER.status.read().tip().bit() { }
            (*ram.add(10 + i as usize)).write( p.SPIPERIPHERAL.rx.read().bits() );
            report(&p, (*ram.add(10 + i as usize)).read());
        }
    }

    // example of updating the "report" bits monitored by the CI framework
    unsafe {
        p.SIMSTATUS.report.write(|w| w.bits( (*ram.add(8)).read() ));
    }

    // set success to indicate to the CI framework that the test has passed
    p.SIMSTATUS.simstatus.modify(|_r, w| w.success().bit(true));
}
