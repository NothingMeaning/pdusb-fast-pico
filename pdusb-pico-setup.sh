#!/bin/bash
usage()
{
  echo "$0 [options]"
  echo "\t -x   Debug output each command "
  echo "\t -g   Use github instead of gitee. Gitee used by default "
  echo "\t -b   Build the example output. Only clone repo by default"
  echo "\t -o   Disable Build openocd too."
}

# Exit on error
#set -e
# Number of cores when running make
NCPU=$(cat /proc/cpuinfo  2>/dev/null | grep "^processor" 2>/dev/null| wc -l 2>/dev/null)
if [ -z "$NCPU" ] ||  [ $NCPU -ge 12 ] ;then
    NCPU=4
fi

JNUM=$((NCPU/2))
if [ $JNUM -lt 1 ] || [ $JNUM -gt 10 ] ; then JNUM=1 ; fi

# Where will the output go?
OUTDIR="$(pwd)/pico"

# Install dependencies
GIT_DEPS="git"
SDK_DEPS="cmake gcc-arm-none-eabi gcc g++"
OPENOCD_DEPS="gdb-multiarch automake autoconf build-essential texinfo libtool libftdi-dev libusb-1.0 libusb-1.0-0-dev"
# Wget to download the deb
VSCODE_DEPS="wget"
UART_DEPS="minicom"
SKIP_VSCODE=1
SKIP_OPENOCD=0
SKIP_UART=1
USE_GITEE=1
DO_BUILD=0

while getopts 'xbgo' OPTION; do
  case "$OPTION" in
    b)
      DO_BUILD=1
      ;;
    g)
      USE_GITEE=0
      ;;
    o)
	    SKIP_OPENOCD=1
	    ;;
    x)
      set -x
      ;;
    h)
        usage
        exit 0
      ;;
    ?)
      usage
      exit 1
      ;;
  esac
done
shift "$(($OPTIND -1))"

if grep -q Raspberry /proc/cpuinfo; then
    echo "Running on a Raspberry Pi"
else
    echo "Not running on a Raspberry Pi. Use at your own risk!"
fi

# Build full list of dependencies
DEPS="$GIT_DEPS $SDK_DEPS"

if [[ "$SKIP_OPENOCD" == 1 ]]; then
    echo "Skipping OpenOCD (debug support)"
else
    DEPS="$DEPS $OPENOCD_DEPS"
fi

if [[ "$SKIP_VSCODE" == 1 ]]; then
    echo "Skipping VSCODE"
else
    DEPS="$DEPS $VSCODE_DEPS"
fi

set -x
echo "Installing Dependencies"
sudo apt update
sudo apt install -y $DEPS

echo "Creating $OUTDIR"
# Create pico directory to put everything in
mkdir -p $OUTDIR
cd $OUTDIR

# Clone sw repos
if [ "x$USE_GITEE" = "x1" ] ;then
	GITHUB_PREFIX="https://gitee.com/pdusb/pdusb-fast-"
else
GITHUB_PREFIX="https://github.com/raspberrypi/"
fi
GITHUB_SUFFIX=".git"
SDK_BRANCH="master"

echo "Checkout repo from $GITHUB_PREFIX"

for REPO in sdk examples extras playground
do
    DEST="$OUTDIR/pico-$REPO"

    if [ -d $DEST ]; then
        echo "$DEST already exists so skipping"
    else
        REPO_URL="${GITHUB_PREFIX}pico-${REPO}${GITHUB_SUFFIX}"
        echo "Cloning $REPO_URL"
        git clone -b $SDK_BRANCH $REPO_URL pico-$REPO

        # Any submodules
        cd $DEST
	if [ "x$USE_GITEE" = "x1" ]  && [ -e ./.gitmodules ] ;then
		sed -i 's+https://github.com/raspberrypi/tinyusb.git+https://gitee.com/pdusb/pdusb-fast-pico-tinyusb.git+g' .gitmodules 2>/dev/null
		sed -i 's+https://git.savannah.nongnu.org/git/lwip.git+https://gitee.com/pdusb/pdusb-fast-lwip.git+g' .gitmodules 2>/dev/null
		sed -i 's+git://git.savannah.nongnu.org/lwip.git+https://gitee.com/pdusb/pdusb-fast-lwip.git+g' .gitmodules 2>/dev/null
	fi
        git submodule update --init
        cd $OUTDIR

        # Define PICO_SDK_PATH in ~/.bashrc
        VARNAME="PICO_${REPO^^}_PATH"
        echo "Adding $VARNAME to ~/.bashrc"
        echo "export $VARNAME=$DEST" >> ~/.bashrc
        export ${VARNAME}=$DEST
    fi
done

cd $OUTDIR

# Pick up new variables we just defined
source ~/.bashrc

# Build a couple of examples
if [ $DO_BUILD -eq 1 ] ;then
    cd "$OUTDIR/pico-examples"
    mkdir build
    cd build
    cmake ../ -DCMAKE_BUILD_TYPE=Debug

    for e in blink hello_world
    do
        echo "Building $e"
        cd $e
        make -j$JNUM
        cd ..
    done
fi
cd $OUTDIR

# Picoprobe and picotool
for REPO in picoprobe picotool
do
    DEST="$OUTDIR/$REPO"
    REPO_URL="${GITHUB_PREFIX}${REPO}${GITHUB_SUFFIX}"
    git clone $REPO_URL $REPO

    # Build both
    cd $DEST
    mkdir build
    if [ $DO_BUILD -eq 1 ] ;then
        cd build
        cmake ../
        make -j$JNUM

        if [[ "$REPO" == "picotool" ]]; then
            echo "Installing picotool to /usr/local/bin/picotool"
            sudo cp picotool /usr/local/bin/
        fi
    fi

    cd $OUTDIR
done

if [ -d openocd ]; then
    echo "openocd already exists so skipping"
    SKIP_OPENOCD=1
fi

if [[ "$SKIP_OPENOCD" == 1 ]]; then
    echo "Won't build OpenOCD"
else
    # Build OpenOCD
    echo "Building OpenOCD"
    cd $OUTDIR
    # Should we include picoprobe support (which is a Pico acting as a debugger for another Pico)
    INCLUDE_PICOPROBE=1
    OPENOCD_BRANCH="rp2040"
    OPENOCD_CONFIGURE_ARGS="--enable-ftdi --enable-sysfsgpio --enable-bcm2835gpio"
    if [[ "$INCLUDE_PICOPROBE" == 1 ]]; then
        OPENOCD_BRANCH="picoprobe"
        OPENOCD_CONFIGURE_ARGS="$OPENOCD_CONFIGURE_ARGS --enable-picoprobe"
    fi

    git clone "${GITHUB_PREFIX}openocd${GITHUB_SUFFIX}" -b $OPENOCD_BRANCH --depth=1 openocd
    if [ $DO_BUILD -eq 1 ] ;then
        cd openocd
        ./bootstrap
        ./configure $OPENOCD_CONFIGURE_ARGS
        make -j$JNUM
        sudo make install
    fi
fi

cd $OUTDIR

# Liam needed to install these to get it working
EXTRA_VSCODE_DEPS="libx11-xcb1 libxcb-dri3-0 libdrm2 libgbm1 libegl-mesa0"
if [[ "$SKIP_VSCODE" == 1 ]]; then
    echo "Won't include VSCODE"
else
    if [ -f vscode.deb ]; then
        echo "Skipping vscode as vscode.deb exists"
    else
        echo "Installing VSCODE"
        if uname -m | grep -q aarch64; then
            VSCODE_DEB="https://aka.ms/linux-arm64-deb"
        else
            VSCODE_DEB="https://aka.ms/linux-armhf-deb"
        fi

        wget -O vscode.deb $VSCODE_DEB
        sudo apt install -y ./vscode.deb
        sudo apt install -y $EXTRA_VSCODE_DEPS

        # Get extensions
        code --install-extension marus25.cortex-debug
        code --install-extension ms-vscode.cmake-tools
        code --install-extension ms-vscode.cpptools
    fi
fi

# Enable UART
if [[ "$SKIP_UART" == 1 ]]; then
    echo "Skipping uart configuration"
else
    sudo apt install -y $UART_DEPS
    echo "Disabling Linux serial console (UART) so we can use it for pico"
    sudo raspi-config nonint do_serial 2
    echo "You must run sudo reboot to finish UART setup"
fi
