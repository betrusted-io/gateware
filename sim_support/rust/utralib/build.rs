use std::env;
use std::{path::{Path, PathBuf}};

fn main() {
    let mut svd_filename = project_root();
    svd_filename.push("..");
    svd_filename.push("..");
    svd_filename.push("target");
    svd_filename.push("soc.svd");

    let svd_file_path = std::path::Path::new(&svd_filename);
    println!("cargo:rerun-if-changed={}", svd_file_path.canonicalize().unwrap().display());

    let src_file = std::fs::File::open(svd_filename).expect("couldn't open src file");
    let mut dest_file = std::fs::File::create("src/generated.rs").expect("couldn't open dest file");
    svd2utra::generate(src_file, &mut dest_file).unwrap();
}

fn project_root() -> PathBuf {
    Path::new(&env!("CARGO_MANIFEST_DIR"))
        .ancestors()
        .nth(1)
        .unwrap()
        .to_path_buf()
}
