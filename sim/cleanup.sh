#!/bin/sh

echo "cleaning up subdirs:"
find . -maxdepth 1 -type d \( ! -name . \) -exec bash -c "cd '{}' && pwd && cargo clean" \;
echo "cleaning up Rust target dir"
rm -rf ../target
