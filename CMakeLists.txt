cmake_minimum_required(VERSION 2.8.3)
set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmakemodules")

#Set the base installtion directory.
#The installation will be done into a subdirectory with the version number:
# ${MTCA4U_BASE_DIR}/${MTCA4U_VERSION}

#recommended for system wide installation
#set(MTCA4U_BASE_DIR "/usr/local/mtca4u")
#
#proposed for user installation (no root privileges required)
set(MTCA4U_BASE_DIR "$ENV{HOME}/mtca4u")

#set the version number or HEAD
#see Releases.txt for more information and a list of available revisions.
set(MTCA4U_VERSION "00.06.00")
#set(MTCA4U_VERSION "HEAD")

include(${CMAKE_SOURCE_DIR}/cmakemodules/Mtca4uInstallation.cmake)
mtca4uInstallation()


