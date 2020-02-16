You need to point to the RISCV toolchain and have Ubuntu 16.04 for this.

# Tested Configurations

## Ubuntu 16.04 x86_64 host

- Status: Working
- Build dependencies: `build-essential git autotools texinfo bison flex libgmp-dev libmpfr-dev libmpc-dev gawk libz-dev libssl-dev python unzip libncurses5-dev`
- Additional build deps for QEMU: `libglib2.0-dev libpixman-1-dev`
- Additional build deps for Spike: `device-tree-compiler`

## Building for vc707 dev board
```sh
make -j4 BOARD=vc707devkit_nopci
```

When the build is finished write the image to sd card.
```sh
make DISK=/dev/whereisSDcard vc707-sd-write
```
