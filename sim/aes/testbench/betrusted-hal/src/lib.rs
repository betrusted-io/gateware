#![cfg_attr(not(test), no_std)]

extern crate bitflags;

pub mod hal_aes;

#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        assert_eq!(2 + 2, 4);
    }
}
