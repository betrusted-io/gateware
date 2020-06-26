import os

from migen import *
from litex.soc.integration.doc import AutoDoc
from litex.soc.interconnect.csr import *
from litex.soc.interconnect.csr_eventmanager import *
from litex.soc.interconnect import wishbone
from migen.genlib.cdc import BlindTransfer, MultiReg

class Hmac(Module, AutoDoc, AutoCSR):
    def __init__(self, platform):
        self.bus = bus = wishbone.Interface()
        wdata=Signal(64)
        wmask=Signal(8)
        wdata_we=Signal()
        wdata_avail=Signal()
        wdata_ready=Signal()
        ack_lsb=Signal()
        ack_lsb_r=Signal()
        ack_msb=Signal()
        ack_msb_r=Signal()
        self.sync.clk50 += [
            wdata_avail.eq(bus.cyc & bus.stb & bus.we & bus.adr[0] == 0), # transfer on an even write, so top word must be written first
            If(bus.cyc & bus.stb & bus.we & ~bus.ack,
                If(bus.adr[0] == 0,
                    wdata[:32].eq(bus.dat_w),
                    wdata[32:].eq(wdata[32:]),
                    wmask[:4].eq(bus.sel),
                    wmask[4:].eq(wmask[4:]),
                    wdata_we.eq(1),  # only commit on even words
                    ack_lsb.eq(1),
                ).Else(
                    wdata[:32].eq(wdata[:32]),
                    wdata[32:].eq(bus.dat_w),
                    wmask[:4].eq(wmask[:4]),
                    wmask[4:].eq(bus.sel),
                    ack_msb.eq(1),
                ),
            ).Else(
                wdata.eq(0),
                wmask.eq(0),
                wdata_we.eq(0),
                ack_lsb.eq(0),
                ack_msb.eq(0),
            )
        ]
        self.sync += [
            ack_lsb_r.eq(ack_lsb),
            ack_msb_r.eq(ack_msb),
            bus.ack.eq( ~ack_lsb_r & ack_lsb | ~ack_msb_r & ack_msb )  # single-cycle acks only!
        ]

        self.config = CSRStorage(description="Configuration register for the HMAC block", fields=[
            CSRField("sha_en", size=1, description="Enable the SHA512 core"),
            CSRField("endian_swap", size=1, description="Swap the endianness on the input data"),
            CSRField("digest_swap", size=1, description="Swap the endianness on the output digest"),
            CSRField("select_256", size=1, description="Select SHA512/256 IV constants when set to `1`")
        ])
        control_latch = Signal(self.config.size)
        ctrl_freeze = Signal()
        sha_en_50 = Signal()
        self.sync.clk50 += [
            If(ctrl_freeze,
                control_latch.eq(control_latch)
            ).Else(
                control_latch.eq(self.config.storage)
            ),
            sha_en_50.eq(self.config.fields.sha_en),
        ]
        self.command = CSRStorage(description="Command register for the HMAC block", fields=[
            CSRField("hash_start", size=1, description="Writing a 1 indicates the beginning of hash data", pulse=True),
            CSRField("hash_process", size=1, description="Writing a 1 digests the hash data", pulse=True),
        ])

        for k in range(0, 8):
            setattr(self, "digest" + str(k), CSRStatus(64, name="digest" + str(k), description="""digest word {}""".format(k)))

        self.msg_length = CSRStatus(size=64, description="Bottom 64 bits of length of digested message, in bits")

        self.submodules.ev = EventManager()
        self.ev.err_valid = EventSourcePulse(description="Error flag was generated")
        self.ev.fifo_full = EventSourcePulse(description="FIFO is full")
        self.ev.sha512_done = EventSourcePulse(description="SHA512 is done")
        self.ev.finalize()
        err_valid=Signal()
        err_valid_r=Signal()
        fifo_full=Signal()
        fifo_full_r=Signal()
        sha512_hash_done=Signal()
        self.sync += [
            err_valid_r.eq(err_valid),
            fifo_full_r.eq(fifo_full),
        ]
        self.comb += [
            self.ev.err_valid.trigger.eq(~err_valid_r & err_valid),
            self.ev.fifo_full.trigger.eq(~fifo_full_r & fifo_full),
            self.ev.sha512_done.trigger.eq(sha512_hash_done),
        ]

        # At a width of 64 bits, an 36kiB fifo is 512 entries deep
        fifo_wvalid=Signal()
        fifo_wdata_mask=Signal(72)
        fifo_rready=Signal()
        fifo_rdata_mask=Signal(72)
        self.fifo = CSRStatus(description="FIFO status", fields=[
            CSRField("read_count", size=9, description="read pointer"),
            CSRField("write_count", size=9, description="write pointer"),
            CSRField("read_error", size=1, description="read error occurred"),
            CSRField("write_error", size=1, description="write error occurred"),
            CSRField("almost_full", size=1, description="almost full"),
            CSRField("almost_empty", size=1, description="almost empty"),
            CSRField("running", size=1, description="hash engine is running and controls are locked out"),
        ])
        ctrl_freeze_sys = Signal()
        self.specials += MultiReg(ctrl_freeze, ctrl_freeze_sys)
        self.comb += self.fifo.fields.running.eq(ctrl_freeze_sys)

        fifo_rvalid = Signal()
        fifo_empty = Signal()
        fifo_wready=Signal()
        fifo_full_local = Signal()
        self.comb += fifo_rvalid.eq(~fifo_empty)
        self.comb += fifo_wready.eq(~fifo_full_local)
        self.specials += Instance("FIFO36_72",
#            p_DATA_WIDTH=72,
            p_ALMOST_EMPTY_OFFSET=8,
            p_ALMOST_FULL_OFFSET=8,
            p_DO_REG=1,
            p_FIRST_WORD_FALL_THROUGH="TRUE",
            p_EN_SYN="FALSE",
            i_RDCLK=ClockSignal("clk50"),
            i_WRCLK=ClockSignal("clk50"),
            i_RST=ResetSignal("clk50"),
            o_FULL=fifo_full_local,
            i_WREN=fifo_wvalid,
            i_DI=fifo_wdata_mask[:64],
            i_DIP=fifo_wdata_mask[64:],
            o_EMPTY=fifo_empty,
            i_RDEN=fifo_rready & fifo_rvalid,
            o_DO=fifo_rdata_mask[:64],
            o_DOP=fifo_rdata_mask[64:],
            o_RDCOUNT=self.fifo.fields.read_count,
            o_RDERR=self.fifo.fields.read_error,
            o_WRCOUNT=self.fifo.fields.write_count,
            o_WRERR=self.fifo.fields.write_error,
            o_ALMOSTFULL=self.fifo.fields.almost_full,
            o_ALMOSTEMPTY=self.fifo.fields.almost_empty,
        )

        hash_start_50 = Signal()
        self.submodules.hashstart = BlindTransfer("sys", "clk50")
        self.comb += [ self.hashstart.i.eq(self.command.fields.hash_start), hash_start_50.eq(self.hashstart.o) ]

        hash_proc_50 = Signal()
        self.submodules.hashproc = BlindTransfer("sys", "clk50")
        self.comb += [ self.hashproc.i.eq(self.command.fields.hash_process), hash_proc_50.eq(self.hashproc.o) ]

        self.specials += Instance("sha512_litex",
            i_clk_i = ClockSignal("clk50"),
            i_rst_ni = ~ResetSignal("clk50"),

            i_reg_hash_start=hash_start_50,
            i_reg_hash_process=hash_proc_50,

            o_ctrl_freeze=ctrl_freeze,
            i_sha_en=sha_en_50,
            i_endian_swap=control_latch[1],
            i_digest_swap=control_latch[2],
            i_hash_select_256=control_latch[3],

            o_sha_hash_done=sha512_hash_done,

            o_digest_0=self.digest0.status,
            o_digest_1=self.digest1.status,
            o_digest_2=self.digest2.status,
            o_digest_3=self.digest3.status,
            o_digest_4=self.digest4.status,
            o_digest_5=self.digest5.status,
            o_digest_6=self.digest6.status,
            o_digest_7=self.digest7.status,

            o_msg_length=self.msg_length.status,

            i_msg_fifo_wdata=wdata,
            i_msg_fifo_write_mask=wmask,
            i_msg_fifo_we=wdata_we,
            i_msg_fifo_req=wdata_avail,
            o_msg_fifo_gnt=wdata_ready,

            o_local_fifo_wvalid=fifo_wvalid,
            i_local_fifo_wready=fifo_wready,
            o_local_fifo_wdata_mask=fifo_wdata_mask,
            i_local_fifo_rvalid=fifo_rvalid,
            o_local_fifo_rready=fifo_rready,
            i_local_fifo_rdata_mask=fifo_rdata_mask,

            o_err_valid=err_valid,
            i_err_valid_pending=self.ev.err_valid.pending,
            o_fifo_full_event=fifo_full,
        )

        platform.add_source(os.path.join("deps", "gateware", "gateware", "sha512", "hmac512_pkg.sv"))
        platform.add_source(os.path.join("deps", "gateware", "gateware", "sha512", "sha512.sv"))
        platform.add_source(os.path.join("deps", "gateware", "gateware", "sha512", "sha512_pad.sv"))
        platform.add_source(os.path.join("deps", "gateware", "gateware", "sha512", "prim_packer512.sv"))
        platform.add_source(os.path.join("deps", "gateware", "gateware", "sha512_litex.sv"))
