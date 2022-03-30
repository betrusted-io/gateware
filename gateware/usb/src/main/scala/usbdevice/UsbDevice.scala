/*
 * SpinalHDL
 * Copyright (c) Dolu, All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3.0 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library.
 */

package usblib

import spinal.core._
import spinal.lib._
/*import spinal.lib.bus.bmb.BmbParameter
import spinal.lib.bus.wishbone._
import spinal.lib.com.usb.phy.{UsbDevicePhyNative, UsbPhyFsNativeIo}*/
import spinal.lib.com.usb.udc._

object UsbDevice extends App {
  println("hello world")
  /*
  def main(args: Array[String]) {
    println("hello world")
    UsbDeviceCtrlWishboneGen
  }*/
}
 /*

//Define a custom SpinalHDL configuration with synchronous reset instead of the default asynchronous one. This configuration can be resued everywhere
object UsbSpinalConfig extends SpinalConfig(defaultConfigForClockDomains = ClockDomainConfig(resetKind = SYNC))

//Generate the UsbDevice's Verilog using the above custom configuration.
object UsbTopLevelVerilogWithCustomConfig {
  def main(args: Array[String]) {
    UsbSpinalConfig.generateVerilog(new UsbDevice)
  }
}*/