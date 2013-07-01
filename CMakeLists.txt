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
#There might already be a system variable defined, for DOOCS e.g.
#set(MTCA4U_BASE_DIR "$ENV{HOME}/mtca4u/$ENV{DOOCSARCH}")

#Set the version number or HEAD.
#See Releases.txt for more information and a list of available revisions.
set(MTCA4U_VERSION "00.07.00")
#set(MTCA4U_VERSION "HEAD")

include(${CMAKE_SOURCE_DIR}/cmakemodules/Mtca4uInstallation.cmake)
mtca4uInstallation()


