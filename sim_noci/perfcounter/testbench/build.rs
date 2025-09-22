use std::process::Command;
use std::env;
use std::{path::{Path, PathBuf}};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut svd2utra_path = project_root();
    svd2utra_path.push("..");
    svd2utra_path.push("..");
    svd2utra_path.push("sim_support");
    svd2utra_path.push("rust");
    svd2utra_path.push("utralib");
    println!("{}", svd2utra_path.display());
    let target = if cfg!(target_os = "linux") {
        "i686-unknown-linux-gnu"
    } else if cfg!(target_os = "windows") {
        "x86_64-pc-windows-msvc"
    } else {
        panic!("unsupported host target for simulation");
        // the resolution to this could be as simple as just adding the target here.
    };
    let status = Command::new(cargo())
        .current_dir(svd2utra_path)
        .args(&[
            "build",
            "--target",
            target,
        ])
        .status()?;
    if !status.success() {
        return Err("cargo build failed".into());
    }

    Ok(())
}

fn cargo() -> String {
    env::var("CARGO").unwrap_or_else(|_| "cargo".to_string())
}

fn project_root() -> PathBuf {
    Path::new(&env!("CARGO_MANIFEST_DIR"))
        .ancestors()
        .nth(1)
        .unwrap()
        .to_path_buf()
}
