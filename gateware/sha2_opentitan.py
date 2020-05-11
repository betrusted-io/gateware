import os

from migen import *
from litex.soc.integration.doc import AutoDoc
from litex.soc.interconnect.csr import *
from litex.soc.interconnect.csr_eventmanager import *
from litex.soc.interconnect import wishbone
from migen.genlib.cdc import BlindTransfer

class Hmac(Module, AutoDoc, AutoCSR):
    def __init__(self, platform):
        self.bus = bus = wishbone.Interface()
        wdata=Signal(32)
        wmask=Signal(4)
        wdata_we=Signal()
        wdata_avail=Signal()
        wdata_ready=Signal()
        self.sync.clk50 += [
            wdata_avail.eq(bus.cyc & bus.stb & bus.we),
            If(bus.cyc & bus.stb & bus.we & ~bus.ack,
                If(wdata_ready,
                    wdata.eq(bus.dat_w),
                    wmask.eq(bus.sel),
                    wdata_we.eq(1),
                    bus.ack.eq(1),  #### TODO check that this works with the clk50->clk100 domain crossing
                ).Else(
                    wdata_we.eq(0),
                    bus.ack.eq(0),
                )
               ).Else(
                wdata_we.eq(0),
                bus.ack.eq(0),
            )
        ]

        self.key_re = Signal(8)
        for k in range(0, 8):
            setattr(self, "key" + str(k), CSRStorage(32, name="key" + str(k), description="""secret key word {}""".format(k)))
            self.key_re[k].eq(getattr(self, "key" + str(k)).re)

        self.config = CSRStorage(description="Configuration register for the HMAC block", fields=[
            CSRField("sha_en", size=1, description="Enable the SHA256 core"),
            CSRField("endian_swap", size=1, description="Swap the endianness on the input data"),
            CSRField("digest_swap", size=1, description="Swap the endianness on the output digest"),
            CSRField("hmac_en", size=1, description="Enable the HMAC core"),
        ])
        control_latch = Signal(self.config.size)
        ctrl_freeze = Signal()
        self.sync.clk50 += [
            If(ctrl_freeze,
                control_latch.eq(control_latch)
            ).Else(
                control_latch.eq(self.config.storage)
            )
        ]
        self.command = CSRStorage(description="Command register for the HMAC block", fields=[
            CSRField("hash_start", size=1, description="Writing a 1 indicates the beginning of hash data", pulse=True),
            CSRField("hash_process", size=1, description="Writing a 1 digests the hash data", pulse=True),
        ])

        self.wipe = CSRStorage(32, description="wipe the secret key using the written value. Wipe happens upon write.")

        for k in range(0, 8):
            setattr(self, "digest" + str(k), CSRStatus(32, name="digest" + str(k), description="""digest word {}""".format(k)))

        self.msg_length = CSRStatus(size=64, description="Length of digested message, in bits")
        self.error_code = CSRStatus(size=32, description="Error code")

        self.submodules.ev = EventManager()
        self.ev.err_valid = EventSourcePulse(description="Error flag was generated")
        self.ev.fifo_full = EventSourcePulse(description="FIFO is full")
        self.ev.hash_done = EventSourcePulse(description="HMAC is done")
        self.ev.sha256_done = EventSourcePulse(description="SHA256 is done")
        self.ev.finalize()
        err_valid=Signal()
        err_valid_r=Signal()
        fifo_full=Signal()
        fifo_full_r=Signal()
        hmac_hash_done=Signal()
        sha256_hash_done=Signal()
        self.sync += [
            err_valid_r.eq(err_valid),
            fifo_full_r.eq(fifo_full),
        ]
        self.comb += [
            self.ev.err_valid.trigger.eq(~err_valid_r & err_valid),
            self.ev.fifo_full.trigger.eq(~fifo_full_r & fifo_full),
            self.ev.hash_done.trigger.eq(hmac_hash_done),
            self.ev.sha256_done.trigger.eq(sha256_hash_done),
        ]

        # At a width of 32 bits, an 36kiB fifo is 1024 entries deep
        fifo_wvalid=Signal()
        fifo_wdata_mask=Signal(36)
        fifo_rready=Signal()
        fifo_rdata_mask=Signal(36)
        self.fifo = CSRStatus(description="FIFO status", fields=[
            CSRField("read_count", size=10, description="read pointer"),
            CSRField("write_count", size=10, description="write pointer"),
            CSRField("read_error", size=1, description="read error occurred"),
            CSRField("write_error", size=1, description="write error occurred"),
            CSRField("almost_full", size=1, description="almost full"),
            CSRField("almost_empty", size=1, description="almost empty"),
        ])
        fifo_rvalid = Signal()
        fifo_empty = Signal()
        fifo_wready=Signal()
        fifo_full_local = Signal()
        self.comb += fifo_rvalid.eq(~fifo_empty)
        self.comb += fifo_wready.eq(~fifo_full_local)
        self.specials += Instance("FIFO36E1",
            p_DATA_WIDTH=36,
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
            i_DI=fifo_wdata_mask[:32],
            i_DIP=fifo_wdata_mask[32:],
            o_EMPTY=fifo_empty,
            i_RDEN=fifo_rready & fifo_rvalid,
            o_DO=fifo_rdata_mask[:32],
            o_DOP=fifo_rdata_mask[32:],
            o_RDCOUNT=self.fifo.fields.read_count,
            o_RDERR=self.fifo.fields.read_error,
            o_WRCOUNT=self.fifo.fields.write_count,
            o_WRERR=self.fifo.fields.write_error,
            o_ALMOSTFULL=self.fifo.fields.almost_full,
            o_ALMOSTEMPTY=self.fifo.fields.almost_empty,
        )

        key_re_50 = Signal(8)
        for k in range(0, 8):
            setattr(self.submodules, 'keyre50_' + str(k), BlindTransfer("sys", "clk50"))
            getattr(self, 'keyre50_' + str(k)).i.eq(getattr(self, 'key' + str(k)).re)
            self.comb += key_re_50[k].eq(getattr(self, 'keyre50_' + str(k)).o)

        hash_start_50 = Signal()
        self.submodules.hashstart = BlindTransfer("sys", "clk50")
        self.comb += [ self.hashstart.i.eq(self.command.fields.hash_start), hash_start_50.eq(self.hashstart.o) ]

        hash_proc_50 = Signal()
        self.submodules.hashproc = BlindTransfer("sys", "clk50")
        self.comb += [ self.hashproc.i.eq(self.command.fields.hash_process), hash_proc_50.eq(self.hashproc.o) ]

        wipe_50 = Signal()
        self.submodules.wipe50 = BlindTransfer("sys", "clk50")
        self.comb += [ self.wipe50.i.eq(self.wipe.re), wipe_50.eq(self.wipe50.o) ]

        self.specials += Instance("sha2_litex",
            i_clk_i = ClockSignal("clk50"),
            i_rst_ni = ~ResetSignal("clk50"),

            i_secret_key_0=self.key0.storage,
            i_secret_key_1=self.key1.storage,
            i_secret_key_2=self.key2.storage,
            i_secret_key_3=self.key3.storage,
            i_secret_key_4=self.key4.storage,
            i_secret_key_5=self.key5.storage,
            i_secret_key_6=self.key6.storage,
            i_secret_key_7=self.key7.storage,
            i_secret_key_re=key_re_50,

            i_reg_hash_start=hash_start_50,
            i_reg_hash_process=hash_proc_50,

            o_ctrl_freeze=ctrl_freeze,
            i_sha_en=control_latch[0],
            i_endian_swap=control_latch[1],
            i_digest_swap=control_latch[2],
            i_hmac_en=control_latch[3],

            o_reg_hash_done=hmac_hash_done,
            o_sha_hash_done=sha256_hash_done,

            i_wipe_secret_re=wipe_50,
            i_wipe_secret_v=self.wipe.storage,

            o_digest_0=self.digest0.status,
            o_digest_1=self.digest1.status,
            o_digest_2=self.digest2.status,
            o_digest_3=self.digest3.status,
            o_digest_4=self.digest4.status,
            o_digest_5=self.digest5.status,
            o_digest_6=self.digest6.status,
            o_digest_7=self.digest7.status,

            o_msg_length=self.msg_length.status,
            o_error_code=self.error_code.status,

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

        platform.add_source(os.path.join("deps", "opentitan", "hw", "ip", "hmac", "rtl", "hmac_pkg.sv"))
        platform.add_source(os.path.join("deps", "opentitan", "hw", "ip", "hmac", "rtl", "sha2.sv"))
        platform.add_source(os.path.join("deps", "opentitan", "hw", "ip", "hmac", "rtl", "sha2_pad.sv"))
        platform.add_source(os.path.join("deps", "opentitan", "hw", "ip", "prim", "rtl", "prim_packer.sv"))
        platform.add_source(os.path.join("deps", "opentitan", "hw", "ip", "hmac", "rtl", "hmac_core.sv"))
        platform.add_source(os.path.join("deps", "gateware", "gateware", "sha2_litex.sv"))
