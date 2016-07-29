Using ChimeraTK with DOOCS

Note: MTCA4U has recently been renamed to ChimeraTK. The debian packages and namespaces of the projects are still called mtca4u at the moment.

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
Each library in ChimeraTK/MTCA4U comes with a script which provides the compiler and linker flags. The deviceaccess library for instance has a script named 'mtca4u-deviceaccess-config'.
It has to be in you path, which is the case if you installed the library from a debian package. For manual installations add the 'bin' directory of the installation directory to you path,
for instance ${HOME}/mtca4u/${DOOCSARCH}/[MTCA4U_VERSION]/bin).

Invoke the according script of each library in the following way (currently mtca4u-deviceacces, mtca4uVirtualLab and mtca4u-MotorDriverCard have support for standard Makefiles):

Example:
CPPFLAGS += $(SHELL mtca4u-deviceaccess-config --cppflags)
LDFLAGS += $(SHELL mtca4u-deviceaccess-config --ldflags) 

The names for the compiler and linker flags might differ in your Makefile. The important thing is that the cppflags are only needed for the compile step, the ldflags only at link time.

Information about the ldflags: MTCA4U libraries are seeting RUNPATH flags to the library which was used at link time.

Background:
MTCA4U links as a  dynamic library, which means the libraries have to be found at run time. This can be accomplished in three different ways:
1.) By installing the libraries to a path which is automatically searched by the system, like /usr/lib
2.) By setting the LD_LIBRARY_PATH to include the directory which contains the library
3.) By setting the RUNPATH of your executable to contain the directory which contains the library

As option 1.) requires root privileges and option 2.) requires the LD_LIBRARY_PATH to be set correctly at run time, the third option is preferred.
RUNPATH prefers the library used at compile time over a library installed on the system, which is probably what you want. Otherwise you would have compiled against the system library.
Note that you can always override the library set in the RUNPATH by setting the LD_LIBRARY_PATH to a different version (we are using RUNPATH, not RPATH).

--------------------
Manual installation:
--------------------
When installing MTCA4U you should stick to the DOOCS habit of installing to an architecture-dependent directory when installing to a network drive.
This might be mounted from several computers with different architectures (like your nfs home directory). To do so change the MTCA4U_BASE_DIR variable in the master CMakeLists.txt file, for example

set(MTCA4U_BASE_DIR "$ENV{HOME}/mtca4u/$ENV{DOOCSARCH}")

When installing to a local directory, which can only be seen on the specific machine, this is not required (for instance installation to /usr/local).

If you do not need MTCA4U for another project, you might also want to keep mtca4u with the rest of libraries you are compiling for DOOCS, for instance 
set(MTCA4U_BASE_DIR "$ENV{HOME}/doocs/mtca4u/$ENV{DOOCSARCH}")
The exact installation location is up to the user. The configuration files are automatically adapted to point to wherever you chose to install the library. There are no implicit assumptions on the install path.

To perform the installation just run the install.sh script, as described in Manual.txt.

Note: When installing for several architectures from the same source directory on a network drive, simply remove the 'build' directory from the previous installation before running the install script on the new architecture.
