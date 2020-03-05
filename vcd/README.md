VCD Parser and Analyzer
=======================

The `vcd` module contains three useful classes:

1.  `VCDParser` - a parser for `.vcd` files that supports streaming the
    vcd file for analysis purposes. Can accept one or more `VCDWatchers`.
    The parser was built referring to the IEEE SystemVerilog standard 1800-2009, Section 21.7 (Value Change Dump (VCD) files).
    It supports the following vcd file features:
    * Declarations such as:
        * the `$date` and `$time` of the vcd file
        * the `$timescale` of the vcd file
        * `$var` variables with scoped and hierarchical (XMR) paths
    * Simulation / capture data with timestamps
    The parser currently ignores:
    * `$comment` lines
    * `$dumpall`, `$dumpon`, `$dumpoff`, and `$dumpvars` in the data
1.  `VCDWatcher` - a signal watcher to be passed to `VCDParser`. It defines
    both a sensitivity list and a watched signal list. The watcher's
    `update` method will be called whenever a sensitivity list signal
    changes. It will be provided the current values of all signals on
    its watched signal list.
1.  `VCDTracker` - One or more trackers can be added to a `VCDWatcher`.
    They will be called on every watcher `update` by default, and are
    intended to be used to analyse one or more higher level transactions
    occuring in the watched data. Trackers can mark themselves as
    `finished`, after which they will no longer be called. To implement
    a tracker, `VCDTracker` **must** be subclassed, and the `start` and
    `update` methods **must** be implemented.


Credits
=======
* Original code is the [toggle count sample code](http://paddy3118.blogspot.com/2008/03/writing-vcd-to-toggle-count-generator.html) example by Donald 'Paddy' McCarthy.
* Elaborated by Gordon McGregor in 2013.
* Improved, made 3.x compatible, and packaged by Joan Touzet in 2018.
* Copied from github https://github.com/wohali/vcd_parsealyze into this repo in 2020. 


License
=======

       Copyright  2018  Joan Touzet
       Copyright  2013  Gordon McGregor

       Licensed under the Apache License, Version 2.0 (the "License");
       you may not use this file except in compliance with the License.
       You may obtain a copy of the License at

           http://www.apache.org/licenses/LICENSE-2.0

       Unless required by applicable law or agreed to in writing, software
       distributed under the License is distributed on an "AS IS" BASIS,
       WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
       See the License for the specific language governing permissions and
       limitations under the License.

