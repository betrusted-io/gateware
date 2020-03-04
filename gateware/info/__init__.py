"""
Module for info embedded in the gateware / board.
"""

from migen import *

from litex.build.generic_platform import ConstraintError
from litex.soc.interconnect.csr import *
from litex.soc.cores import dna
from litex.soc.cores import xadc

from gateware.info import git
from gateware.info import platform as platform_info


class Info(Module, AutoCSR):
    def __init__(self, platform, target_name, analog_pads=None):
        self.submodules.dna = dna.DNA()
        self.submodules.git = git.GitInfo()
        target = target_name.lower()[:-3]
        self.submodules.platform = platform_info.PlatformInfo(platform.name, target)

        if "xc7" in platform.device:
            self.submodules.xadc = xadc.XADC(analog_pads)
            if analog_pads != None:
                self.xadc.expose_drp()

