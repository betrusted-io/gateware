all: bios.bin

%.bin: %.elf
	riscv64-unknown-elf-objcopy -O binary target/riscv32imac-unknown-none-elf/release/sim-bios $@

bios.elf: memory.x test/src/lib.rs src/main.rs
	cargo build --release
	riscv64-unknown-elf-objdump -d target/riscv32imac-unknown-none-elf/release/sim-bios > sim-bios.S
