# Gateware Modules

## Structure and Prerequisites

These are RTL description files that are meant to be instantiated as submodules
under a BaseSoC class from Litex. They exist in a separate submodule directory
to facilitate IP sharing between projects and to streamline CI integration.

Managing Python paths is painful, because everyone has their way to do it. This
project is no exception.

We assume this gateware assumes a project structure modeled around the
lxbuildenv methodology. Thus, we assume the gateware submodule is cloned
into the parent project's `deps` directory:

 `<project_root>/deps/gateware`

Within this gateware repo, production hardware descriptions are contained
in the gateware/ subdir: 

 `<project_root>/deps/gateware/gateware/<module>.py`

 Simulation testbenches in the sim/ subdir:
 
 `<project_root>/deps/gateware/sim/<module>/dut.py`
 
It is recommended to create new simulation testbenches by using the
`new_sim.py -s <module>` command in the `sim/` directory. This script manages
a couple of subtleties that ensure the Rust workspace framework built around
this simulation works correctly.

## Environment 

In order to run the `dut.py` script, we assume two items (or the latest equivalent) are in your path:

 - RISCV_TOOLS=/tools/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14
 - VIVADO=/tools/Xilinx/Vivado/2019.2

If you don't have these installed, please refer to the readme at
https://github.com/betrusted-io/betrusted-soc for how to obtain and
install these.

We also assume the presence of a stable Rust environment that targets 
the riscv32-imac target, and that the svd2rust and form packages are installed:

  - `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
  - `cargo install svd2rust`
  - `cargo install form`
  - `rustup target add riscv32imac-unknown-none-elf`

svd2rust and form are necessary to generate a peripheral access crate for each
test environment, which is a set of macros the test author can optionally
use to make the code a little bit safer/prettier.

Builds are tested on an x86_64 system running Ubuntu 18.04LTS. 

### Gateware

"Gateware" is the Litex/migen term for stuff that gets compiled LUTS and
 routing within an FPGA bitstream. 
 
 The code for gateware is located in the `gateware/` directory, and each
 .py file describes a migen `Module` that can be submoduled into a
 BaseSoC instance as a hardware peripheral. This methodology supports
 both CSR and/or wishbone attached modules.

### Simulation

The test benches for a given gateware is located in a directory names as follows:

 `sim/<gateware-root-name>/`

Where if the python module is called "zomg_mod.py", then `<gateware-root-name>` is "zomg_mod".

There is a `sim_common` directory which contains several important properties that
are inherited into every test bench. The idea is to put as much of the non-module specific
integration into `sim_common`. For example, the `csr_paging` parameter and memory
map are specified in `sim_common`, so if these parameters are changed in the target SoC
all the module simulations can be regression-tested against these changes automatically.

Within the `<gateware-root-name>` subdirectory, the following artifacts are expected:

 - A file called `dut.py`. This is the script that builds the testbench, code, and runs the simulation itself.
 It inherits SoC properties from a `sim_bench.py` file.
 - A `top_tb.v` file which wires up the test bench. It is copied to the run/ directory before integrating
   with the generated `top.v` file. Usually `top_tb.v` is pretty minimal for simple IP blocks.
 - A `test` directory which contains a Rust program. The test starts with the `run()` method. 
 - Any other helper models that are required by the test bench

The test framework essentially does a minimal setup of the runtime environment and jumps to `run()`. 
This happens within about 20us of simulation time (about 2k CPU cycles @ 100MHz, of which half 
is spent waiting for the PLL to lock).  
 
### CI

For CI, the strategy would then be to descend into every subdirectory of sim/ and
run script `dut.py -c`. The `-c` argument informs the script it should run with no GUI.

The test harness builds three signals on the top level that are mandatory:

- done, a 1-bit signal that is set when the test should be terminated
- success, a 1-bit signal that indicates the test passed when set
- report, a 16-bit signal for extra reporting to CI

The simulator writes to a `ci.vcd` file in the `run/` directory. This is automatically
parsed by the test bench to look for the `done` transition, and then based on the
value of `success` at the rising edge of `done`, the script returns either 0 for
pass, or 1 for fail.

# Methodology Notes

There are two goals of the testbenches in this repository:

 1. Create a record of the tests performed to validate a given gateware IP block.
 2. Ensure that this record is usable as dependencies change

CI integration achieves goal #2: we want to know when upstream
dependencies (e.g. Litex) change and break our testbenches, so we
don't accrue huge technical debt on the test benches. The current
problem is that Litex is very actively developed and growing, and so
it's subject to massive refactoring of core APIs that tend to break
everything. This motivates splitting out the top_tb.v and code into
"stub" files that allows for recursive search-and-replace strategies
to fix changing paths or API names.

Goal #1 is achieved by the original designer, and baked into the
testbench.  The quality and depth of coverage for the IP is not baked
into this methodology. However, typically the test vectors originate
from the simulated soft-core CPU, and the simulated CPU is responsible
for checking results and reporting errors. This is a bit faster and
more flexible than e.g. attempting to write verilog statements and
asserts that try to catch every deviation. This methodology is
preferred in part because in reality, if there is a refactor of the
wishbone bus in the Litex directory that causes subtle changes in the
bus timing that doesn't break the functionality of the IP, we are okay
with that. A verilog assert is thus a bit too aggressive and
low-level. Similarly, a verilog assert at the IP API level won't catch
problems like refactoring of the cache hierarchy in the CPU, which can
break some IP cores in subtle ways. Thus, by driving the simulation
primarily from the standpoint of the CPU, we are saying "so long as
the CPU gets the results it expects, we're probably OK, even if the
exact bus timings and reset conditions shift around by a cycle or
two because of upstream refactoring".
