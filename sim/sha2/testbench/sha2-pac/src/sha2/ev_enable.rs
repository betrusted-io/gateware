# [ doc = "Reader of register EV_ENABLE" ] pub type R = crate :: R < u32 , super :: EV_ENABLE > ; # [ doc = "Writer for register EV_ENABLE" ] pub type W = crate :: W < u32 , super :: EV_ENABLE > ; # [ doc = "Register EV_ENABLE `reset()`'s with value 0" ] impl crate :: ResetValue for super :: EV_ENABLE { type Type = u32 ; # [ inline ( always ) ] fn reset_value ( ) -> Self :: Type { 0 } } # [ doc = "Reader of field `err_valid`" ] pub type ERR_VALID_R = crate :: R < bool , bool > ; # [ doc = "Write proxy for field `err_valid`" ] pub struct ERR_VALID_W < 'a > { w : & 'a mut W , } impl < 'a > ERR_VALID_W < 'a > { # [ doc = r"Sets the field bit" ] # [ inline ( always ) ] pub fn set_bit ( self ) -> & 'a mut W { self . bit ( true ) } # [ doc = r"Clears the field bit" ] # [ inline ( always ) ] pub fn clear_bit ( self ) -> & 'a mut W { self . bit ( false ) } # [ doc = r"Writes raw bits to the field" ] # [ inline ( always ) ] pub fn bit ( self , value : bool ) -> & 'a mut W { self . w . bits = ( self . w . bits & ! 0x01 ) | ( ( value as u32 ) & 0x01 ) ; self . w } } # [ doc = "Reader of field `fifo_full`" ] pub type FIFO_FULL_R = crate :: R < bool , bool > ; # [ doc = "Write proxy for field `fifo_full`" ] pub struct FIFO_FULL_W < 'a > { w : & 'a mut W , } impl < 'a > FIFO_FULL_W < 'a > { # [ doc = r"Sets the field bit" ] # [ inline ( always ) ] pub fn set_bit ( self ) -> & 'a mut W { self . bit ( true ) } # [ doc = r"Clears the field bit" ] # [ inline ( always ) ] pub fn clear_bit ( self ) -> & 'a mut W { self . bit ( false ) } # [ doc = r"Writes raw bits to the field" ] # [ inline ( always ) ] pub fn bit ( self , value : bool ) -> & 'a mut W { self . w . bits = ( self . w . bits & ! ( 0x01 << 1 ) ) | ( ( ( value as u32 ) & 0x01 ) << 1 ) ; self . w } } # [ doc = "Reader of field `hash_done`" ] pub type HASH_DONE_R = crate :: R < bool , bool > ; # [ doc = "Write proxy for field `hash_done`" ] pub struct HASH_DONE_W < 'a > { w : & 'a mut W , } impl < 'a > HASH_DONE_W < 'a > { # [ doc = r"Sets the field bit" ] # [ inline ( always ) ] pub fn set_bit ( self ) -> & 'a mut W { self . bit ( true ) } # [ doc = r"Clears the field bit" ] # [ inline ( always ) ] pub fn clear_bit ( self ) -> & 'a mut W { self . bit ( false ) } # [ doc = r"Writes raw bits to the field" ] # [ inline ( always ) ] pub fn bit ( self , value : bool ) -> & 'a mut W { self . w . bits = ( self . w . bits & ! ( 0x01 << 2 ) ) | ( ( ( value as u32 ) & 0x01 ) << 2 ) ; self . w } } # [ doc = "Reader of field `sha256_done`" ] pub type SHA256_DONE_R = crate :: R < bool , bool > ; # [ doc = "Write proxy for field `sha256_done`" ] pub struct SHA256_DONE_W < 'a > { w : & 'a mut W , } impl < 'a > SHA256_DONE_W < 'a > { # [ doc = r"Sets the field bit" ] # [ inline ( always ) ] pub fn set_bit ( self ) -> & 'a mut W { self . bit ( true ) } # [ doc = r"Clears the field bit" ] # [ inline ( always ) ] pub fn clear_bit ( self ) -> & 'a mut W { self . bit ( false ) } # [ doc = r"Writes raw bits to the field" ] # [ inline ( always ) ] pub fn bit ( self , value : bool ) -> & 'a mut W { self . w . bits = ( self . w . bits & ! ( 0x01 << 3 ) ) | ( ( ( value as u32 ) & 0x01 ) << 3 ) ; self . w } } impl R { # [ doc = "Bit 0 - Write a ``1`` to enable the ``err_valid`` Event" ] # [ inline ( always ) ] pub fn err_valid ( & self ) -> ERR_VALID_R { ERR_VALID_R :: new ( ( self . bits & 0x01 ) != 0 ) } # [ doc = "Bit 1 - Write a ``1`` to enable the ``fifo_full`` Event" ] # [ inline ( always ) ] pub fn fifo_full ( & self ) -> FIFO_FULL_R { FIFO_FULL_R :: new ( ( ( self . bits >> 1 ) & 0x01 ) != 0 ) } # [ doc = "Bit 2 - Write a ``1`` to enable the ``hash_done`` Event" ] # [ inline ( always ) ] pub fn hash_done ( & self ) -> HASH_DONE_R { HASH_DONE_R :: new ( ( ( self . bits >> 2 ) & 0x01 ) != 0 ) } # [ doc = "Bit 3 - Write a ``1`` to enable the ``sha256_done`` Event" ] # [ inline ( always ) ] pub fn sha256_done ( & self ) -> SHA256_DONE_R { SHA256_DONE_R :: new ( ( ( self . bits >> 3 ) & 0x01 ) != 0 ) } } impl W { # [ doc = "Bit 0 - Write a ``1`` to enable the ``err_valid`` Event" ] # [ inline ( always ) ] pub fn err_valid ( & mut self ) -> ERR_VALID_W { ERR_VALID_W { w : self } } # [ doc = "Bit 1 - Write a ``1`` to enable the ``fifo_full`` Event" ] # [ inline ( always ) ] pub fn fifo_full ( & mut self ) -> FIFO_FULL_W { FIFO_FULL_W { w : self } } # [ doc = "Bit 2 - Write a ``1`` to enable the ``hash_done`` Event" ] # [ inline ( always ) ] pub fn hash_done ( & mut self ) -> HASH_DONE_W { HASH_DONE_W { w : self } } # [ doc = "Bit 3 - Write a ``1`` to enable the ``sha256_done`` Event" ] # [ inline ( always ) ] pub fn sha256_done ( & mut self ) -> SHA256_DONE_W { SHA256_DONE_W { w : self } } }