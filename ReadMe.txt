mtca4u is a meta package which will install its sub packages. Currently these are
- MtcaMappedDevice (aka libdevMap from llrfCtrl/toolsForServer/desy-libs/libs-src)
- QtHardMon
The installation is done from source code. You need the C++ development tools (compiler etc.) installed on your
machine.

Requirements:
You need cmake (at least version 2.8.3), which is used as the build system.
In addition you need the Subversion version control client installed (svn).
To build the QtHardMon, you also need the Qt4 development libraries installed. For the plotting functionality
QWT 6 is required in addition.

You have to install these packages with the package manager of your Linux distribution before you can proceed
with the installation. The list below shows the software component and the Ubuntu 12.4 package name in
parentheses. You can install it using "sudo apt-get install PackageName". For other distributions the
package name and install mechanism can be different.

- CMake (cmake)
- Subversion (subversion)
- Qt4 development libraries (libqt4-dev)
- QWT development libraries (libqwt-dev)

Download:
You can download the source code of the mtca4u meta package directly from the source code repository:
(The name of the download directory on your hard drive can be chosen freely. In this ReadMe we use mtca4u_source.)

~> svn checkout https://svnsrv.desy.de/public/mtca4u/mtca4u/trunk mtca4u_source

Installation:
To perform the default installation to your home directory ($HOME/mtca4u) just run the install.sh script in 
the mtca4u source directory. This will download, compile and install the latest release version of mtca4u.

~/mtca4u_source> ./install.sh

In case you want to install to a different directory adapt the  MTCA4U_BASE_DIR in the CMakeLists.txt file
before executing the script.

Executing the HardMon:
Just execute $HOME/mtca4u/[MTCA4U_VERSION]/QtHardMon/[QT_HARD_MON_VERSION]/bin/QtHardMon. The full path with the 
correct versions for MTCA4U_VERSION and QT_HARD_MON_VERSION is shown by the install command in the line:
-- Set runtime path of "/full/path/to/QtHardMon" to "..."

You might want to add $HOME/mtca4u/[MTCA4U_VERSION]/QtHardMon/[QT_HARD_MON_VERSION]/bin to your 
search path, so you can just call 'QtHardMon'. For Bash you can add the following line to your $HOME/.bashrc :
export PATH=${PATH}:${HOME}/mtca4u/[MTCA4U_VERSION]/QtHardMon/[QT_HARD_MON_VERSION]/bin

Advanced installation:

Step 1: Specify installation directory and version

The CMakeLists.txt file contains the information of the install directory and the version to be installed.
You can chose one of the tagged releases of mtca4u or the latest HEAD of all sub packages. The HEAD version usually
is only needed by developers or if you want a feature which is not in a release version yet. For production
systems (e.g. servers used at the accelerator) you normally want a tagged version.
For information about the available releases please refer to Releases.txt.

The installation will always happen into a sub directory with the mtca4u version. Sub packages will be installed
into a further sub directory with version number.
Example: You specify /home/dummyuser/mtca4u as MTCA4U_BASE_DIR and want to install version 00.02.00.
This comes with QtHardMon 00.02.02, which will be installed to  /home/dummyuser/mtca4u/00.02.00/QtHardMon/00.02.02


Step 2: Configuration
Create a build directory and run cmake. cmake now reads your system environment and creates a Makefile for you.

In the mtca4u source directory:
~/mtca4u_source> mkdir build
~/mtca4u_source> cd build
~/mtca4u_source/build> cmake ..

Step 3:
Run the installation.

Just type 'make' in the build directory.
mtca4u_source/build> make

After a successful installation you can remove the build directory.

Expert installation:

You can also create custom versions of the sub packages to install. For instance you do not want all the HEAD
versions but only the HEAD of the MtcaMappedDevice sub package, and all the other versions from the latest
release. To perform this installation you have to create a new MTCA_VERSION_*.cmake file in the cmakemodules
directory, usually by copying and adapting an existing one.

Example:
In this example we use the 00.02.00 version of mtca4u and set the MtcaMappedDevice version to HEAD. We chose the 
rather lengthy, but descriptive name/version string  "00.02.00_with_MtcaMappedDevice_HEAD".

~/mtca4u_source/cmakemodules> cp MTCA_VERSION_00.02.00.cmake MTCA_VERSION_00.02.00_with_MtcaMappedDevice_HEAD.cmake

Now open the new file in a text editor and change
set(MtcaMappedDevice_VERSION "00.02.00")
to
set(MtcaMappedDevice_VERSION "HEAD")

Afterwards exit the CMakeLists.txt and set the MTCA4U_VERSION to "00.02.00_with_MtcaMappedDevice_HEAD". Now
just run install.sh. The installation will go to $/HOME/mtca4u/00.02.00_with_MtcaMappedDevice_HEAD (if you did not
change the MTCA4U_BASE_DIR).

Note: The released versions of mtca4u contain a combination of versions of the sub packages which are known to
work together, es well all the HEAD version should work together. When creating your own combination of sub packages
this might not be the case. Or it might break later, when the HEAD of a package is evolving.
