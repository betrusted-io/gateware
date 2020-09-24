# Curve25519 Engine Simulation Bench

## Set up

### Tooling

The toolchain is unfortunately quite heavy to install. Unfortunately
the latest version of Xilinx tools (2020.1) will require about 100GiB
available space to install, although a large part of that is cleared
after the installation once the temporary files are removed. Older
versions can require significantly less free space (~40GiB) to
install. In addition, the Rust and Python prequisites together will
consume an additional 1-2GiB. 

1. Ensure you have Python 3.5 or newer installed.
1. Ensure you have `make` installed.
1. Download the Risc-V toolchain from https://www.sifive.com/products/tools/ and put it in your PATH.
1. Install the cross-compile target with `rustup target add riscv32imac-unknown-none-elf`
1. Go to https://www.xilinx.com/support/download.html and download `All OS installer Single-File Download`
1. Do a minimal Xilinx install to /opt/Xilinx/, and untick everything except `Design Tools / Vivado Design Suite / Vivado` and `Devices / Production Devices / 7 Series`
1. Go to https://www.xilinx.com/member/forms/license-form.html, get a license, and place it in ~/.Xilinx/Xilinx.lic

### Configuring and Compiling

The `gateware` repository assumes it is a submodule within the
[betrusted-soc](https://github.com/betrusted-io/betrusted-soc) project.

The easiest way to set up the directory structure is thus to clone the betrusted-soc
directory and then drill into the gateware simulation. By the time these instructions
are done, the setup will have consumed about 1.1GiB of additional disk space beyond
the base tools at this point.

First clone the repository, and initialize just the repositories needed. You can also do
a recursive clone but it will pull down an extra gigabyte of unrelated code.

```
git clone git@github.com:betrusted-io/betrusted-soc.git
cd betrusted-soc/deps
git submodule init
git submodule update gateware
cd gateware/sim/curve_engine/testbench
git submodule init
git submodule update curve25519-dalek engine25519-as
```

You now need to reconfigure the workspace to run in a non-CI
environment. Tell Rust that we're only going to run this simulation --
and ignore all the other simulations in the workspace -- by copying the
minimal workspace template for the workspace.

```
cd .. # you should now be in gateware/sim/curve_engine
cp minimal-workspace-template ../../Cargo.toml
```

Now you should be able to run the test script. Test that everything is
working first by running it in CI mode using the `-c` operation.

```
./dut.py -c
```

The first run will take some time to run as this script will
initialize a few other submodules, pull down Rust crates for the
initial build, and so forth.

To pop up the interactive waveform browser, just run `./dut.py`
without the `-c` argument.

## Test Architecture

The general strategy for testing is to use curve25519-dalek to
generate test vectors for arithmetic primitives, and write them
to a binary record format which is incorporated into the
testbench as a ROM that is mapped to a region of memory.

The binary record format is [documented
here](https://github.com/betrusted-io/curve25519-dalek/blob/b757e6475252af74677eced02aadd07373389ac9/src/field.rs#L512). A test record includes both the microcode used to generate the data, as
well as inputs and their associated "correct" outputs. Below is a
summary of the format.

```
  0x0 0x56454354   "VECT" - indicates a valid vector set
  0x4 [31   load address   16]                                 [15  length of code  0]
  0x8 [31  N registers to load  27] [26 W window 23] [22  X number of vectors sets  0]
  0xC [microcode] (variable length)
  [ padding of 0x0 until 0x20 * align ]
  0x20*align [X test vectors]
```

Records can repeat; as long as "VECT" is found, the test framework
will attemp to load and run the test.  Thus, end of records MUST end
with a word that is NOT 0x56454354. This is because the ROM read can
"wrap around" and the test will run forever. By convention, we use
0xFFFF_FFFF to indicate this.

For each test, vectors are stored with the following convention:
* Check result is always in r31
* N Registers loaded starting at r0 into engine window W

The testbench then reads the test vectors from the ROM and
attempts to perform the computations described in the test vectors.
It compares the result of the computation against the "correct"
results stored in the test vector ROM.

After these vectors are run, the testbench has some additional code
that attempts to write test values to all the microcode and register
offsets to make sure there are no mix-ups in that wiring; this test
takes a long time to run, and usually passes, which is why it's at the end.

### Code Structure (if you can call it that)

Individual tests are incorporated into the `make_vectors` routine
as in-line functions within the `make_vectors` function (how awful
is that?).

The functions are called [at the very end of the
routine](https://github.com/betrusted-io/curve25519-dalek/blob/b757e6475252af74677eced02aadd07373389ac9/src/field.rs#L1266),
and capped with the ending value.

Thus adding a test consists of defining a new in-line function
inside the `make_vectors` routine, and then adding it to the sequence
of `test_*` calls at the end. It's recommended to call the function
you're working on first in the sequence, so you don't have to wait through
a long simulation sequence to get to your code.

