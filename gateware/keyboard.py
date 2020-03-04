from migen.genlib.cdc import MultiReg
from migen.genlib.coding import Decoder

from litex.soc.integration.doc import AutoDoc, ModuleDoc
from litex.soc.interconnect.csr_eventmanager import *

# Relies on a clock called "kbd" for delay counting
# Input and output through "i" and "o" signals respectively
class Debounce(Module):
    def __init__(self, n):
        self.i = Signal()
        self.o = Signal()

        # # #

        i_kbd = Signal()
        o_kbd = Signal()
        count = Signal(max=(2*n))

        self.specials += MultiReg(self.i, i_kbd, odomain="kbd");
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
        self.specials += MultiReg(o_kbd, self.o)

# A hardware key scanner that can run even when the CPU is powered down or stopped
class KeyScan(Module, AutoCSR, AutoDoc):
    def __init__(self, pads):
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
            # below is in sysclock domain; row_scan is guaranteed stable by state machine sequencing when scan_done gating is enabled
            self.sync += [
                If(scan_done_sys,
                    getattr(self, "row" + str(r) + "dat").status.eq(row_scan)
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

        pending_key = Signal()
        self.sync.kbd += [
            colcount.eq(colcount + 1),
            scan_done.eq(0),
            update_shadow.eq(0),
            reset_scan.eq(0),
            If(colcount == (settling*cols.nbits+2), colcount.eq(0)),
            If(colcount == (settling*cols.nbits), scan_done.eq(1)),
            # Only update the shadow if the pending bit has been cleared (e.g., CPU has acknowledged
            # it has fetched the current key state)
            If(colcount == (settling*cols.nbits+1), update_shadow.eq(~pending_key)),
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
        self.ev.keypressed = EventSourcePulse() # Rising edge triggered
        self.ev.finalize()
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
        # Fire an interrupt during the reset_scan phase. Delay by 2 cycles so that rowchange can pick
        # up a new value before the "pending" bit is set.
        kp_d  = Signal()
        kp_d2 = Signal()
        kp_r  = Signal()
        kp_r2 = Signal()
        self.sync.kbd += kp_d.eq(rowdiff != 0)
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
        self.specials += MultiReg(self.ev.keypressed.pending, pending_key, "kbd")
