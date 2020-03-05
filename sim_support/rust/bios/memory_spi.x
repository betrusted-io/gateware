MEMORY
{
  ROM : ORIGIN = 0x00000000, LENGTH = 32k
  SRAM : ORIGIN = 0x01000000, LENGTH = 128k
  SRAM_EXT : ORIGIN = 0x40000000, LENGTH = 16M
  FLASH : ORIGIN = 0x20500000, LENGTH = 16M
  MEMLCD: ORIGIN = 0xB0000000, LENGTH = 32k
  AUDIO:  ORIGIN = 0xE0000000, LENGTH = 4
}

REGION_ALIAS("REGION_TEXT", FLASH);
REGION_ALIAS("REGION_RODATA", FLASH);
REGION_ALIAS("REGION_DATA", SRAM);
REGION_ALIAS("REGION_BSS", SRAM);
REGION_ALIAS("REGION_HEAP", SRAM);
REGION_ALIAS("REGION_STACK", SRAM);