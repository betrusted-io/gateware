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

from litex.build.io import SDRTristate

import subprocess, sys

# USB OHCI -----------------------------------------------------------------------------------------

class USBDevice(Module):
    def __init__(self, platform, pads, usb_clk_freq=48e6, dma_data_width=32):
        self.pads           = pads
        self.usb_clk_freq   = usb_clk_freq
        self.dma_data_width = dma_data_width

        self.wb_ctrl = wb_ctrl = wishbone.Interface(data_width=32)
        self.wb_dma  = wb_dma  = wishbone.Interface(data_width=dma_data_width)

        self.interrupt = Signal()

        # # #

        usb_ios = Record([
            ("dp_i",  1), ("dp_o",  1), ("dp_oe", 1),
            ("dm_i",  1), ("dm_o",  1), ("dm_oe", 1),
        ])

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

            # unsure what this does
            i_io_power = 1,
        )
        self.specials += SDRTristate(
            io = pads.d_p,
            o  = usb_ios.dp_o,
            oe = usb_ios.dp_oe,
            i  = usb_ios.dp_i,
        )
        self.specials += SDRTristate(
            io = pads.d_n,
            o  = usb_ios.dm_o,
            oe = usb_ios.dm_oe,
            i  = usb_ios.dm_i,
        )
        # k_state is used by the power management system to detect if we should force CPU power on
        self.k_state = Signal()
        self.comb += [
            self.k_state.eq(~usb_ios.dm_i & usb_ios.dp_i)
        ]

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
        print(f"Generating USB Device netlist")
        exec_path = os.path.join("deps", "gateware", "gateware", "usb", "SpinalUsb")
        subprocess.run('sbt "runMain spinal.lib.com.usb.udc.UsbDeviceCtrlWishboneGen"', cwd=exec_path, shell=True)


