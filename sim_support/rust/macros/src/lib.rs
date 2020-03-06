extern crate proc_macro;
extern crate rand;
#[macro_use]
extern crate quote;
extern crate core;
extern crate proc_macro2;
#[macro_use]
extern crate syn;

extern crate pac;

use proc_macro2::Span;
use rand::Rng;
use rand::SeedableRng;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::time::{SystemTime, UNIX_EPOCH};
use syn::{parse, spanned::Spanned, Ident, ItemFn, ReturnType, Type, Visibility};

static CALL_COUNT: AtomicUsize = AtomicUsize::new(0);

use proc_macro::TokenStream;
#[proc_macro_attribute]
pub fn sim_test(args: TokenStream, input: TokenStream) -> TokenStream {
    let f = parse_macro_input!(input as ItemFn);

    // check the function signature
    let valid_signature = f.constness.is_none()
        && f.vis == Visibility::Inherited
        && f.abi.is_none()
        && f.decl.inputs.len() == 1
        && f.decl.generics.params.is_empty()
        && f.decl.generics.where_clause.is_none()
        && f.decl.variadic.is_none()
        && match f.decl.output {
            ReturnType::Default => true,
            ReturnType::Type(_, ref ty) => match **ty {
                Type::Never(_) => false,
                _ => false,
            },
        };

    if !valid_signature {
        return parse::Error::new(
            f.span(),
           "`#[sim_test]` function must have signature `[unsafe] fn(p: &pac::Peripherals) -> !`"
        //    format!("`#[sim_test]` function must have signature `[unsafe] fn(p: &pac::Peripherals) -> !`\n{:?}", f.decl.inputs[0])
        )
        .to_compile_error()
        .into();
    }

    if !args.is_empty() {
        return parse::Error::new(Span::call_site(), "This attribute accepts no arguments")
            .to_compile_error()
            .into();
    }

    // XXX should we blacklist other attributes?
    let attrs = f.attrs;
    let unsafety = f.unsafety;
    let hash = random_ident();
    let stmts = f.block.stmts;

    quote!(
        use core::panic::PanicInfo;
        #[panic_handler]
        pub fn panic(_panic_info: &PanicInfo<'_>) -> ! {
            unsafe{ pac::Peripherals::steal().SIMSTATUS.report.write(|w| w.bits(0xC0DE_DEAD)); }
            unsafe{ pac::Peripherals::steal().SIMSTATUS.simstatus.write(|w| w.success().bit(false).done().bit(true)); }
            loop {}
        }

        #[export_name = "run_test"]
        #(#attrs)*
        pub #unsafety fn #hash(p: &pac::Peripherals) {
            #(#stmts)*
        }
    )
    .into()
}

// Creates a random identifier
fn random_ident() -> Ident {
    let secs = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs();

    let count: u64 = CALL_COUNT.fetch_add(1, Ordering::SeqCst) as u64;
    let mut seed: [u8; 16] = [0; 16];

    for (i, v) in seed.iter_mut().take(8).enumerate() {
        *v = ((secs >> (i * 8)) & 0xFF) as u8
    }

    for (i, v) in seed.iter_mut().skip(8).enumerate() {
        *v = ((count >> (i * 8)) & 0xFF) as u8
    }

    let mut rng = rand::rngs::SmallRng::from_seed(seed);
    Ident::new(
        &(0..16)
            .map(|i| {
                if i == 0 || rng.gen() {
                    ('a' as u8 + rng.gen::<u8>() % 25) as char
                } else {
                    ('0' as u8 + rng.gen::<u8>() % 10) as char
                }
            })
            .collect::<String>(),
        Span::call_site(),
    )
}
