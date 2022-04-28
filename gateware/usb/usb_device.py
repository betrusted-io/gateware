#
# This file is based on the usb_ohci.py in Litex
#
# Copyright (c) 2021 Dolu1990 <charles.papon.90@gmail.com>
# Copyright (c) 2021 Florent Kermarrec <florent@enjoy-digital.fr>
# SPDX-License-Identifier: BSD-2-Clause

import os

from migen import *

from litex import get_data_mod

from litex.soc.interconnect import wishbone

from migen.genlib.cdc import MultiReg
from litex.soc.interconnect.csr_eventmanager import *

import subprocess, sys

# USB OHCI -----------------------------------------------------------------------------------------

class USBDevice(Module):
    def __init__(self, platform, usb_ios, usb_clk_freq=48e6, dma_data_width=32):
        self.usb_clk_freq   = usb_clk_freq
        self.dma_data_width = dma_data_width

        self.wb_ctrl = wb_ctrl = wishbone.Interface(data_width=32)

        usb_int = Signal()
        self.submodules.ev = EventManager()
        self.ev.usb    = EventSourceProcess(edge="rising")   # rising edge triggered
        self.comb += self.ev.usb.trigger.eq(usb_int)
        self.ev.finalize()

        self.specials += Instance(self.get_netlist_name(),
            # Clk / Rst.
            i_phy_clk    = ClockSignal("usb_48"),
            i_phy_reset  = ResetSignal("usb_48"),
            i_ctrl_clk   = ClockSignal("sys"),
            i_ctrl_reset = ResetSignal("sys"),

            # Wishbone Control.
            i_io_wishbone_CYC      = wb_ctrl.cyc,
            i_io_wishbone_STB      = wb_ctrl.stb,
            o_io_wishbone_ACK      = wb_ctrl.ack,
            i_io_wishbone_WE       = wb_ctrl.we,
            i_io_wishbone_ADR      = wb_ctrl.adr,
            o_io_wishbone_DAT_MISO = wb_ctrl.dat_r,
            i_io_wishbone_DAT_MOSI = wb_ctrl.dat_w,
            i_io_wishbone_SEL      = wb_ctrl.sel,

            # USB
            i_io_usb_dp_read        = usb_ios.dp_i,
            o_io_usb_dp_write       = usb_ios.dp_o,
            o_io_usb_dp_writeEnable = usb_ios.dp_oe,
            i_io_usb_dm_read        = usb_ios.dm_i,
            o_io_usb_dm_write       = usb_ios.dm_o,
            o_io_usb_dm_writeEnable = usb_ios.dm_oe,

            # interrupt
            o_io_interrupt = usb_int,

            # unsure what this does
            i_io_power = 1,
        )

        self.add_sources(platform)

    def get_netlist_name(self):
        return "UsbDeviceWithPhyWishbone"

    def add_sources(self, platform):
        netlist_name = self.get_netlist_name()

        print(f"USB Device netlist : {netlist_name}")
        netlist_path = os.path.join("deps", "gateware", "gateware", "usb", "SpinalUsb", netlist_name + ".v")

        if not os.path.exists(netlist_path):
            self.generate_netlist()

        platform.add_source(netlist_path, "verilog")

    def generate_netlist(self):
        print(f"Generating USB Device netlist. Note this needs to be run on the 'dev' branch for it to work correctly. The pre-committed netlist is built from the correct branch, this command is mainly for reference.")
        exec_path = os.path.join("deps", "gateware", "gateware", "usb", "SpinalUsb")
        subprocess.run('sbt "runMain spinal.lib.com.usb.udc.UsbDeviceCtrlWishboneGen"', cwd=exec_path, shell=True)


class IoBuf(Module):
    def __init__(self, usbp_pin, usbn_pin, alt_ios, alt_sel, usb_pullup_pin=None):
        reset_duration_in_s = 0.1
        reset_cycles = int(32768 * reset_duration_in_s)
        reset_counter = Signal(log2_int(reset_cycles, need_pow2=False)+1, reset=reset_cycles - 1)
        usb_phy_reset = Signal(reset=1)
        self.sync.lpclk += \
            If(reset_counter != 0,
                reset_counter.eq(reset_counter - 1)
            ).Else(
                usb_phy_reset.eq(0)
            )

        # tx/rx io interface
        self.usb_tx_en = Signal()
        self.usb_p_tx = Signal()
        self.usb_n_tx = Signal()

        self.usb_p_rx = Signal()
        self.usb_n_rx = Signal()

        usb_p_t = TSTriple()
        usb_n_t = TSTriple()

        # alt mux
        mux_dp_o = Signal()
        mux_dm_o = Signal()
        mux_dp_oe = Signal()
        mux_dm_oe = Signal()
        self.comb += [
            # inputs directly through
            alt_ios.dp_i.eq(usb_p_t.i),
            alt_ios.dm_i.eq(usb_n_t.i),
            If(alt_sel,
                mux_dp_o.eq(alt_ios.dp_o),
                mux_dm_o.eq(alt_ios.dm_o),
                mux_dp_oe.eq(alt_ios.dp_oe),
                mux_dm_oe.eq(alt_ios.dm_oe),
            ).Else(
                mux_dp_o.eq(self.usb_p_tx),
                mux_dm_o.eq(self.usb_n_tx),
                mux_dp_oe.eq(self.usb_tx_en),
                mux_dm_oe.eq(self.usb_tx_en),
            )
        ]

        self.specials += usb_p_t.get_tristate(usbp_pin)
        self.specials += usb_n_t.get_tristate(usbn_pin)

        self.usb_pullup = Signal()
        if usb_pullup_pin is not None:
            self.comb += [
                usb_pullup_pin.eq(self.usb_pullup),
            ]

        #######################################################################
        #######################################################################
        #### Mux the USB +/- pair with the TX and RX paths
        #######################################################################
        #######################################################################
        usb_p_t_i = Signal()
        usb_n_t_i = Signal()
        self.specials += [
            MultiReg(usb_p_t.i, usb_p_t_i),
            MultiReg(usb_n_t.i, usb_n_t_i)
        ]
        self.comb += [
            If(self.usb_tx_en,
                self.usb_p_rx.eq(0b1),
                self.usb_n_rx.eq(0b0),
            ).Else(
                self.usb_p_rx.eq(usb_p_t_i),
                self.usb_n_rx.eq(usb_n_t_i),
            ),
            If(usb_phy_reset,
                usb_p_t.oe.eq(1),
                usb_n_t.oe.eq(1),
                usb_p_t.o.eq(0),
                usb_n_t.o.eq(0),
            ).Else(
                usb_p_t.oe.eq(mux_dp_oe),
                usb_n_t.oe.eq(mux_dm_oe),
                usb_p_t.o.eq(mux_dp_o),
                usb_n_t.o.eq(mux_dm_o),
            )
        ]
