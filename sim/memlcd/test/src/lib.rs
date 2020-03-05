#![no_std]

extern crate pac;

// allocate a global, unsafe static string for debug output
#[used] // This is necessary to keep DBGSTR from being optimized out
static mut DBGSTR: [u32; 8] = [0, 0, 0, 0, 0, 0, 0, 0];

pub struct Test {
	p: pac::Peripherals,
}

impl Test {
	pub fn new() -> Self {
		unsafe {
			Test {
				p: pac::Peripherals::steal(),
			}
		}
	}

	pub fn run(&mut self) {
		unsafe{ DBGSTR[0] = 0xface; }

		// set the success bit
		self.p.SIMSTATUS.simstatus.write(|w| w.success().bit(true));
	}
}
