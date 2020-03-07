#!/usr/bin/python3

import argparse

def main():
    parser = argparse.ArgumentParser(description="Convert bin to verilog hex file")
    parser.add_argument(
        "-f", "--file", default="betrusted-soc.bin", help="Input "
    )

    args = parser.parse_args()

    with open(args.file, "rb") as f:
        binfile = f.read()

        for b in binfile:
            print("{:02x}".format(b))


if __name__ == "__main__":
    main()

