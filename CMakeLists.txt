cmake_minimum_required(VERSION 2.8.0)
set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmakemodules")

#Set the base installtion directory.
#The installation will be done into a subdirectory with the version number:
# ${MTCA4U_BASE_DIR}/${MTCA4U_VERSION}

#Recommended for system wide installation
#set(MTCA4U_BASE_DIR "/usr/local/mtca4u")
#
#Proposed for user installation (no root privileges required)
set(MTCA4U_BASE_DIR "$ENV{HOME}/mtca4u")
#
#Recommended for network file systems: add the architecture
#set(MTCA4U_BASE_DIR "$ENV{HOME}/mtca4u/Ubuntu-12.04-x86_64")
#There might already be a system variable defined, or a directory
#where you would like to install it. For DOOCS e.g.
#set(MTCA4U_BASE_DIR "$ENV{HOME}/doocs/mtca4u/$ENV{DOOCSARCH}")

#This variable is updated for a new release. It is stored in a separate line so the 'set(MTCA4U_VERSION ..)'
#line does not cause a conflict on svn update if it is changed to HEAD by the developer.
set(LATEST_VERSION "01.02.02")

#Set the version to be installed (version number or HEAD).
#See Releases.txt for more information and a list of available revisions.
#Note: You can only install versions newer than 01.00.00, which is the first version that comes with the
# deviceaccess library. For older versions please check out tag 00.24.03, which can install all 00.xx versions.
set(MTCA4U_VERSION ${LATEST_VERSION})
#set(MTCA4U_VERSION "HEAD")

#In case pugixml is not found set either the path where it can be found,
#or chose it to be installed together with MTCA4U
#set(pugixml_DIR "/wherever/pugixml/is/installed")
#set(INSTALL_PUGIXML true)

include(${CMAKE_SOURCE_DIR}/cmakemodules/Mtca4uInstallation.cmake)
mtca4uInstallation()
