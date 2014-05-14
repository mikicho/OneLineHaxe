#!/bin/bash

# Die function, Taken from http://stackoverflow.com/questions/64786/error-handling-in-bash
function error_exit
{
	PROGNAME=$(basename $0)
    echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
    exit 1
}

###

if [ ! -n "$2" ]
then
  error_exit "Usage: `basename $0` haxe-tag neko-tag (for example, 3.1.3 v2-0 or development master)"
fi

HAXETAG=$1
NEKOTAG=$2

###

echo ""
echo "Creating 'haxeinstall' directory..."
mkdir -p haxeinstall || error_exit "Failed to create 'haxeinstall' directory."
cd haxeinstall

###

echo ""
echo "Installing dependencies for Haxe and Neko with apt-get. "
echo "We will need your password..."

sudo apt-get update
sudo apt-get install make libzip-dev ocaml git-core libgc-dev libpcre3-dev apache2-threaded-dev libsqlite3-dev camlp4 || error_exit "ERROR: Failed to install dependencies with apt-get"

###

echo ""
echo "About to checkout, compile and install Haxe Git $HAXETAG"
read -p "Press Enter to continue"

echo "Checkout Haxe $HAXETAG tag from Github"

if [ -d "haxe" ]; then
  # It exists, so checkout and update
  cd haxe
  git reset --hard || error_exit "Failed to run 'git reset --hard' in haxe directory"
  git checkout development || error_exit "Failed to run 'git checkout development' in haxe directory"
  git fetch || error_exit "Failed to run 'git pull' in haxe directory"
  git checkout $HAXETAG || error_exit "Failed to run 'git checkout $HAXETAG' in haxe directory"
  git submodule init || error_exit "Failed to run 'git submodule init' in haxe directory"
  git submodule update || error_exit "Failed to run 'git submodule update' in haxe directory"
else
  # It does not exist, so clone
  git clone --branch $HAXETAG --depth=1 git://github.com/HaxeFoundation/haxe.git || error_exit "Failed to clone haxe source from Github"
  cd haxe
  git submodule init || error_exit "Failed to run 'git submodule init' in haxe directory"
  git submodule update || error_exit "Failed to run 'git submodule update' in haxe directory"
fi

killall haxe

echo "Compile Haxe"
make clean all || error_exit "Failed to run 'make clean all' on haxe codebase"
echo "Install Haxe"
sudo make install || error_exit "Failed to run 'sudo make install' on haxe codebase"
cd ..

haxe

echo ""
echo "Haxe Installed"

###

echo ""
echo "About to checkout, compile and install Neko Git $NEKOTAG"
echo "You may have to press 's' a few times to skip optional extra things."
read -p "Press Enter to continue"

echo "Checkout Neko from Git / $NEKOTAG"

if [ -d "neko" ]; then
  # It exists, so checkout and update
  cd neko
  git reset --hard || error_exit "Failed to run 'git reset --hard' in neko directory"
  git fetch || error_exit "Failed to run 'git pull' in neko directory"
  git checkout $NEKOTAG || error_exit "Failed to run 'git checkout $NEKOTAG' in haxe directory"
else
  # It does not exist, so clone
  git clone --branch $NEKOTAG --depth=1 git://github.com/HaxeFoundation/neko.git || error_exit "Failed to checkout neko source from Github"
  cd neko
fi


echo "Compile Neko"
make clean all || error_exit "Failed to run 'make clean all' on neko codebase"
echo "Install Neko"
sudo make install || error_exit "Failed to run 'sudo make install' on neko codebase"
cd ..

neko

echo ""
echo "Neko Installed..."

###

echo ""
echo "Haxelib setup" || error_exit "Failed to setup haxelib"

haxelib setup

###

echo ""
echo "About to update haxelib"
sudo haxelib selfupdate

###

cd ..
echo "Done"
echo "Type [haxe], [neko], and [haxelib] and at a command line to check they're good to go"

