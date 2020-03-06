#![no_std]
#![no_main]

use sim_bios::sim_test;

// allocate a global, unsafe static string for debug output
#[used] // This is necessary to keep DBGSTR from being optimized out
static mut DBGSTR: [u32; 8] = [0, 0, 0, 0, 0, 0, 0, 0];

const FB_WIDTH_WORDS: usize = 11;
const FB_WIDTH_PIXELS: usize = 336;
const FB_LINES: usize = 536;
const FB_SIZE: usize = FB_WIDTH_WORDS * FB_LINES; // 44 bytes by 536 lines
const LCD_FB: *mut [u32; FB_SIZE] = 0xB000_0000 as *mut [u32; FB_SIZE];

fn lcd_clear(p: &pac::Peripherals) {
    unsafe{ p.MEMLCD.prescaler.write(|w| w.bits(49)); }

    for row in 0..536 {
        for col in 0..11 {
            unsafe {
                (*LCD_FB)[row * 11 + col] = 0xffff_ffff;
            }
        }
    }

    p.MEMLCD.command.write(|w| w.update_dirty().bit(true));
    while p.MEMLCD.busy.read().bits() != 0 { }

    for row in 0..536 {
        unsafe{
            (*LCD_FB)[ row * 11 + 10 ] = 0xffff;
        }
    }
}

fn lcd_animate(p: &pac::Peripherals) {
    let mut offset: usize = 0;

    for row in 100..105 {
        for col in 0..11 {
            unsafe {
                match offset % 4 {
                    0 => (*LCD_FB)[ row * 11 + col ] = 0xc003_c003,
                    1 => (*LCD_FB)[ row * 11 + col ] = 0x3c00_3c00,
                    2 => (*LCD_FB)[ row * 11 + col ] = 0x03c0_03c0,
                    3 => (*LCD_FB)[ row * 11 + col ] = 0x003c_003c,
                    _ => (),
                }
            }
            offset += 1;
            p.MEMLCD.command.write(|w| w.update_dirty().bit(true));
            while p.MEMLCD.busy.read().bits() != 0 { }
        }
    }
}

#[sim_test]
fn run(p: &pac::Peripherals) {

    unsafe{ p.MEMLCD.prescaler.write(|w| w.bits(49)); }  // 2 MHz clock (top speed allowed)
    unsafe {
        (*LCD_FB)[535*11 + 10] = 0x10001; // set dirty bit on the last line
        (*LCD_FB)[535*11] = 0x1111face; // put at the beginning of the last line

        // some data on the first line too
        (*LCD_FB)[10] = 0x0700_6006;
        (*LCD_FB)[0] = 0x8000_0001;
        (*LCD_FB)[1] = 0x4000_0002;
    }
    // this test set will cause the system to write just the first line and last line,
    // and skip through everything else in the middle
    p.MEMLCD.command.write(|w| w.update_dirty().bit(true));

    let mut timer: u32 = 0;
    while p.MEMLCD.busy.read().bits() != 0 { timer += 1; }
    
    unsafe{ p.SIMSTATUS.report.write( |w| w.bits(timer)); }
    unsafe{ p.SIMSTATUS.simstatus.write(|w| w.success().bit(true)); }

    // uncomment for manual checking of further behavior
    // lcd_clear(&p);
    // lcd_animate(&p);
}
