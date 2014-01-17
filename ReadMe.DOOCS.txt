Using MTCA4U with DOOCS

-------------
Installation:
-------------
If you want to package your DOOCS server as a Debian package, you have to use the Debian packages for mtca4u. A simple
~> sudo apt-get install dev-mtca4u
should do the trick.

In case you have no root privileges or want the HEAD version, which is never packaged, you should have a look at the 'Manual installation' section below. Note that you cannot build Debian packages of your server in this case.

-----------------------
Adapting your Makefile:
-----------------------
MTCA4U comes with an include file for Makefiles, called MTCA4U.CONFIG, which is located in /usr/share/mtca4u (or the installation directory if you did manual installation, for instance ${HOME}/mtca4u/${DOOCSARCH}/[MTCA4U_VERSION]).
For each subpackage which contains a library (currently MtcaMappedDevice and MotorDriverCard) it provides the variables  ${SUBPACKAGE}_INCLUDE_FLAGS,  ${SUBPACKAGE}_LIB_FLAGS and  ${SUBPACKAGE}_RUNPATH_FLAGS, which you add to your compiler and linker flags, respectively.

Example:
CPPFLAGS += $(MtcaMappedDevice_INCLUDE_FLAGS)
LDFLAGS +=  $(MtcaMappedDevice_LIB_FLAGS) $(MtcaMappedDevice_RUNPATH_FLAGS)

The names for the compiler and linker flags might differ in your Makefile. The important thing is that the include flags are only needed for the compile step, the lib flags only at link time.

Note: The previous solution with MTCA4U_LIB_FLAGS was abandonned because one only should link against the necessary libraries, not all libraries which are provided by the MTCA4U.

Information about the RUNPATH_FLAGS:

MTCA4U links as a  dynamic library, which means the libraries have to be found at run time. This can be accomplished in three different ways:
1.) By installing the libraries to a path which is automatically searched by the system, like /usr/lib
2.) By setting the LD_LIBRARY_PATH to include the directory which contains the library
3.) By setting the RUNPATH of your executable to contain the directory which contains the library

As option 1.) requires root privileges and option 2.) requires the LD_LIBRARY_PATH to be set correctly at run time, the third option is preferred.
RUNPATH prefers the library used at compile time over a library installed on the system, which is probably what you want. Otherwise you would have compiled against the system library.
Note that you can always override the library set in the RUNPATH by setting the LD_LIBRARY_PATH to a different version (we are using RUNPATH, not RPATH).
For this reason it is recommended to have the RUNPATH_FLAGS in your linker flags.

Note:
If you are using the MTCA4U from Debian packages, the RUNPATH_FLAGS are empty, as we are using option 1 and the libraries are found automatically.
To keep your source code compatible with MTCA4U installations from source code (strongly recommended), one should nevertheless keep the RUNPATH_FLAGS in the linker flags.

--------------------
Manual installation:
--------------------
When installing MTCA4U you should stick to the DOOCS habit of installing to an architecture-dependent directory when installing to a network drive.
This might be mounted from several computers with different architectures (like your nfs home directory). To do so change the MTCA4U_BASE_DIR variable in the master CMakeLists.txt file, for example

set(MTCA4U_BASE_DIR "$ENV{HOME}/mtca4u/$ENV{DOOCSARCH}")

When installing to a local directory, which can only be seen on the specific machine, this is not necessarily required (for instance installation to /usr/local/mtca4u).

If you do not need MTCA4U for another project, you might also want to keep mtca4u with the rest of libraries you are compiling for DOOCS, for instance 
set(MTCA4U_BASE_DIR "$ENV{HOME}/doocs/mtca4u/$ENV{DOOCSARCH}")
The exact installation location is up to the user. The configuration files are automatically adapted to point to wherever you chose to install the library. There are no implicit assumptions on the install path.

To perform the installation just run the install.sh script, as described in ReadMe.txt.

Note: When installing for several architectures from the same source directory, simply remove the 'build' directory from the previous installation before running the install script on the new architecture.
