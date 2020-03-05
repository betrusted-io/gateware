use std::{env, fs};
use std::path::PathBuf;
use std::io::Write;

fn main() {
    // Put the linker script somewhere the linker can find it
    let out_dir = PathBuf::from(env::var("OUT_DIR").unwrap());
    println!("cargo:rustc-link-search={}", out_dir.display());

    let boot_type: &'static str = env!["BOOT_TYPE", "BOOT_TYPE environment variable must be set to either ROM or SPI"];

    if boot_type == "ROM" {
        fs::File::create(out_dir.join("memory.x")).unwrap()
            .write_all(include_bytes!("memory_rom.x")).unwrap();
        println!("cargo:rerun-if-changed=memory.x");
    } else if boot_type == "SPI" {
        fs::File::create(out_dir.join("memory.x")).unwrap()
            .write_all(include_bytes!("memory_spi.x")).unwrap();
        println!("cargo:rerun-if-changed=memory.x");
    } else {
        panic!("BOOT_TYPE environment variable must be set to either ROM or SPI");
    }
}