from migen.genlib.cdc import MultiReg, BlindTransfer
from migen.genlib.coding import Decoder

from litex.soc.integration.doc import AutoDoc, ModuleDoc
from litex.soc.interconnect.csr_eventmanager import *

# Relies on a clock called "kbd" for delay counting
# Input and output through "i" and "o" signals respectively
class Debounce(Module):
    def __init__(self, i, o, n):
        i_kbd = Signal()
        o_kbd = Signal()
        count = Signal(max=(2*n))

        self.specials += MultiReg(i, i_kbd, odomain="kbd");
        self.sync.kbd += [
            # Basic idea: We want to debounce our input signal for n cycles:
            # If key is pressed, count up to n; if it bounces, reset count to 0. The key is declared
            # pressed when held for n successive cycles. At this point, count is set to 2*n and the
            # same process is so repeated for the key release, except counting down to n.
            If(i_kbd,
                count.eq(count + 1),
                 # Once we've reached n, "snap" up to 2x n to prep for key release
                If(count >= n,
                    count.eq(2*n),
                )
            ).Else(
                count.eq(count - 1),
                # Once we've fell below n, "snap" down to 0 to prepare for next key press
                If(count < n,
                    count.eq(0)
                )
            ),
            o_kbd.eq(count >= n)
        ]
        #self.specials += MultiReg(o_kbd, o)
        self.sync.kbd += o.eq(o_kbd)  # if we want the output domain to be in kbd

class KeyScan(Module, AutoCSR, AutoDoc):
    def __init__(self, pads, debounce_ms=5):
        self.background = ModuleDoc("""Matrix Keyboard Driver
A hardware key scanner that can run even when the CPU is powered down or stopped.

The hardware is assumed to be a matrix of switches, divided into rows and columns. 
The number of rows and columns is inferred by the number of pins dedicated in
the `pads` record. 

The rows are inputs, and require a `PULLDOWN` to be inferred on the pins, to prevent
them from floating when the keys are not pressed. Note that `PULLDOWN` is not offered
on all FPGA architectures, but at the very least is present on 7-Series FPGAs.

The columns are driven by tristate drivers. The state of the columns is either driven
high (`1`), or hi-Z (`Z`). 

The KeyScan module also expects a `kbd` clock domain. The preferred implementation
makes this a 32.768KHz always-on clock input with no PLL. This allows the keyboard 
module to continue scanning even if the CPU is powered down.

Columns are scanned sequentially using a `kbd`-domain state machine by driving each
column in order. When a column is driven, its electrical state goes from `hi-z` to `1`. 
The rows are then sampled with each column scan state. Since each row has
a pulldown on it, if no keys are hit, the result is `0`. When a key is pressed, it
will short a row to a column, and the `1` driven on a column will flip the row
state to a `1`, thus registering a key press. 

Columns are driven for a minimum period of time known as a `settling` period. The
settling time must be at least 2 because a Multireg (2-stage synchronizer) is used
to sample the data on the receiving side. In this module, settling time is fixed
to `4` cycles.

Thus a 1 in the `rowdat` registers indicate the column intersection that was active for 
a given row in the matrix.

There is also a row shadow register that is maintained by the hardware. The row shadow
is used to maintain the previous state of the key matrix, so that a "key press change"
interrupt can be generated. The first change in the row registers is recorded in the
`rowchange` status register. It does not update until it has been read. The idea of this
register is that it can capture one key hit while the CPU is in standby, and the CPU
should wake up in time to read it, before a new key hit is registered. The CPU can consult
the `rowchange` register to read just the `rowdat` CSR with the key change, instead of
having to iterate through the entire array to find the row that changed. 

There is also a `keypressed` interrupt which fires every time there is a change in
the row registers. 

`debounce` is the period in ms for the keyboard matrix to stabilize before triggering
an interrupt.
        """)
        rows_unsync = pads.row
        cols        = Signal(pads.col.nbits)

        for c in range(0, cols.nbits):
            cols_ts = TSTriple(1)
            self.specials += cols_ts.get_tristate(pads.col[c])
            self.comb += cols_ts.oe.eq(cols[c])
            self.comb += cols_ts.o.eq(1)

        # row and col are n-bit signals that correspond to the row and columns of the keyboard matrix
        # each row will generate a column register with the column result in it
        rows = Signal(rows_unsync.nbits)
        self.specials += MultiReg(rows_unsync, rows, "kbd")

        # setattr(self, name, object) is the same as self.name = object, except in this case "name" can be dynamically generated
        # this is necessary here because we CSRStatus is not iterable, so we have to manage the attributes manually
        for r in range(0, rows.nbits):
            setattr(self, "row" + str(r) + "dat", CSRStatus(cols.nbits, name="row" + str(r) + "dat", description="""Column data for the given row"""))

        settling = 4  # 4 cycles to settle: 2 cycles for MultiReg stabilization + slop. Must be > 2, and a power of 2
        colcount = Signal(max=(settling*cols.nbits+2))

        update_shadow = Signal()
        reset_scan    = Signal()
        scan_done     = Signal()
        col_r         = Signal(cols.nbits)
        scan_done_sys = Signal()
        self.specials += MultiReg(scan_done, scan_done_sys)
        for r in range(0, rows.nbits):
            row_scan = Signal(cols.nbits)
            row_scan_sys = Signal(cols.nbits)
            # below is in sysclock domain; row_scan is guaranteed stable by state machine sequencing when scan_done gating is enabled
            self.sync += [
                row_scan_sys.eq(row_scan), # loosen up the clock domain crossing timing
                If(scan_done_sys,
                    getattr(self, "row" + str(r) + "dat").status.eq(row_scan_sys)
                ).Else(
                    getattr(self, "row" + str(r) + "dat").status.eq(getattr(self, "row" + str(r) + "dat").status)
                )
            ]
            self.sync.kbd += [
                If(reset_scan,
                   row_scan.eq(0)
                ).Else(
                    If(rows[r] & (colcount[0:2] == 3),  # sample row only on the 4th cycle of colcount
                       row_scan.eq(row_scan | col_r)
                    ).Else(
                        row_scan.eq(row_scan)
                    )
                )
            ]

            rowshadow = Signal(cols.nbits)
            self.sync.kbd += If(update_shadow, rowshadow.eq(row_scan)).Else(rowshadow.eq(rowshadow))

            setattr(self, "row_scan" + str(r), row_scan)
            setattr(self, "rowshadow" + str(r), rowshadow)
            # create a simple, one-scan delayed version of row_scan for debouncing purposes
            row_debounce = Signal(cols.nbits)
            self.sync.kbd += [
                If(scan_done,
                    row_debounce.eq(row_scan),
                ).Else(
                    row_debounce.eq(row_debounce),
                )
            ]
            setattr(self, "row_debounce" + str(r), row_debounce)

        pending_kbd = Signal()
        pending_kbd_f = Signal()
        key_ack = Signal()
        self.sync.kbd += [
            pending_kbd_f.eq(pending_kbd),
            colcount.eq(colcount + 1),
            scan_done.eq(0),
            update_shadow.eq(0),
            reset_scan.eq(0),
            If(colcount == (settling*cols.nbits+2), colcount.eq(0)),
            If(colcount == (settling*cols.nbits), scan_done.eq(1)),
            # Only update the shadow if the pending bit has been cleared (e.g., CPU has acknowledged
            # it has fetched the current key state)
            If(~pending_kbd & pending_kbd_f,
                If(colcount == (settling * cols.nbits + 1),
                    update_shadow.eq(1),
                    key_ack.eq(0),
                ).Else(
                    key_ack.eq(1),
                )
            ).Else(
                If(colcount == (settling*cols.nbits+1),
                    update_shadow.eq(key_ack),
                    key_ack.eq(0),
                ).Else(
                    key_ack.eq(key_ack)
                )
            ),
            If(colcount == (settling*cols.nbits+2), reset_scan.eq(1)),
        ]

        # Drive the columns based on the colcount counter
        self.submodules.coldecoder = Decoder(cols.nbits)
        self.comb += [
            self.coldecoder.i.eq(colcount[log2_int(settling):]),
            self.coldecoder.n.eq(~(colcount < settling*cols.nbits)),
            cols.eq(self.coldecoder.o)
        ]
        self.sync.kbd += col_r.eq(self.coldecoder.o)

        self.submodules.ev = EventManager()
        self.ev.keypressed = EventSourcePulse(description="Triggered every time there is a difference in the row state") # Rising edge triggered
        self.ev.finalize()
        # debounce timers and clocks
        debounce_clocks = int((debounce_ms * 0.001) * 32768.0)
        debounce_timer  = Signal(max=(debounce_clocks + 1))
        debounced = Signal()
        # Extract any changes just before the shadow takes its new values
        rowdiff = Signal(rows.nbits)
        for r in range(0, rows.nbits):
            self.sync.kbd += [
                If(scan_done,
                   rowdiff[r].eq( ~((getattr(self, "row_scan" + str(r)) ^ getattr(self, "rowshadow" + str(r))) == 0) )
                ).Else(
                    rowdiff[r].eq(rowdiff[r])
                )
            ]

        # debouncing:
        #   1. compute the delta of the current scan vs. previous scan
        #   2. if the delta is non-zero, start a debounce timer.
        #   3. Count down as long as the delta remains zero; if the delta is non-zero again, reset the timer.
        #   4. When the timer hits zero, latch the final value for sampling to the CPU
        rowchanging = Signal(rows.nbits)
        for r in range(0, rows.nbits):
            self.sync.kbd += [
                If(scan_done,
                    rowchanging[r].eq( ~((getattr(self, "row_scan" + str(r)) ^ getattr(self, "row_debounce" + str(r))) == 0) )
                ).Else(
                    rowchanging[r].eq(rowchanging[r])
                )
            ]

        db_fsm = ClockDomainsRenamer("kbd")(FSM(reset_state="IDLE"))
        self.submodules += db_fsm
        db_fsm.act("IDLE",
            If(rowchanging != 0,
                NextValue(debounce_timer, debounce_clocks),
                NextState("DEBOUNCING")
            )
        )
        db_fsm.act("DEBOUNCING",
            If(rowchanging == 0,
                NextValue(debounce_timer, debounce_timer - 1),
                If(debounce_timer == 0,
                    NextState("DEBOUNCED")
                )
            ).Else(
                NextValue(debounce_timer, debounce_clocks),
                NextState("DEBOUNCING")
            )
        )
        db_fsm.act("DEBOUNCED",
            debounced.eq(1),
            NextState("IDLE")
        )

        # Fire an interrupt during the reset_scan phase. Delay by 2 cycles so that rowchange can pick
        # up a new value before the "pending" bit is set.
        kp_d  = Signal()
        kp_d2 = Signal()
        kp_r  = Signal()
        kp_r2 = Signal()
        self.sync.kbd += kp_d.eq(debounced & (rowdiff != 0))
        self.sync.kbd += kp_d2.eq(kp_d)
        self.sync += kp_r.eq(kp_d2)
        self.sync += kp_r2.eq(kp_r)
        self.comb += self.ev.keypressed.trigger.eq(kp_r & ~kp_r2)

        self.rowchange = CSRStatus(rows.nbits, name="rowchange",
            description="""The rows that changed at the point of interrupt generation.
            Does not update again until the interrupt is serviced.""")
        reset_scan_sys = Signal()
        self.specials += MultiReg(reset_scan, reset_scan_sys)
        self.sync += [
            If(reset_scan_sys & ~self.ev.keypressed.pending,
               self.rowchange.status.eq(rowdiff)
            ).Else(
                self.rowchange.status.eq(self.rowchange.status)
            )
        ]
        #self.specials += MultiReg(self.ev.keypressed.pending, pending_kbd, "kbd")
        self.submodules.pending_sync = BlindTransfer("sys", "kbd")
        self.comb += [
            self.pending_sync.i.eq(self.ev.keypressed.pending),
            pending_kbd.eq(self.pending_sync.o),
        ]
