mtca4u_installer is a meta package which will install the mtca4u sub packages. Currently these are
- MtcaMappedDevice (aka libdevMap from llrfCtrl/toolsForServer/desy-libs/libs-src)
- QtHardMon
- MotorDriverCard
The installation is done from source code. You need the C++ development tools (compiler etc.) installed on your
machine.

Requirements:
You need cmake (at least version 2.8.3), which is used as the build system.
In addition you need the Subversion version control client installed (svn).
The libraries use C++ Boost, so you need the development libraries.
For the unit tests you need the Boost testing framework in addition. They are optional and not required to build the packages.
To build the QtHardMon, you also need the Qt4 development libraries installed. For the plotting functionality
QWT 6 is required in addition.
MotorDriverCard reqires the pugixml parser (version 1.4 or higher, including Findpugixml.cmake, which is in the DESY version.
  See (*) below the dependeny list.)

You have to install these packages with the package manager of your Linux distribution before you can proceed
with the installation. The list below shows the software component and the Ubuntu 12.4 package name in
parentheses. You can install it using "sudo apt-get install PackageName". For other distributions the
package name and install mechanism can be different.

- CMake (cmake)
- Subversion (subversion)
- Boost (libboost-dev)
- Boost Test Library (libboost-test-dev) // Unit tests only, optional
- Boost Filesystem (libboost-filesystem-dev) // Unit tests only, optional
- Boost Thread (libboost-thread-dev) // MotorDriverCard only
- Qt4 development libraries (libqt4-dev) // QtHardMon only
- QWT development libraries (libqwt-dev) // QtHardMon plotting only, optional
- pugixml (libpugixml-dev)(*) // MotorDriverCard only (**)

In Ubuntu you can install libboost-all-dev, which installs all boost development packages, if you don't want to
hand-pick the boost dependencies.

Recommended to get documentation:
- Doxygen (doxygen)

(*) You need the libpugixml-dev libraries with Findpugixml.cmake. They are provided in the DESY version of the package.
For Ubuntu 12.4 and 14.4 
this is available from the DESY debian package servers http://doocspkgs.desy.de/pub/doocs (DESY internal)
and http://doocs.desy.de/pub/doocs (from outside of DESY). For all other cases it has to be installed from
the source code, which can be found at http://www.desy.de/~killenb/pugixml-desy/.
The MTCA4U installer can automatically install pugixml for you. Just "set(INSTALL_PUGIXML true)" in the CMakeLists.txt.
In this case you also need the bazaar (bzr) version control package installed.

(**) The MtcaMapped device will also be changed to XML mapping files, so pugixml will become a general requirement soon.

Download:
You can download the source code of the mtca4u meta package directly from the source code repository:
(The name of the download directory on your hard drive, which is the last argument of the command, can be chosen freely.
 In this ReadMe we use mtca4u_installer.)

~> svn checkout https://svnsrv.desy.de/public/mtca4u/mtca4u_installer/trunk mtca4u_installer

Installation:
To perform the default installation to your home directory ($HOME/mtca4u) just run the install.sh script in 
the mtca4u_installer directory. This will download, compile and install the latest release version of mtca4u.

~/mtca4u_installer> ./install.sh

In case you want to install to a different directory adapt the MTCA4U_BASE_DIR in the CMakeLists.txt file
before executing the script. For installations on network drives (nfs, afs) which can be mounted from different
architectures it is recommended to add the architecture to the MTCA4U_BASE_DIR, for instance 
set(MTCA4U_BASE_DIR "$ENV{HOME}/mtca4u/Ubuntu-12.04-x86_64")

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

In the mtca4u_installer directory:
~/mtca4u_installer> mkdir build
~/mtca4u_installer> cd build
~/mtca4u_installer/build> cmake ..

Step 3:
Run the installation.

Just type 'make' in the build directory.
mtca4u_installer/build> make

After a successful installation you can remove the build directory.

Expert installation:

You can also create custom versions of the sub packages to install. For instance you do not want all the HEAD
versions but only the HEAD of the MtcaMappedDevice sub package, and all the other versions from the latest
release (see example 1). Or you might want to skip QtHardMon in case the Qt4 development environment is not available (example 2).
To perform this installation you have to create a new MTCA_VERSION_*.cmake file in the cmakemodules
directory, usually by copying and adapting an existing one. Another use case is skipping the MotorDriverCard if you don't
want to bother with installing pugixml.

Example 1:
In this example we use the 00.02.00 version of mtca4u and set the MtcaMappedDevice version to HEAD. We chose the 
rather lengthy, but descriptive name/version string  "00.02.00_with_MtcaMappedDevice_HEAD".
Note that the version string has to start with the version number so the internal parser runs successfully.

~/mtca4u_installer/cmakemodules> cp MTCA_VERSION_00.02.00.cmake MTCA_VERSION_00.02.00_with_MtcaMappedDevice_HEAD.cmake

Now open the new file in a text editor and change
set(MtcaMappedDevice_VERSION "00.02.00")
to
set(MtcaMappedDevice_VERSION "HEAD")

Afterwards exit the CMakeLists.txt and set the MTCA4U_VERSION to "00.02.00_with_MtcaMappedDevice_HEAD". Now
just run install.sh. The installation will go to $/HOME/mtca4u/00.02.00_with_MtcaMappedDevice_HEAD (if you did not
change the MTCA4U_BASE_DIR).

Note: The released versions of mtca4u contain a combination of versions of the sub packages which are known to
work together, as well as all the HEAD versions should work together. When creating your own combination of sub packages
this might not be the case. Or it might break later, when the HEAD of a package is evolving.

Example 2:
You want to exclude QtHardMon from the installation. Copy the version file MTCA_VERSION_00.02.00.cmake file to
00.02.00_without_QtHardMon.cmake . Open the latter and simply delete or uncomment the 'set(QtHardMon_VERSION 00.02.02)' line.
Now adapt the CMakeLists.txt as described in example 1.
