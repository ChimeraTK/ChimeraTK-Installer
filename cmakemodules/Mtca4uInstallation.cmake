include(ExternalProject)

set(MTCA4U_VERSION_FILE "MTCA4U_VERSION_${MTCA4U_VERSION}")
include(${MTCA4U_VERSION_FILE})

set(MTCA4U_DIR ${MTCA4U_BASE_DIR}/${MTCA4U_VERSION})
#message("MtcaMappedDevice_VERSION ${MtcaMappedDevice_VERSION}")

#turn on linking of the full rpath in installation
SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

# the RPATH to be used when installing, but only if it's not a system directory
LIST(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES "${CMAKE_INSTALL_PREFIX}/lib" isSystemDir)
IF("${isSystemDir}" STREQUAL "-1")
   SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
ENDIF("${isSystemDir}" STREQUAL "-1")

#The base URL of the repository. Sub-packages are located in sub-directiries
set(SVN_BASE_DIR "https://svnsrv.desy.de/public/mtca4u")

#macro to set and intstall the sub package as external project from the svn repository
MACRO(installSubPackage subPackage addidionalCMakeArgs)

  set(${subPackage}_DIR "${MTCA4U_DIR}/${subPackage}/${${subPackage}_VERSION}")

  if( ${subPackage}_VERSION STREQUAL "HEAD" )
    #use the svn trunk in case of the head version
    set(${subPackage}_SVN_DIR "${SVN_BASE_DIR}/${subPackage}/trunk")
  else( ${subPackage}_VERSION STREQUAL "HEAD" )
    #use the tagged version
    set(${subPackage}_SVN_DIR "${SVN_BASE_DIR}/${subPackage}/tags/${${subPackage}_VERSION}")
  endif( ${subPackage}_VERSION STREQUAL "HEAD" )

  message("${subPackage}_VERSION is ${${subPackage}_VERSION}")

  ExternalProject_Add(mtca4u-${subPackage} 
    SVN_REPOSITORY ${${subPackage}_SVN_DIR}
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${${subPackage}_DIR} ${addidionalCMakeArgs}
    INSTALL_DIR ${${subPackage}_DIR}
    )

ENDMACRO(installSubPackage)

# The mtca4uInstallation stores which sub-packages to install and where they are located
MACRO(mtca4uInstallation)
  
  installSubPackage("MtcaMappedDevice" "")

  installSubPackage("QtHardMon" "-DMtcaMappedDevice_DIR=${MtcaMappedDevice_DIR}")

  message("This is mtca4uInstallation installing to ${MTCA4U_BASE_DIR}/${MTCA4U_VERSION}.")
ENDMACRO(mtca4uInstallation)


