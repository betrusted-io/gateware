#![cfg_attr(not(test), no_std)]

extern crate bitflags;
extern crate volatile;
extern crate digest;

pub mod hal_sha512;

#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        assert_eq!(2 + 2, 4);
    }
}
