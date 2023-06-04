#![no_std]
#![no_main]
#![feature(alloc_error_handler)]

extern crate volatile;
use volatile::Volatile;
extern crate jtag;
use jtag::*;

// pull in external symbols to define heap start and stop
// defined in memory.x
extern "C" {
    static _sheap: u8;
    static _heap_size: u8;
}

// Plug in the allocator crate
#[macro_use]
extern crate alloc;
extern crate alloc_riscv;

use alloc_riscv::RiscvHeap;

#[global_allocator]
static ALLOCATOR: RiscvHeap = RiscvHeap::empty();

// allocate a global, unsafe static string for debug output
#[used] // This is necessary to keep DBGSTR from being optimized out
static mut DBGSTR: [u32; 8] = [0, 0, 0, 0, 0, 0, 0, 0];

#[alloc_error_handler]
fn alloc_error_handler(layout: alloc::alloc::Layout) -> ! {
    unsafe{ DBGSTR[0] = layout.size() as u32; }
    panic!()
}

const CMD_FUSE_KEY: u32 = 0b110001;

use sim_bios::*;
#[no_mangle]
pub extern "Rust" fn run(p: &pac::Peripherals) {
    unsafe {
        let heap_start = &_sheap as *const u8 as usize;
        let heap_size = &_heap_size as *const u8 as usize;
        ALLOCATOR.init(heap_start, heap_size);
    }

    let ram_ptr: *mut u32 = 0x0100_0000 as *mut u32;
    let ram = ram_ptr as *mut Volatile<u32>;

    let mut jm = JtagMach::new();
    let mut jp = JtagGpioPhy::new();

    jm.reset(&mut jp);

    // get the KEY fuse
    let mut ir_leg: JtagLeg = JtagLeg::new(JtagChain::IR, "cmd");
    ir_leg.push_u32(CMD_FUSE_KEY, 6, JtagEndian::Little);
    jm.add(ir_leg);
    jm.next(&mut jp);

    let mut ret: u32 = 0;
    if let Some(mut data) = jm.get() {
        // it's safe to just pop the "max length" because pop is "best effort only"
        ret = data.pop_u32(6, JtagEndian::Little).unwrap();
    }

    // example of updating the "report" bits monitored by the CI framework
    unsafe {
        p.SIMSTATUS.report.write(|w| w.bits(ret));
    }

    // set success to indicate to the CI framework that the test has passed
    p.SIMSTATUS.simstatus.modify(|_r, w| w.success().bit(true));
}
