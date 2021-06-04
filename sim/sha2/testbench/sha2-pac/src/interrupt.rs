# [ doc = r"Enumeration of all the interrupts" ] # [ derive ( Copy , Clone , Debug ) ] pub enum Interrupt { # [ doc = "0 - uart" ] UART , # [ doc = "1 - timer0" ] TIMER0 , # [ doc = "2 - sha2" ] SHA2 , } unsafe impl bare_metal :: Nr for Interrupt { # [ inline ] fn nr ( & self ) -> u8 { match * self { Interrupt :: UART => 0 , Interrupt :: TIMER0 => 1 , Interrupt :: SHA2 => 2 , } } } # [ derive ( Debug , Copy , Clone ) ] pub struct TryFromInterruptError ( ( ) ) ; impl Interrupt { # [ inline ] pub fn try_from ( value : u8 ) -> Result < Self , TryFromInterruptError > { match value { 0 => Ok ( Interrupt :: UART ) , 1 => Ok ( Interrupt :: TIMER0 ) , 2 => Ok ( Interrupt :: SHA2 ) , _ => Err ( TryFromInterruptError ( ( ) ) ) , } } } # [ cfg ( feature = "rt" ) ] # [ macro_export ] # [ doc = r" Assigns a handler to an interrupt" ] # [ doc = r"" ] # [ doc = r" This macro takes two arguments: the name of an interrupt and the path to the" ] # [ doc = r" function that will be used as the handler of that interrupt. That function" ] # [ doc = r" must have signature `fn()`." ] # [ doc = r"" ] # [ doc = r" Optionally, a third argument may be used to declare interrupt local data." ] # [ doc = r" The handler will have exclusive access to these *local* variables on each" ] # [ doc = r" invocation. If the third argument is used then the signature of the handler" ] # [ doc = r" function must be `fn(&mut $NAME::Locals)` where `$NAME` is the first argument" ] # [ doc = r" passed to the macro." ] # [ doc = r"" ] # [ doc = r" # Example" ] # [ doc = r"" ] # [ doc = r" ``` ignore" ] # [ doc = r" interrupt!(TIM2, periodic);" ] # [ doc = r"" ] # [ doc = r" fn periodic() {" ] # [ doc = r#"     print!(".");"# ] # [ doc = r" }" ] # [ doc = r"" ] # [ doc = r" interrupt!(TIM3, tick, locals: {" ] # [ doc = r"     tick: bool = false;" ] # [ doc = r" });" ] # [ doc = r"" ] # [ doc = r" fn tick(locals: &mut TIM3::Locals) {" ] # [ doc = r"     locals.tick = !locals.tick;" ] # [ doc = r"" ] # [ doc = r"     if locals.tick {" ] # [ doc = r#"         println!("Tick");"# ] # [ doc = r"     } else {" ] # [ doc = r#"         println!("Tock");"# ] # [ doc = r"     }" ] # [ doc = r" }" ] # [ doc = r" ```" ] macro_rules ! interrupt { ( $ NAME : ident , $ path : path , locals : { $ ( $ lvar : ident : $ lty : ty = $ lval : expr ; ) * } ) => { # [ allow ( non_snake_case ) ] mod $ NAME { pub struct Locals { $ ( pub $ lvar : $ lty , ) * } } # [ allow ( non_snake_case ) ] # [ no_mangle ] pub extern "C" fn $ NAME ( ) { let _ = $ crate :: interrupt :: Interrupt :: $ NAME ; static mut LOCALS : self :: $ NAME :: Locals = self :: $ NAME :: Locals { $ ( $ lvar : $ lval , ) * } ; let f : fn ( & mut self :: $ NAME :: Locals ) = $ path ; f ( unsafe { & mut LOCALS } ) ; } } ; ( $ NAME : ident , $ path : path ) => { # [ allow ( non_snake_case ) ] # [ no_mangle ] pub extern "C" fn $ NAME ( ) { let _ = $ crate :: interrupt :: Interrupt :: $ NAME ; let f : fn ( ) = $ path ; f ( ) ; } } }