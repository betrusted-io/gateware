#![no_std]
#![no_main]

use sim_bios::sim_test;

extern crate digest;
use digest::Digest;
extern crate sha512_hal;
use sha512_hal::hal_sha512::{Sha512, Sha512Trunc256};
use hkdf::*;

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
        let byte: u8 = (((K_EXPECTED_DIGEST[i / 8]) >> ((7 - (i % 8)) * 8)) & 0xff) as u8;
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

    //////// test Sha512Trunc256
    report(p, 0x1000_0005);
    let mut hasher256 = Sha512Trunc256::new();

    report(p, 0x1000_0006);

    for (_reg, chunk) in K_DATA.chunks(16).enumerate() {
        let mut temp: [u8; 16] = Default::default();
        if chunk.len() == 16 {
            temp.copy_from_slice(chunk);
            hasher256.update(temp);
        } else {
            for index in 0..chunk.len() {
                let lone_value: [u8; 1] = [chunk[index]];
                hasher256.update(&lone_value);
            }
        }
    }

    report(p, 0x1000_0007);
    let digest256 = hasher256.finalize();

    report(p, 0x1000_0008);
    for i in 0..32 {
        let byte: u8 = (((K_EXPECTED_DIGEST_256[i / 8]) >> ((7 - (i % 8)) * 8)) & 0xff) as u8;
        report(p, digest256[i] as u32);
        report(p, byte as u32);
        if digest256[i] != byte {
            pass = false;
        }
    }
    if pass {
        report(p, 0x1000_0009);
    } else {
        report(p, 0xDEAD_0009);
    }

    ////// test restart
    report(p, 0x1000_000A);
    let mut hasher = Sha512::new();

    report(p, 0x1000_000B);

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

    report(p, 0x1000_000C);
    let digest = hasher.finalize();

    report(p, 0x1000_000D);
    for i in 0..64 {
        let byte: u8 = (((K_EXPECTED_DIGEST[i / 8]) >> ((7 - (i % 8)) * 8)) & 0xff) as u8;
        report(p, digest[i] as u32);
        report(p, byte as u32);
        if digest[i] != byte {
            pass = false;
        }
    }
    if pass {
        report(p, 0x1000_000E);
    } else {
        report(p, 0xDEAD_000E);
    }

    ////// test length
    report(p, 0x1000_000F);
    let mut key = [0; 64];
    let info = b"foobar!";
    let salt: &[u8; 64] = &[0; 64];
    let ikm: &[u8; 32] = &[0x42; 32];

    let hkdf_obj = Hkdf::<Sha512>::new(Some(salt), ikm);

    report(p, 0x1000_0010);

    hkdf_obj.expand(&info[..], &mut key).unwrap();

    report(p, 0x1000_0011);

    // set success to indicate to the CI framework that the test has passed
    p.SIMSTATUS.simstatus.modify(|_r, w| w.success().bit(pass));
}
