#![doc = "Peripheral access API for SIMULATION microcontrollers (generated using svd2rust v0.16.1)\n\nYou can find an overview of the API [here].\n\n[here]: https://docs.rs/svd2rust/0.16.1/svd2rust/#peripheral-api"]
#![deny(missing_docs)]
#![deny(warnings)]
#![allow(non_camel_case_types)]
#![no_std]
extern crate bare_metal;
extern crate riscv;
#[cfg(feature = "rt")]
extern crate riscv_rt;
extern crate vcell;
use core::marker::PhantomData;
use core::ops::Deref;
#[doc(hidden)]
pub mod interrupt;
pub use self::interrupt::Interrupt;
#[allow(unused_imports)]
use generic::*;
#[doc = r"Common register and bit access and modify traits"]
pub mod generic;
#[doc = "TIMER0"]
pub struct TIMER0 {
    _marker: PhantomData<*const ()>,
}
unsafe impl Send for TIMER0 {}
impl TIMER0 {
    #[doc = r"Returns a pointer to the register block"]
    #[inline(always)]
    pub const fn ptr() -> *const timer0::RegisterBlock {
        0x8200_5000 as *const _
    }
}
impl Deref for TIMER0 {
    type Target = timer0::RegisterBlock;
    fn deref(&self) -> &Self::Target {
        unsafe { &*TIMER0::ptr() }
    }
}
#[doc = "TIMER0"]
pub mod timer0;
#[doc = "DEMO"]
pub struct DEMO {
    _marker: PhantomData<*const ()>,
}
unsafe impl Send for DEMO {}
impl DEMO {
    #[doc = r"Returns a pointer to the register block"]
    #[inline(always)]
    pub const fn ptr() -> *const demo::RegisterBlock {
        0x8200_7000 as *const _
    }
}
impl Deref for DEMO {
    type Target = demo::RegisterBlock;
    fn deref(&self) -> &Self::Target {
        unsafe { &*DEMO::ptr() }
    }
}
#[doc = "DEMO"]
pub mod demo;
#[doc = "IDENTIFIER_MEM"]
pub struct IDENTIFIER_MEM {
    _marker: PhantomData<*const ()>,
}
unsafe impl Send for IDENTIFIER_MEM {}
impl IDENTIFIER_MEM {
    #[doc = r"Returns a pointer to the register block"]
    #[inline(always)]
    pub const fn ptr() -> *const identifier_mem::RegisterBlock {
        0x8200_2000 as *const _
    }
}
impl Deref for IDENTIFIER_MEM {
    type Target = identifier_mem::RegisterBlock;
    fn deref(&self) -> &Self::Target {
        unsafe { &*IDENTIFIER_MEM::ptr() }
    }
}
#[doc = "IDENTIFIER_MEM"]
pub mod identifier_mem;
#[doc = "CTRL"]
pub struct CTRL {
    _marker: PhantomData<*const ()>,
}
unsafe impl Send for CTRL {}
impl CTRL {
    #[doc = r"Returns a pointer to the register block"]
    #[inline(always)]
    pub const fn ptr() -> *const ctrl::RegisterBlock {
        0x8200_0000 as *const _
    }
}
impl Deref for CTRL {
    type Target = ctrl::RegisterBlock;
    fn deref(&self) -> &Self::Target {
        unsafe { &*CTRL::ptr() }
    }
}
#[doc = "CTRL"]
pub mod ctrl;
#[doc = "SIMSTATUS"]
pub struct SIMSTATUS {
    _marker: PhantomData<*const ()>,
}
unsafe impl Send for SIMSTATUS {}
impl SIMSTATUS {
    #[doc = r"Returns a pointer to the register block"]
    #[inline(always)]
    pub const fn ptr() -> *const simstatus::RegisterBlock {
        0x8200_6000 as *const _
    }
}
impl Deref for SIMSTATUS {
    type Target = simstatus::RegisterBlock;
    fn deref(&self) -> &Self::Target {
        unsafe { &*SIMSTATUS::ptr() }
    }
}
#[doc = "SIMSTATUS"]
pub mod simstatus;
#[doc = "UART"]
pub struct UART {
    _marker: PhantomData<*const ()>,
}
unsafe impl Send for UART {}
impl UART {
    #[doc = r"Returns a pointer to the register block"]
    #[inline(always)]
    pub const fn ptr() -> *const uart::RegisterBlock {
        0x8200_4000 as *const _
    }
}
impl Deref for UART {
    type Target = uart::RegisterBlock;
    fn deref(&self) -> &Self::Target {
        unsafe { &*UART::ptr() }
    }
}
#[doc = "UART"]
pub mod uart;
#[no_mangle]
static mut DEVICE_PERIPHERALS: bool = false;
#[doc = r"All the peripherals"]
#[allow(non_snake_case)]
pub struct Peripherals {
    #[doc = "TIMER0"]
    pub TIMER0: TIMER0,
    #[doc = "DEMO"]
    pub DEMO: DEMO,
    #[doc = "IDENTIFIER_MEM"]
    pub IDENTIFIER_MEM: IDENTIFIER_MEM,
    #[doc = "CTRL"]
    pub CTRL: CTRL,
    #[doc = "SIMSTATUS"]
    pub SIMSTATUS: SIMSTATUS,
    #[doc = "UART"]
    pub UART: UART,
}
impl Peripherals {
    #[doc = r"Returns all the peripherals *once*"]
    #[inline]
    pub fn take() -> Option<Self> {
        riscv::interrupt::free(|_| {
            if unsafe { DEVICE_PERIPHERALS } {
                None
            } else {
                Some(unsafe { Peripherals::steal() })
            }
        })
    }
    #[doc = r"Unchecked version of `Peripherals::take`"]
    pub unsafe fn steal() -> Self {
        DEVICE_PERIPHERALS = true;
        Peripherals {
            TIMER0: TIMER0 {
                _marker: PhantomData,
            },
            DEMO: DEMO {
                _marker: PhantomData,
            },
            IDENTIFIER_MEM: IDENTIFIER_MEM {
                _marker: PhantomData,
            },
            CTRL: CTRL {
                _marker: PhantomData,
            },
            SIMSTATUS: SIMSTATUS {
                _marker: PhantomData,
            },
            UART: UART {
                _marker: PhantomData,
            },
        }
    }
}
