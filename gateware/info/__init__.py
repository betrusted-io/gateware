"""
Module for info embedded in the gateware / board.
"""

from migen import *

from litex.build.generic_platform import ConstraintError
from litex.soc.interconnect.csr import *
from litex.soc.cores import xadc

from gateware.info import git
from gateware.info import platform as platform_info
from gateware.info import dna  # use our local version of DNA, the upstream version broke in 2022.08

class Info(Module, AutoCSR):
    def __init__(self, platform, target_name, use_xadc=True, analog_pads=None):
        self.submodules.dna = dna.DNA()
        self.submodules.git = git.GitInfo()
        target = target_name.lower()[:-3]
        self.submodules.platform = platform_info.PlatformInfo(platform.name, target)

        if use_xadc:
            if "xc7" in platform.device:
                self.submodules.xadc = xadc.XADC(analog_pads)
                if analog_pads != None:
                    self.xadc.expose_drp()

