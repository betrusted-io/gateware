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
    let status = Command::new(cargo())
        .current_dir(svd2utra_path)
        .args(&[
            "build",
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
