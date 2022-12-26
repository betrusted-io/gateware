#! /usr/bin/env python3

import argparse
import linecache

def main():
    parser = argparse.ArgumentParser(description="Extract verilog blocks from Xsim error messages")
    parser.add_argument(
        "--file", required=True, help="Log file for parsing", type=str
    )
    args = parser.parse_args()

    with open(args.file, "r") as f:
        for line in f:
            if "F:/largework" in line:
                # remove the leading 'INFO: ', and trailing newline
                vpath = line.rstrip().removeprefix('INFO: ')
                # now extract the line number at the end
                vinfo = vpath.rsplit(':', 1)
                print("{}:{}".format(vinfo[0], vinfo[1]))
                line_number = int(vinfo[1])
                one_line = linecache.getline(vinfo[0], line_number).rstrip()
                starting_indent_level = len(one_line) - len(one_line.lstrip(' '))
                should_print = True
                first_line = True
                while should_print:
                    print("   ", one_line)
                    line_number += 1
                    one_line = linecache.getline(vinfo[0], line_number).rstrip()
                    indent_level = len(one_line) - len(one_line.lstrip(' '))
                    if indent_level <= starting_indent_level:
                        should_print = False
                        if first_line is False:
                            print("   ", one_line)
                    first_line = False


if __name__ == "__main__":
    main()
    exit(0)
