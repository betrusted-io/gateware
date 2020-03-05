#!/usr/bin/python3

import sys
import os
import argparse

parser = argparse.ArgumentParser("Populate a new simulation from template")
parser.add_argument(
    "-s", "--sim-name", help="Name of the new simulation", type=str, required=True
)

args = parser.parse_args()

sim_name = args.sim_name

if os.path.exists(sim_name):
    print('Simulation directory {} already exists, aborting.'.format(sim_name))
    sys.exit(1)

# Reason #0 for this script -- do a very targeted copy, because the template contains Rust build artifacts that we must avoid
print('Creating and copying template files...')
os.system("mkdir -p {}".format(sim_name))
os.system("mkdir -p {}/test".format(sim_name))
os.system("mkdir -p {}/test/src".format(sim_name))
os.system("cp template/dut.py {}/".format(sim_name))
os.system("cp template/top_tb.v {}/".format(sim_name))
os.system("cp -r template/test/Cargo.toml {}/test/".format(sim_name))
os.system("cp -r template/test/Makefile {}/test/".format(sim_name))
os.system("cp -r template/test/src/main.rs {}/test/src/".format(sim_name))

# Reason #1 for this script -- we always forget to rename the target binary
print('Changing target name in {}/test/Cargo.toml'.format(sim_name))
os.system("sed -i s/template/{}/g {}/test/Cargo.toml".format(sim_name, sim_name))

# Reason #2 for this script -- we need to add the new simulation to the Rust workspace
print('Adding simulation to Rust workspace (../Cargo.toml)')
os.system("sed -i '/members = \[/ a {}' ../Cargo.toml".format('\ \ \ \ \"sim/{}/test\",'.format(sim_name)))

print('Done.')
