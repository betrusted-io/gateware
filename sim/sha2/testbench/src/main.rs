#![cfg_attr(not(test), no_main)]
#![cfg_attr(not(test), no_std)]

use sim_bios::sim_test;
extern crate volatile;
use volatile::Volatile;

use hal_sha2::hal_sha2::*;

// allocate a global, unsafe static string. You can use this to force writes to RAM.
#[used] // This is necessary to keep DBGSTR from being optimized out
static mut DBGSTR: [u32; 8] = [0, 0, 0, 0, 0, 0, 0, 0];

const kData: &[u8; 142] = b"Every one suspects himself of at least one of the cardinal virtues, and this is mine: I am one of the few honest people that I have ever known";
const kExpectedDigest: [u32; 8] = [0xdc96c23d, 0xaf36e268, 0xcb68ff71, 0xe92f76e2, 0xb8a8379d, 0x426dc745, 0x19f5cff7, 0x4ec9c6d6];

fn report(p: &pac::Peripherals, data: u32) {
    unsafe{ p.SIMSTATUS.report.write(|w| w.bits(data)); }
}

#[sim_test]
fn run(p: &pac::Peripherals) {
    let ram_ptr: *mut u32 = 0x0100_0000 as *mut u32;
    let ram = ram_ptr as *mut Volatile<u32>;

    // example of using the DBGSTR to stash a variable from a raw pointer
    unsafe {
        DBGSTR[0] = (*(ram.add(4))).read();
    };

    report(p, 0x1000_0000);
    let mut sha2: BtSha2 = BtSha2::new();
    report(p, 0x1000_0001);
    sha2.config = Sha2Config::ENDIAN_SWAP | Sha2Config::DIGEST_SWAP | Sha2Config::SHA256_EN; // Sha2Config::HMAC_EN; // Sha2Config::SHA256_EN;
    sha2.keys = [0; 8];

    report(p, 0x1000_0002);
    sha2.init();
    report(p, 0x1000_0003);
    sha2.update(kData);
    report(p, 0x1000_0004);
    let mut digest: [u32; 8] = [0; 8];
    sha2.digest(&mut digest);
    report(p, 0x1000_0005);

    let mut pass: bool = true;
    for i in 0..8 {
        report(p, digest[i]);
        report(p, kExpectedDigest[i]);
        if digest[i] != kExpectedDigest[i] {
            pass = false;
        }
    }
    report(p, 0x1000_0006);

    // set success to indicate to the CI framework that the test has passed
    p.SIMSTATUS.simstatus.modify(|_r, w| w.success().bit(pass));
}
