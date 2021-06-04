# [ doc = "Reader of register DIGEST71" ] pub type R = crate :: R < u32 , super :: DIGEST71 > ; # [ doc = "Writer for register DIGEST71" ] pub type W = crate :: W < u32 , super :: DIGEST71 > ; # [ doc = "Register DIGEST71 `reset()`'s with value 0" ] impl crate :: ResetValue for super :: DIGEST71 { type Type = u32 ; # [ inline ( always ) ] fn reset_value ( ) -> Self :: Type { 0 } } # [ doc = "Reader of field `digest7`" ] pub type DIGEST7_R = crate :: R < u32 , u32 > ; # [ doc = "Write proxy for field `digest7`" ] pub struct DIGEST7_W < 'a > { w : & 'a mut W , } impl < 'a > DIGEST7_W < 'a > { # [ doc = r"Writes raw bits to the field" ] # [ inline ( always ) ] pub unsafe fn bits ( self , value : u32 ) -> & 'a mut W { self . w . bits = ( self . w . bits & ! 0xffff_ffff ) | ( ( value as u32 ) & 0xffff_ffff ) ; self . w } } impl R { # [ doc = "Bits 0:31" ] # [ inline ( always ) ] pub fn digest7 ( & self ) -> DIGEST7_R { DIGEST7_R :: new ( ( self . bits & 0xffff_ffff ) as u32 ) } } impl W { # [ doc = "Bits 0:31" ] # [ inline ( always ) ] pub fn digest7 ( & mut self ) -> DIGEST7_W { DIGEST7_W { w : self } } }