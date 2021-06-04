# [ doc = "Reader of register XOVER_EV_ENABLE" ] pub type R = crate :: R < u32 , super :: XOVER_EV_ENABLE > ; # [ doc = "Writer for register XOVER_EV_ENABLE" ] pub type W = crate :: W < u32 , super :: XOVER_EV_ENABLE > ; # [ doc = "Register XOVER_EV_ENABLE `reset()`'s with value 0" ] impl crate :: ResetValue for super :: XOVER_EV_ENABLE { type Type = u32 ; # [ inline ( always ) ] fn reset_value ( ) -> Self :: Type { 0 } } # [ doc = "Reader of field `xover_ev_enable`" ] pub type XOVER_EV_ENABLE_R = crate :: R < u8 , u8 > ; # [ doc = "Write proxy for field `xover_ev_enable`" ] pub struct XOVER_EV_ENABLE_W < 'a > { w : & 'a mut W , } impl < 'a > XOVER_EV_ENABLE_W < 'a > { # [ doc = r"Writes raw bits to the field" ] # [ inline ( always ) ] pub unsafe fn bits ( self , value : u8 ) -> & 'a mut W { self . w . bits = ( self . w . bits & ! 0x03 ) | ( ( value as u32 ) & 0x03 ) ; self . w } } impl R { # [ doc = "Bits 0:1" ] # [ inline ( always ) ] pub fn xover_ev_enable ( & self ) -> XOVER_EV_ENABLE_R { XOVER_EV_ENABLE_R :: new ( ( self . bits & 0x03 ) as u8 ) } } impl W { # [ doc = "Bits 0:1" ] # [ inline ( always ) ] pub fn xover_ev_enable ( & mut self ) -> XOVER_EV_ENABLE_W { XOVER_EV_ENABLE_W { w : self } } }