# [ doc = "Reader of register TRIGGER" ] pub type R = crate :: R < u32 , super :: TRIGGER > ; # [ doc = "Writer for register TRIGGER" ] pub type W = crate :: W < u32 , super :: TRIGGER > ; # [ doc = "Register TRIGGER `reset()`'s with value 0" ] impl crate :: ResetValue for super :: TRIGGER { type Type = u32 ; # [ inline ( always ) ] fn reset_value ( ) -> Self :: Type { 0 } } # [ doc = "Reader of field `start`" ] pub type START_R = crate :: R < bool , bool > ; # [ doc = "Write proxy for field `start`" ] pub struct START_W < 'a > { w : & 'a mut W , } impl < 'a > START_W < 'a > { # [ doc = r"Sets the field bit" ] # [ inline ( always ) ] pub fn set_bit ( self ) -> & 'a mut W { self . bit ( true ) } # [ doc = r"Clears the field bit" ] # [ inline ( always ) ] pub fn clear_bit ( self ) -> & 'a mut W { self . bit ( false ) } # [ doc = r"Writes raw bits to the field" ] # [ inline ( always ) ] pub fn bit ( self , value : bool ) -> & 'a mut W { self . w . bits = ( self . w . bits & ! 0x01 ) | ( ( value as u32 ) & 0x01 ) ; self . w } } # [ doc = "Reader of field `key_clear`" ] pub type KEY_CLEAR_R = crate :: R < bool , bool > ; # [ doc = "Write proxy for field `key_clear`" ] pub struct KEY_CLEAR_W < 'a > { w : & 'a mut W , } impl < 'a > KEY_CLEAR_W < 'a > { # [ doc = r"Sets the field bit" ] # [ inline ( always ) ] pub fn set_bit ( self ) -> & 'a mut W { self . bit ( true ) } # [ doc = r"Clears the field bit" ] # [ inline ( always ) ] pub fn clear_bit ( self ) -> & 'a mut W { self . bit ( false ) } # [ doc = r"Writes raw bits to the field" ] # [ inline ( always ) ] pub fn bit ( self , value : bool ) -> & 'a mut W { self . w . bits = ( self . w . bits & ! ( 0x01 << 1 ) ) | ( ( ( value as u32 ) & 0x01 ) << 1 ) ; self . w } } # [ doc = "Reader of field `iv_clear`" ] pub type IV_CLEAR_R = crate :: R < bool , bool > ; # [ doc = "Write proxy for field `iv_clear`" ] pub struct IV_CLEAR_W < 'a > { w : & 'a mut W , } impl < 'a > IV_CLEAR_W < 'a > { # [ doc = r"Sets the field bit" ] # [ inline ( always ) ] pub fn set_bit ( self ) -> & 'a mut W { self . bit ( true ) } # [ doc = r"Clears the field bit" ] # [ inline ( always ) ] pub fn clear_bit ( self ) -> & 'a mut W { self . bit ( false ) } # [ doc = r"Writes raw bits to the field" ] # [ inline ( always ) ] pub fn bit ( self , value : bool ) -> & 'a mut W { self . w . bits = ( self . w . bits & ! ( 0x01 << 2 ) ) | ( ( ( value as u32 ) & 0x01 ) << 2 ) ; self . w } } # [ doc = "Reader of field `data_in_clear`" ] pub type DATA_IN_CLEAR_R = crate :: R < bool , bool > ; # [ doc = "Write proxy for field `data_in_clear`" ] pub struct DATA_IN_CLEAR_W < 'a > { w : & 'a mut W , } impl < 'a > DATA_IN_CLEAR_W < 'a > { # [ doc = r"Sets the field bit" ] # [ inline ( always ) ] pub fn set_bit ( self ) -> & 'a mut W { self . bit ( true ) } # [ doc = r"Clears the field bit" ] # [ inline ( always ) ] pub fn clear_bit ( self ) -> & 'a mut W { self . bit ( false ) } # [ doc = r"Writes raw bits to the field" ] # [ inline ( always ) ] pub fn bit ( self , value : bool ) -> & 'a mut W { self . w . bits = ( self . w . bits & ! ( 0x01 << 3 ) ) | ( ( ( value as u32 ) & 0x01 ) << 3 ) ; self . w } } # [ doc = "Reader of field `data_out_clear`" ] pub type DATA_OUT_CLEAR_R = crate :: R < bool , bool > ; # [ doc = "Write proxy for field `data_out_clear`" ] pub struct DATA_OUT_CLEAR_W < 'a > { w : & 'a mut W , } impl < 'a > DATA_OUT_CLEAR_W < 'a > { # [ doc = r"Sets the field bit" ] # [ inline ( always ) ] pub fn set_bit ( self ) -> & 'a mut W { self . bit ( true ) } # [ doc = r"Clears the field bit" ] # [ inline ( always ) ] pub fn clear_bit ( self ) -> & 'a mut W { self . bit ( false ) } # [ doc = r"Writes raw bits to the field" ] # [ inline ( always ) ] pub fn bit ( self , value : bool ) -> & 'a mut W { self . w . bits = ( self . w . bits & ! ( 0x01 << 4 ) ) | ( ( ( value as u32 ) & 0x01 ) << 4 ) ; self . w } } # [ doc = "Reader of field `prng_reseed`" ] pub type PRNG_RESEED_R = crate :: R < bool , bool > ; # [ doc = "Write proxy for field `prng_reseed`" ] pub struct PRNG_RESEED_W < 'a > { w : & 'a mut W , } impl < 'a > PRNG_RESEED_W < 'a > { # [ doc = r"Sets the field bit" ] # [ inline ( always ) ] pub fn set_bit ( self ) -> & 'a mut W { self . bit ( true ) } # [ doc = r"Clears the field bit" ] # [ inline ( always ) ] pub fn clear_bit ( self ) -> & 'a mut W { self . bit ( false ) } # [ doc = r"Writes raw bits to the field" ] # [ inline ( always ) ] pub fn bit ( self , value : bool ) -> & 'a mut W { self . w . bits = ( self . w . bits & ! ( 0x01 << 5 ) ) | ( ( ( value as u32 ) & 0x01 ) << 5 ) ; self . w } } impl R { # [ doc = "Bit 0 - Triggers an AES computation if manual_start is selected" ] # [ inline ( always ) ] pub fn start ( & self ) -> START_R { START_R :: new ( ( self . bits & 0x01 ) != 0 ) } # [ doc = "Bit 1 - Clears the key" ] # [ inline ( always ) ] pub fn key_clear ( & self ) -> KEY_CLEAR_R { KEY_CLEAR_R :: new ( ( ( self . bits >> 1 ) & 0x01 ) != 0 ) } # [ doc = "Bit 2 - Clears the IV" ] # [ inline ( always ) ] pub fn iv_clear ( & self ) -> IV_CLEAR_R { IV_CLEAR_R :: new ( ( ( self . bits >> 2 ) & 0x01 ) != 0 ) } # [ doc = "Bit 3 - Clears data input" ] # [ inline ( always ) ] pub fn data_in_clear ( & self ) -> DATA_IN_CLEAR_R { DATA_IN_CLEAR_R :: new ( ( ( self . bits >> 3 ) & 0x01 ) != 0 ) } # [ doc = "Bit 4 - Clears the data output" ] # [ inline ( always ) ] pub fn data_out_clear ( & self ) -> DATA_OUT_CLEAR_R { DATA_OUT_CLEAR_R :: new ( ( ( self . bits >> 4 ) & 0x01 ) != 0 ) } # [ doc = "Bit 5 - Reseed PRNG" ] # [ inline ( always ) ] pub fn prng_reseed ( & self ) -> PRNG_RESEED_R { PRNG_RESEED_R :: new ( ( ( self . bits >> 5 ) & 0x01 ) != 0 ) } } impl W { # [ doc = "Bit 0 - Triggers an AES computation if manual_start is selected" ] # [ inline ( always ) ] pub fn start ( & mut self ) -> START_W { START_W { w : self } } # [ doc = "Bit 1 - Clears the key" ] # [ inline ( always ) ] pub fn key_clear ( & mut self ) -> KEY_CLEAR_W { KEY_CLEAR_W { w : self } } # [ doc = "Bit 2 - Clears the IV" ] # [ inline ( always ) ] pub fn iv_clear ( & mut self ) -> IV_CLEAR_W { IV_CLEAR_W { w : self } } # [ doc = "Bit 3 - Clears data input" ] # [ inline ( always ) ] pub fn data_in_clear ( & mut self ) -> DATA_IN_CLEAR_W { DATA_IN_CLEAR_W { w : self } } # [ doc = "Bit 4 - Clears the data output" ] # [ inline ( always ) ] pub fn data_out_clear ( & mut self ) -> DATA_OUT_CLEAR_W { DATA_OUT_CLEAR_W { w : self } } # [ doc = "Bit 5 - Reseed PRNG" ] # [ inline ( always ) ] pub fn prng_reseed ( & mut self ) -> PRNG_RESEED_W { PRNG_RESEED_W { w : self } } }