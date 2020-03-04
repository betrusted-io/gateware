from migen import *
from migen.genlib.fsm import FSM, NextState

from litex.soc.interconnect import wishbone
from litex.soc.interconnect.csr import *
from litex.soc.interconnect.csr_eventmanager import *
from litex.soc.integration.doc import AutoDoc, ModuleDoc


class MemLCD(Module, AutoCSR):
    def __init__(self, pads):
        self.background = ModuleDoc("""MemLCD: Driver for the SHARP Memory LCD model LS032B7DD02

        The LS032B7DD02 is a 336x536 pixel black and white memory LCD, with a 200ppi dot pitch.
        Memory LCDs can be thought of as 'fast E-ink displays that consume a tiny bit of standby
        power', as seen by these properties:

        * Extremely low standby power (30uW typ hold mode)
        * No special bias circuitry required to maintain image in hold mode
        * 120 degree viewing angle, 1:35 contrast ratio
        * All control logic fabricated on-glass using TFT devices that are auditable with
          a common 40x power desktop microscope and a bright backlight source

        This last property in particular makes the memory LCD extremely well suited for situations
        where absolute visibility into the construction of a secure enclave is desired.

        The memory organization of the LS032B7DD02 is simple: 536 lines of pixel data 336 wide.
        Each pixel is 1 bit (the display is black and white), and is fed into the module from
        left to right as pixels 1 through 336, inclusive. Lines are enumerated from top to bottom,
        from 1 to 536, inclusive.

        The LCD can only receive serial data. The protocol is a synchronous serial interface with
        an active high chip select. All data words are transmitted LSB first. A line transfer is
        initiated by sending a 6-bit mode selection, a 10-bit row address, and the subsequent 336
        pixels, followed by 16 dummy bits which transfer the data from the LCD holding register to
        the display itself.

            .. wavedrom::
                :caption: Single line data transfer to memory LCD

                { "signal": [
                    { "name": "SCLK", "wave": "0.P.......|......|...|..l." },
                    { "name": "SCS", "wave": "01........|......|...|.0.." },
                    { "name": "SI", "wave": "0===x..===|======|==x|....", "data": ["M0", "M1", "M2", "R0", "R1", " ", "R8", "R9", "D0", "D1", "D2", " ", "D334", "D335"] },
                    { "node": ".....................a.b..."},
                ],
                  "edge": ['a<->b 16 cycles']
                }

        Alternatively, one can send successive lines without dropping SCS by substituting the 16 dummy
        bits at the end with a 6-bit don't care preamble (where the mode bits would have been), 10 bits
        of row address, and then the pixel data.

            .. wavedrom::
              :caption: Multiple line data transfer to memory LCD

              { "signal": [
                    { "name": "SCLK", "wave": "0.P.......|......|...|....|....." },
                    { "name": "SCS", "wave": "01........|......|...|....|....." },
                    { "name": "SI", "wave": "0===x..===|======|==x|.===|=====", "data": ["M0", "M1", "M2", "R0", "R1", " ", "R8", "R9", "D0", "D1", "D2", " ", "D334", "D335", "R0", "R1", " ", "R8", "R9", "D0", "D1"] },
                    { "node": ".....................a.b..."},
              ],
                "edge": ['a<->b 6 cycles']
              }

        The very last line in the multiple line data transfer must terminate with 16 dummy cycles.

        Mode bits M0-M2 have the following meaning:
           M0: Set to 1 when transferring data lines. Set to 0 for hold mode, see below.
           M1: VCOM inversion flag. Ignore when hardware strap pin EXTMODE is high. Betrusted
               sets EXTMODE high, so the VCOM inversion is handled by low-power aux hardware.
               When EXTMODE is low, software must explicitly manage the VCOM inversion flag such the
               flag polarity changes once every second "as much as possible".
           M2: Normally set to 0. Set to 1 for all clear (see below)

        Data bit polarity:
           1 = White
           0 = Black

        For 'Hold mode' and 'All clear', a total of 16 cycles are sent, the first three being
        the mode bit and the last 13 being dummy cycles.

            .. wavedrom::
              :caption: Hold and all clear timings

              { "signal": [
                    { "name": "SCLK", "wave": "0.P...|.l" },
                    { "name": "SCS", "wave": "01....|0." },
                    { "name": "SI", "wave": "0===x...", "data": ["M0", "M1", "M2", "R0", "R1", " ", "R8", "R9", "D0", "D1", "D2", " ", "D334", "D335", "R0", "R1", " ", "R8", "R9", "D0", "D1"] },
                    { "node": ".....a.b..."},
              ],
                "edge": ['a<->b 13 cycles']
            }

        All signals are 3.0V compatible, 5V tolerant (VIH is 2.7V-VDD). The display itself requires
        a single 5V power supply (4.8-5.5V typ 5.8V abs max). In hold mode, typical power is 30uW, max 330uW;
        with data updating at 1Hz, power is 250uW, max 750uW (SCLK=1MHz, EXTCOMMIN=1Hz).

        * The maximum clock frequency for SCLK is 2MHz (typ 1MHz).
        * EXTCOMMIN frequency is 1-10Hz, 1Hz typ
        * EXTCOMMIN minimum high duration is 1us
        * All rise/fall times must be less than 50ns
        * SCS setup time is 3us, hold time is 1us. Minimum low duration is 1us,
          minimum high is 188us for a data update, 12 us for a hold mode operation.
        * SI setup time is 120ns, 190ns hold time.
        * Operating temperature is -20 to 70C, storage temperature -30 to 80C.
        """)

        self.interface = ModuleDoc("""Wishbone interface for MemLCD

        MemLCD maintains a local framebuffer for the LCD. The CPU can read and write
        to the frame buffer to update pixel data, and then request a screen update to
        commit the frame buffer to the LCD.

        Only full lines can be updated on a memory LCD; partial updates are not possible.
        In order to optimize the update process, MemLCD maintains a "dirty bit" associated
        with each line. Only lines with modified pixels are written to the screen after an
        update request.

        A line is 336 bits wide. When padded to 32-bit words, this yields a line width of
        44 bytes (0x2C, or 352 bits). In order to simplify math, the frame buffer rounds
        the line width up to the nearest power of two, or 64 bytes.

        The unused bits can be used as a "hint" to the MemLCD block as to which lines
        require updating. If the unused bits have any value other than 0, the MemLCD block
        will update those lines when an "UpdateDirty" command is triggered. It is up
        to the CPU to set and clear the dirty bits, they are not automatically cleared
        by the block upon update. Typically the clearing of the bits would be handled
        during the update-finished interrupt handling routine. If the dirty bits are
        not used, an "UpdateAll" command can be invoked, which will update every
        line of the LCD regardless of the contents of the dirty bits.

        The total depth of the memory is thus 44 bytes * 536 lines = 23,584 bytes or
        5,896 words.

        Pixels are stored with the left-most pixel in the MSB of each 32-bit word, with
        the left-most pixels occupying the lowest address in the line.

        Lines are stored with the bottom line of the screen at the lowest address.

        These parameters are chosen so that a 1-bit BMP file can be copied into the frame
        buffer and it will render directly to the screen with no further transformations
        required.

        The CPU is responsible for not writing data to the LCD while it is updating. Concurrent
        writes to the LCD during updates can lead to unpredictable behavior.
        """)
        data_width     = 32
        width          = 336
        height         = 536
        bytes_per_line = 44

        self.fb_depth = fb_depth = height * bytes_per_line // (data_width//8)
        pixdata   = Signal(32)
        pixadr_rd = Signal(max=fb_depth)

        # 1 is white, which is the "off" state
        fb_init = [0xffffffff] * int(fb_depth)
        for i in range(fb_depth // 11):
            fb_init[i * 11 + 10] = 0xffff
        mem = Memory(32, fb_depth, init=fb_init)  # may need to round up to 8192 if a power of 2 is required by migen
        # read port for pixel data out
        self.specials.rdport = mem.get_port(write_capable=False, mode=READ_FIRST) # READ_FIRST allows BRAM to be used
        self.comb += self.rdport.adr.eq(pixadr_rd)
        self.comb += pixdata.eq(self.rdport.dat_r)
        # implementation note: vivado will complain about being unable to merge an output register, leading to
        # non-optimal timing, but a check of the timing path shows that at 100MHz there is about 4-5ns of setup margin,
        # so the merge is unnecessary in this case. Ergo, prefer comb over sync to reduce latency.

        # memory-mapped write port to wishbone bus
        self.bus = wishbone.Interface()
        self.submodules.wb_sram_if = wishbone.SRAM(mem, read_only=False)
        decoder_offset = log2_int(fb_depth, need_pow2=False)
        def slave_filter(a):
                return a[decoder_offset:32-decoder_offset] == 0  # no aliasing in the block
        self.submodules.wb_con = wishbone.Decoder(self.bus, [(slave_filter, self.wb_sram_if.bus)], register=True)

        self.command = CSRStorage(2, fields=[
            CSRField("UpdateDirty", description="Write a ``1`` to flush dirty lines to the LCD", pulse=True),
            CSRField("UpdateAll",   description="Update full screen regardless of tag state",    pulse=True),
        ])

        self.busy = CSRStatus(1, name="Busy", description="""A ``1`` indicates that the block is currently updating the LCD""")

        self.prescaler = CSRStorage(8, reset=99, name="prescaler", description="""
        Prescaler value. LCD clock is module (clock / (prescaler+1)). Reset value: 99, so
        for a default sysclk of 100MHz this yields an LCD SCLK of 1MHz""")

        self.submodules.ev = EventManager()
        self.ev.done       = EventSourceProcess()
        self.ev.finalize()
        self.comb += self.ev.done.trigger.eq(self.busy.status) # Fire an interupt when busy drops

        self.sclk = sclk = getattr(pads, "sclk")
        self.scs  = scs  = getattr(pads, "scs")
        self.si   = si   = getattr(pads, "si")
        self.sendline = sendline = Signal()
        self.linedone = linedone = Signal()
        updateall   = Signal()
        fetch_dirty = Signal()
        update_line = Signal(max=height) # Keep track of both line and address to avoid instantiating a multiplier
        update_addr = Signal(max=height*bytes_per_line)

        fsm_up = FSM(reset_state="IDLE")
        self.submodules += fsm_up

        fsm_up.act("IDLE",
            If(self.command.fields.UpdateDirty | self.command.fields.UpdateAll,
                NextValue(self.busy.status, 1),
                NextValue(fetch_dirty, 1),
                If(self.command.fields.UpdateAll,
                    NextValue(updateall, 1)
                ).Else(
                    NextValue(updateall, 0)
                ),
                NextState("START")
            ).Else(
                NextValue(self.busy.status, 0)
            )
        )
        fsm_up.act("START",
            NextValue(update_line, height),
            NextValue(update_addr, (height -1) * bytes_per_line), # Represents the byte address of the beginning of the last line
            NextState("FETCHDIRTY")
        )
        fsm_up.act("FETCHDIRTY", # Wait one cycle delay for the pixel data to be retrieved before evaluating it
            NextState("CHECKDIRTY")
        )
        fsm_up.act("CHECKDIRTY",
            If(update_line == 0,
                NextState("IDLE")
            ).Else(
                If( (pixdata[16:] != 0) | updateall,
                    NextState("DIRTYLINE"),
                ).Else(
                    NextValue(update_line, update_line - 1),
                    NextValue(update_addr, update_addr - bytes_per_line),
                    NextState("FETCHDIRTY")
                )
            )
        )
        fsm_up.act("DIRTYLINE",
            NextValue(fetch_dirty, 0),
            sendline.eq(1),
            NextState("WAITDONE")
        )
        fsm_up.act("WAITDONE",
            If(linedone,
                NextValue(fetch_dirty, 1),
                NextValue(update_line, update_line - 1),
                NextValue(update_addr, update_addr - bytes_per_line),
                NextState("FETCHDIRTY")
            )
        )

        modeshift = Signal(16)
        mode      = Signal(6)
        pixshift  = Signal(32)
        pixcount  = Signal(max=width)
        bitreq    = Signal()
        bitack    = Signal()
        self.comb += mode.eq(1) # Always in line write mode, not clearing, no vcom management necessary
        fsm_phy = FSM(reset_state="IDLE")
        self.submodules += fsm_phy
        # Update_addr units is in bytes. [2:] turns bytes to words
        # pixcount units are in pixels. [3:] turns pixels to bytes
        self.comb += [
            If(fetch_dirty,
                pixadr_rd.eq((update_addr + bytes_per_line - 4)[2:])
            ).Else(
                pixadr_rd.eq((update_addr + pixcount[3:])[2:])
            )
         ]
        scs_cnt = Signal(max=200)
        fsm_phy.act("IDLE",
            NextValue(si, 0),
            NextValue(linedone, 0),
            If(sendline,
                NextValue(scs, 1),
                NextValue(scs_cnt, 200), # 2 us setup
                NextValue(pixcount, 16),
                NextValue(modeshift, Cat(mode, update_line)),
                NextState("SCS_SETUP")
            ).Else(
                NextValue(scs, 0)
            )
        )
        fsm_phy.act("SCS_SETUP",
            If(scs_cnt > 0,
                NextValue(scs_cnt, scs_cnt - 1)
            ).Else(
                NextState("MODELINE")
            )
        )
        fsm_phy.act("MODELINE",
            If(pixcount > 0,
                NextValue(modeshift, modeshift[1:]),
                NextValue(si, modeshift[0]),
                NextValue(pixcount, pixcount - 1),
                bitreq.eq(1),
                NextState("MODELINEWAIT")
            ).Else(
                NextValue(pixcount, 1),
                NextValue(pixshift, pixdata),
                NextState("DATA")
            )
        )
        fsm_phy.act("MODELINEWAIT",
            If(bitack,
                NextState("MODELINE")
            )
        )
        fsm_phy.act("DATA",
            If(pixcount < width + 17,
                If(pixcount[0:5] == 0,
                    NextValue(pixshift, pixdata),
                ).Else(
                    NextValue(pixshift, pixshift[1:]),
                ),
                NextValue(scs, 1),
                NextValue(si, pixshift[0]),
                NextValue(pixcount, pixcount + 1),
                bitreq.eq(1),
                NextState("DATAWAIT")
            ).Else(
                NextValue(si, 0),
                NextValue(scs_cnt, 100), # 1 us hold
                NextState("SCS_HOLD")
            )
        )
        fsm_phy.act("SCS_HOLD",
            If(scs_cnt > 0,
                NextValue(scs_cnt, scs_cnt - 1)
            ).Else(
                NextValue(scs, 0),
                NextValue(scs_cnt, 100), # 1us minimum low time
                NextState("SCS_LOW")
            )
        )
        fsm_phy.act("SCS_LOW",
            If(scs_cnt > 0,
                NextValue(scs_cnt, scs_cnt - 1)
            ).Else(
                NextValue(linedone, 1),
                NextState("IDLE")
            )
        )
        fsm_phy.act("DATAWAIT",
            If(bitack,
                NextState("DATA")
            )
        )

        # This handles clock division
        fsm_bit = FSM(reset_state="IDLE")
        self.submodules += fsm_bit
        clkcnt = Signal(8)
        fsm_bit.act("IDLE",
            NextValue(sclk, 0),
            NextValue(clkcnt, self.prescaler.storage),
            If(bitreq,
                NextState("SCLK_LO")
            )
        )
        fsm_bit.act("SCLK_LO",
            NextValue(clkcnt, clkcnt - 1),
            If(clkcnt < self.prescaler.storage[1:],
               NextValue(sclk, 1),
               NextState("SCLK_HI")
            )
        )
        fsm_bit.act("SCLK_HI",
            NextValue(clkcnt, clkcnt - 1),
            If(clkcnt == 0,
                NextValue(sclk, 0),
                NextState("IDLE"),
                bitack.eq(1)
            )
        )
