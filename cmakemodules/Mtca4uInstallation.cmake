include(ExternalProject)

project("MTCA4U")

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
MACRO(installSubPackage subPackage addidionalCMakeArgs dependecies)

  # If a subpackage is not defined, it is not added. This allows
  # to control which subpackages are installed from the version file.
  if( ${subPackage}_VERSION )

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
      DEPENDS ${dependecies}
      SVN_REPOSITORY ${${subPackage}_SVN_DIR}
      CMAKE_ARGS "-DCMAKE_INSTALL_PREFIX=${${subPackage}_DIR}" "${addidionalCMakeArgs}"
      INSTALL_DIR ${${subPackage}_DIR}
      )

     endif( ${subPackage}_VERSION )  
ENDMACRO(installSubPackage)

MACRO(checkOrInstallPugixml)
   #pugixml is only needed for MTCA4U from 00.09 on 
   if( (${MTCA4U_VERSION} VERSION_GREATER "00.08.01") OR 
       (${MTCA4U_VERSION} STREQUAL "HEAD") )

     if( INSTALL_PUGIXML )
        # fixme:  cmake/desy installer for pugixml plus checkout from the
     	# official pugixml after the next tag
      	set(pugixml_external_project_name "installed_pugixml")
      	set(pugixml_DIR "${MTCA4U_DIR}/pugixml/1.3desy")
      	ExternalProject_Add(${pugixml_external_project_name}
	    DOWNLOAD_COMMAND rm -rf ${pugixml_external_project_name} && bzr export ${pugixml_external_project_name} -r tag:1.3-desy http://www.desy.de/~killenb/pugixml-desy 
	    CMAKE_ARGS "-DCMAKE_INSTALL_PREFIX=${pugixml_DIR}" "${addidionalCMakeArgs}"
	    INSTALL_DIR ${pugixml_DIR}
	    )
	set( pugixml_FOUND true )
     else( INSTALL_PUGIXML )    	   
       find_package(pugixml ${pugixml_MIN_VERSION})
     endif( INSTALL_PUGIXML )

     if( NOT pugixml_FOUND )
       message( FATAL_ERROR "pugixml not found. Edit the CMakeLists.txt file and either provide pugixml_DIR or set INSTALL_PUGIXML to true to have it installed together with mtca4u" )
     endif( NOT pugixml_FOUND )
   endif( (${MTCA4U_VERSION} VERSION_GREATER "00.08.01") OR 
          (${MTCA4U_VERSION} STREQUAL "HEAD")  )
ENDMACRO(checkOrInstallPugixml)

# The mtca4uInstallation stores which sub-packages to install and where they are located
MACRO(mtca4uInstallation)
  
  find_package(Boost REQUIRED)
  checkOrInstallPugixml()

  installSubPackage("MtcaMappedDevice" "" "")

  installSubPackage("QtHardMon" "-DMtcaMappedDevice_DIR=${MtcaMappedDevice_DIR}" "mtca4u-MtcaMappedDevice")
  installSubPackage("MotorDriverCard"
	"-DMtcaMappedDevice_DIR=${MtcaMappedDevice_DIR};-Dpugixml_DIR=${pugixml_DIR}"
	"mtca4u-MtcaMappedDevice;${pugixml_external_project_name}")
  installSubPackage("CommandLineTools" "-DMtcaMappedDevice_DIR=${MtcaMappedDevice_DIR}" "mtca4u-MtcaMappedDevice")

  message("This is mtca4uInstallation installing to ${MTCA4U_BASE_DIR}/${MTCA4U_VERSION}.")

  configure_file(${PROJECT_SOURCE_DIR}/cmakemodules/${PROJECT_NAME}InitialCache.cmake.in
    "${MTCA4U_DIR}/${PROJECT_NAME}InitialCache.cmake" @ONLY)

  configure_file(${PROJECT_SOURCE_DIR}/cmakemodules/${PROJECT_NAME}.CONFIG.in
    "${MTCA4U_DIR}/${PROJECT_NAME}.CONFIG" @ONLY)

ENDMACRO(mtca4uInstallation)

if(NOT MTCA4U_VERSION STREQUAL "HEAD" )
  include(${PROJECT_SOURCE_DIR}/cmakemodules/prepare_debian_package.cmake)
endif(NOT MTCA4U_VERSION STREQUAL "HEAD" )
