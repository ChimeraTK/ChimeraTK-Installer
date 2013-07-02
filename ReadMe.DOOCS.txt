Using MTCA4U with DOOCS

Installation:
When installing MTCA4U you should stick to the DOOCS habit of installing to an architecture-dependent directory when installing to a network drive. This might be mounted from several computers with different architecture (like your nfs home directory). To do so change the MTCA4U_BASE_DIR variable in the master CMakeLists.txt file, for example

set(MTCA4U_BASE_DIR "$ENV{HOME}/mtca4u/$ENV{DOOCSARCH}")

When installing to a local directory, which can only be seen on the specific machine, this is not necessarily required (for instance installation to /usr/local/mtca4u).

If you do not need MTCA4U for another project, you might also want to keep mtca4u with the rest of libraries you are compiling for doocs, for instance 
set(MTCA4U_BASE_DIR "$ENV{HOME}/doocs/mtca4u/$ENV{DOOCSARCH}")
The exact installation location is up to the user. The configuration files are automatically adapted to point to wherever you chose to install the library. There are no implicit assumptions on the install path.

To perform the installation just run the install.sh script, as described in ReadMe.txt.

Note: When installing for several architectures from the same source directory, simply remove the 'build' directory from the previous installation before running the install script on the new architecture.
Note: It is planned to provide pre-compiled packages for at least Ubuntu-10.04-x86_64 and Ubuntu-12.04-x86_64. Until then only way to install is via source code.

Adapting your Makefile:
MTCA4U comes with an include file for Makefiles, called MTCA4U.CONFIG, which is located in the installation directory (for instance ${HOME}/mtca4u/${DOOCSARCH}/[MTCA4U_VERSION]).
It provides the variables  MTCA4U_INCLUDE_FLAGS, MTCA4U_LIB_FLAGS and MTCA4U_RUNPATH_FLAGS, which you add to your compiler and linker flags, respectively.

CPPFLAGS += $(MTCA4U_INCLUDE_FLAGS)
LDFLAGS +=  $(MTCA4U_LIB_FLAGS)

The variable names might differ in your Makefile. The important thing is that the include flags are only needed for the compile step, the lib flags only at link time.

MTCA4U links as a  dynamic library, which means the libraries have to be found at run time. This can be accomplished in three different ways:
1.) By installing the libraries to a path which is automatically searched by the system, like /usr/lib
2.) By setting the LD_LIBRARY_PATH to include the directory which contains the library
3.) By setting the RUNPATH of your executable to contain the directory which contains the library

As option 1.) requires root privileges and option 2.) requires the LD_LIBRARY_PATH to be set correctly at run time, the third option is preferred. For this reason it is recommended to also add the MTCA4U_RUNPATH_FLAGS to the linker flags:

LDFLAGS +=  $(MTCA4U_RUNPATH_FLAGS)

This prefers the library used at compile time over a library installed on the system, which is probably what you want. Otherwise you would have compiled against the system library.
Note that you can always override the library set in the RUNPATH by setting the LD_LIBRARY_PATH to a different version (we are using RUNPATH, not RPATH).

