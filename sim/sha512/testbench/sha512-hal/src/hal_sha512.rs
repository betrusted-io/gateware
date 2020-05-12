use bitflags::*;
use volatile::Volatile;

bitflags! {
    pub struct Sha512Config: u32 {
        const NONE        = 0b0000_0000;
        const SHA512_EN   = 0b0000_0001;
        const ENDIAN_SWAP = 0b0000_0010;
        const DIGEST_SWAP = 0b0000_0100;
    }
}

bitflags! {
    pub struct Sha512Command: u32 {
        const HASH_START  = 0b0000_0001;
        const HASH_DIGEST = 0b0000_0010;
    }
}

bitflags! {
    pub struct Sha512Status: u32 {
        const DONE = 0b0000_0001;
    }
}

bitflags! {
    pub struct Sha512Fifo: u32 {
        const READ_COUNT_MASK  = 0b0000_0000_0000_0011_1111;
        const WRITE_COUNT_MASK = 0b0000_1111_1111_1100_0000;
        const READ_ERROR       = 0b0001_0000_0000_0000_0000;
        const WRITE_ERROR      = 0b0010_0000_0000_0000_0000;
        const ALMOST_FULL      = 0b0100_0000_0000_0000_0000;
        const ALMOST_EMPTY     = 0b1000_0000_0000_0000_0000;
    }
}

bitflags! {
    pub struct Sha512Event: u32 {
        const ERROR       = 0b0001;
        const FIFO_FULL   = 0b0010;
        const SHA512_DONE = 0b0100;
    }
}

pub struct BtSha512 {
    p: sha512_pac::Peripherals,
    pub config: Sha512Config,
}

impl BtSha512 {
    pub fn new() -> Self {
        unsafe {
            BtSha512 {
                p: sha512_pac::Peripherals::steal(),
                config: Sha512Config::NONE,
            }
        }
    }

    pub fn init(&mut self) -> bool {
        unsafe{ self.p.SHA512.config.write(|w|{ w.bits(self.config.bits()) }); }
        self.p.SHA512.command.write(|w|{ w.hash_start().set_bit() });
        true
    }

    pub fn update(&mut self, data: &[u8]) {
        let sha_ptr: *mut u32 = 0xe0002000 as *mut u32;
        let sha = sha_ptr as *mut Volatile<u32>;
        let sha_byte_ptr: *mut u8 = 0xe0002000 as *mut u8;
        let sha_byte = sha_byte_ptr as *mut Volatile<u8>;

        for (_reg, chunk) in data.chunks(8).enumerate() {
            let mut temp: [u8; 8] = Default::default();
            if chunk.len() == 8 {
                temp.copy_from_slice(chunk);
                let dword: u64 = u64::from_le_bytes(temp);

                while self.p.SHA512.fifo.read().almost_full().bit() {}
                unsafe { (*sha.add(1)).write((dword >> 32) as u32); }
                unsafe { (*sha).write(dword as u32); }
            } else {
                for index in 0..chunk.len() {
                    while self.p.SHA512.fifo.read().almost_full().bit() {}
                    unsafe{ (*sha_byte).write(chunk[index]); }
                }
            }
        }
    }

    pub fn digest(&mut self, digest: &mut [u64; 8]) {
        self.p.SHA512.command.write(|w|{ w.hash_process().set_bit()});
        while (self.p.SHA512.ev_pending.read().bits() & (Sha512Event::SHA512_DONE).bits()) == 0 {}
        unsafe{ self.p.SHA512.ev_pending.write(|w| w.bits((Sha512Event::SHA512_DONE).bits()) ); }

        for reg in 0..8 {
            match reg {
                0 => digest[reg] = self.p.SHA512.digest00.read().bits() as u64 | (self.p.SHA512.digest01.read().bits() as u64) << 32,
                1 => digest[reg] = self.p.SHA512.digest10.read().bits() as u64 | (self.p.SHA512.digest11.read().bits() as u64) << 32,
                2 => digest[reg] = self.p.SHA512.digest20.read().bits() as u64 | (self.p.SHA512.digest21.read().bits() as u64) << 32,
                3 => digest[reg] = self.p.SHA512.digest30.read().bits() as u64 | (self.p.SHA512.digest31.read().bits() as u64) << 32,
                4 => digest[reg] = self.p.SHA512.digest40.read().bits() as u64 | (self.p.SHA512.digest41.read().bits() as u64) << 32,
                5 => digest[reg] = self.p.SHA512.digest50.read().bits() as u64 | (self.p.SHA512.digest51.read().bits() as u64) << 32,
                6 => digest[reg] = self.p.SHA512.digest60.read().bits() as u64 | (self.p.SHA512.digest61.read().bits() as u64) << 32,
                7 => digest[reg] = self.p.SHA512.digest70.read().bits() as u64 | (self.p.SHA512.digest71.read().bits() as u64) << 32,
                _ => assert!(false),
            }
        }
    }
}
