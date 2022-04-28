# this needs to be run on the 'dev' branch to get the correct netlist (the interrupt to the core was added there)
# this command is mainly for reference. Per Charles Papon:
# So, you can just clone https://github.com/SpinalHDL/SpinalHDL.git it will get dev by default.
# Then in the SpinalHDL repo root :
# sbt "lib/runMain spinal.lib.com.usb.udc.UsbDeviceCtrlWishboneGen"

sbt "runMain spinal.lib.com.usb.udc.UsbDeviceCtrlWishboneGen"
