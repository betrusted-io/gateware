#![no_std]
#![no_main]

use sim_bios::sim_test;
extern crate volatile;
use volatile::Volatile;

extern crate digest;
use digest::Digest;
extern crate sha512_hal;
use sha512_hal::hal_sha512::{Sha512, Sha512Trunc256};


const K_DATA: &'static [u8; 142] = b"Every one suspects himself of at least one of the cardinal virtues, and this is mine: I am one of the few honest people that I have ever known";
const K_EXPECTED_DIGEST: [u64; 8] =    [0x02fc78c0d16b727a, 0x18570a3279e6c97b, 0x113b8871b2e92051, 0x4c0947b20169fedf, 0x1a67094ad04ad031, 0xab5f8cc340125001, 0xffbd7d7af36d3a3a, 0xf7e8465d73bbd86d];
// 7a726bd1c078fc02 7bc9e679320a5718 5120e9b271883b11 dffe6901b247094c 31d04ad04a09671a 01501240c38c5fab 3a3a6df37a7dbdff 6dd8bb735d46e8f7

const K_EXPECTED_DIGEST_256: [u64; 4] = [0x4efe9a5709f2fb3d, 0x56538af5e6af1cb9, 0x4477edf136cec4cc, 0x9f9a61797f3452e9];
// 3dfbf209579afe4e b91cafe6f58a5356 ccc4ce36f1ed7744 e952347f79619a9f

fn report(p: &pac::Peripherals, data: u32) {
    unsafe{ p.SIMSTATUS.report.write(|w| w.bits(data)); }
}

#[sim_test]
fn run(p: &pac::Peripherals) {
    let mut pass: bool = true;

    report(p, 0x1000_0000);
    let mut hasher = Sha512::new();

    report(p, 0x1000_0001);

    for (_reg, chunk) in K_DATA.chunks(16).enumerate() {
        let mut temp: [u8; 16] = Default::default();
        if chunk.len() == 16 {
            temp.copy_from_slice(chunk);
            hasher.update(temp);
        } else {
            for index in 0..chunk.len() {
                let lone_value: [u8; 1] = [chunk[index]];
                hasher.update(&lone_value);
            }
        }
    }

    report(p, 0x1000_0002);
    let digest = hasher.finalize();

    report(p, 0x1000_0003);
    for i in 0..64 {
        let byte: u8 = (((K_EXPECTED_DIGEST[i / 8]) >> ((i % 8) * 8)) & 0xff) as u8;
        report(p, digest[i] as u32);
        report(p, byte as u32);
        if digest[i] != byte {
            pass = false;
        }
    }
    if pass {
        report(p, 0x1000_0004);
    } else {
        report(p, 0xDEAD_0004);
    }

/*
        let mut sha512: BtSha512 = BtSha512::new();
        report(p, 0x1000_0001);
        sha512.config = Sha512Config::ENDIAN_SWAP | Sha512Config::DIGEST_SWAP | Sha512Config::SHA512_EN; // Sha2Config::HMAC_EN; // Sha2Config::SHA256_EN;

        report(p, 0x1000_0002);
        sha512.init();
        report(p, 0x1000_0003);
        sha512.update(kData);
        report(p, 0x1000_0004);
        let mut digest: [u64; 8] = [0; 8];
        sha512.digest(&mut digest); // this should also reset the block
        report(p, 0x1000_0005);

        for i in 0..8 {
            report(p, digest[i] as u32);
            report(p, kExpectedDigest[i] as u32);
            report(p, (digest[i] >> 32) as u32);
            report(p, (kExpectedDigest[i] >> 32) as u32);
            if digest[i] != kExpectedDigest[i] {
                pass = false;
            }
        }
        if pass {
            report(p, 0x1000_0006);
        } else {
            report(p, 0xDEAD_0006);
        }

        // test sha512/256
        report(p, 0x1000_0007);
        let mut sha512b: BtSha512 = BtSha512::new();
        sha512b.config = Sha512Config::ENDIAN_SWAP | Sha512Config::DIGEST_SWAP | Sha512Config::SHA512_EN | Sha512Config::SHA512_256;

        report(p, 0x1000_0008);
        sha512b.init();

        report(p, 0x1000_0009);
        sha512b.update(kData);
        report(p, 0x1000_000A);
        let mut digest256: [u64; 4] = [0; 4];
        sha512b.digest256(&mut digest256); // this should also reset the block
        report(p, 0x1000_000B);

        for i in 0..4 {
            report(p, digest256[i] as u32);
            report(p, kExpectedDigest256[i] as u32);
            report(p, (digest256[i] >> 32) as u32);
            report(p, (kExpectedDigest256[i] >> 32) as u32);
            if digest256[i] != kExpectedDigest256[i] {
                pass = false;
            }
        }
        if pass {
            report(p, 0x1000_000C);
        } else {
            report(p, 0xDEAD_000C);
        }

        // test a hard reset part way through
        report(p, 0x1000_000D);
        let mut sha512c: BtSha512 = BtSha512::new();
        sha512c.config = Sha512Config::ENDIAN_SWAP | Sha512Config::DIGEST_SWAP | Sha512Config::SHA512_EN | Sha512Config::SHA512_256;

        report(p, 0x1000_000E);
        sha512c.init();

        report(p, 0x1000_000F);
        sha512c.update(kData);

        report(p, 0x1000_FFFF);

        ///////// do the hash reset!
        p.SHA512.command.write(|w| { w.hash_process().set_bit() });
        while (p.SHA512.ev_pending.read().bits() & (Sha512Event::SHA512_DONE).bits()) == 0 {}
        unsafe { p.SHA512.ev_pending.write(|w| w.bits((Sha512Event::SHA512_DONE).bits())); }
        unsafe { p.SHA512.config.write(|w| { w.bits(0) }); }

        // now restart the hash
        report(p, 0x1000_0010);
        let mut sha512d: BtSha512 = BtSha512::new();
        sha512d.config = Sha512Config::ENDIAN_SWAP | Sha512Config::DIGEST_SWAP | Sha512Config::SHA512_EN;

        report(p, 0x1000_0011);
        sha512d.init();

        report(p, 0x1000_0012);
        sha512d.update(kData);
        report(p, 0x1000_0013);
        let mut digest3: [u64; 8] = [0; 8];
        sha512d.digest(&mut digest3); // this should also reset the block
        report(p, 0x1000_0014);

        for i in 0..8 {
            report(p, digest3[i] as u32);
            report(p, kExpectedDigest[i] as u32);
            report(p, (digest3[i] >> 32) as u32);
            report(p, (kExpectedDigest[i] >> 32) as u32);
            if digest3[i] != kExpectedDigest[i] {
                pass = false;
            }
        }
        if pass {
            report(p, 0x1000_0015);
        } else {
            report(p, 0xDEAD_0015);
        }
    */
    // set success to indicate to the CI framework that the test has passed
    p.SIMSTATUS.simstatus.modify(|_r, w| w.success().bit(pass));
}
