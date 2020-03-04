# Gateware Modules

## Structure and Prerequisites

These are RTL description files that are meant to be instantiated as submodules
under a BaseSoC class from Litex. They exist in a separate submodule directory
to facilitate IP sharing between projects and to streamline CI integration.

Managing Python paths is painful, because everyone has their way to do it. This
project is no exception.

We assume this gateware assumes a project structure modeled around the
lxbuildenv methodology. Thus, we assume the gateware submodule is located
as follows:

 `<project_root>/deps/gateware/sim/<sim_proj>/sim.py`
 
Where this "gateware" repository is cloned into `<project_root>/deps/`

In order to run the script, we assume two items are in your path:

 - RISCV_TOOLS=/tools/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14
 - VIVADO=/tools/Xilinx/Vivado/2019.2

If you don't have these installed, please refer to the readme at
https://github.com/betrusted-io/betrusted-soc for how to obtain and
install these.

## Gateware

The code for gateware is located in the gateware/ directory.

## Simulation

The test benches for a given gateware is located in a directory names as follows:

 `sim/<gateware-root-name>/`

Where if the python module is called "zomg_mod.py", then `<gateware-root-name>` is "zomg_mod".

Within the `<gateware-root-name>` subdirectory, the following artifacts are expected:

 - A file called `sim.py`. This is the script that builds the testbench, code, and runs the simulation itself
 - A `top_tb.v` file which wires up the test bench. It is copied to the run/ directory before integrating
   with the generated `top.v` file. Usually `top_tb.v` is pretty minimal for simple IP blocks.
 - Either a `stub.c` or a `stub.rs` file which contains any program code necessary to run the simulation
 - Any other helper models that are required by the test bench

For CI, the strategy would then be to descend into every subdirectory of sim/ and
run the `sim.py` script within.

## Methodology

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
