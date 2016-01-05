include(ExternalProject)

project("MTCA4U")

set(MTCA4U_VERSION_FILE "MTCA4U_VERSION_${MTCA4U_VERSION}")
include(${MTCA4U_VERSION_FILE})

set(MTCA4U_DIR ${MTCA4U_BASE_DIR}/${MTCA4U_VERSION})

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
MACRO(installSubPackage subPackage addidionalCMakeArgs dependecies svnSubDirectory)

  # If a subpackage is not defined, it is not added. This allows
  # to control which subpackages are installed from the version file.
  if( ${subPackage}_VERSION )

    set(${subPackage}_DIR "${MTCA4U_DIR}/${subPackage}/${${subPackage}_VERSION}")

    if ("${svnSubDirectory}" STREQUAL "")
      set( SVN_SUB_DIR "${subPackage}" )
    else ("${svnSubDirectory}" STREQUAL "")
      set( SVN_SUB_DIR "${svnSubDirectory}" )
    endif ("${svnSubDirectory}" STREQUAL "")

    if( ${subPackage}_VERSION STREQUAL "HEAD" )
      #use the svn trunk in case of the head version
      set(${subPackage}_SVN_DIR "${SVN_BASE_DIR}/${SVN_SUB_DIR}/trunk")
    else( ${subPackage}_VERSION STREQUAL "HEAD" )
      #use the tagged version
      set(${subPackage}_SVN_DIR "${SVN_BASE_DIR}/${SVN_SUB_DIR}/tags/${${subPackage}_VERSION}")
    endif( ${subPackage}_VERSION STREQUAL "HEAD" )

    message("${subPackage}_VERSION is ${${subPackage}_VERSION}")

    ExternalProject_Add(external-${subPackage} 
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
       if( ${pugixml_MIN_VERSION} VERSION_EQUAL "1.3" )
	  message( FATAL_ERROR "Error: pugixml version 1.3 requested. Please use the latest patch tag!" )
        endif( ${pugixml_MIN_VERSION} VERSION_EQUAL "1.3" )

        set(pugixml_INSTALL_VERSION "1.4")
      	set(pugixml_external_project_name "installed_pugixml")
      	set(pugixml_DIR "${MTCA4U_DIR}/pugixml/${pugixml_INSTALL_VERSION}")
      	ExternalProject_Add(${pugixml_external_project_name}
	    DOWNLOAD_COMMAND rm -rf ${pugixml_external_project_name} && bzr export ${pugixml_external_project_name} -r tag:${pugixml_INSTALL_VERSION} http://www.desy.de/~killenb/pugixml-desy 
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

  installSubPackage("mtca4u-deviceaccess" "" "" "deviceaccess")

  installSubPackage("QtHardMon" "-Dmtca4u-deviceaccess_DIR=${mtca4u-deviceaccess_DIR}" "external-mtca4u-deviceaccess" "")
  installSubPackage("MotorDriverCard"
	"-Dmtca4u-deviceaccess_DIR=${mtca4u-deviceaccess_DIR};-Dpugixml_DIR=${pugixml_DIR}"
	"external-mtca4u-deviceaccess;${pugixml_external_project_name}" "")
  installSubPackage("CommandLineTools" "-Dmtca4u-deviceaccess_DIR=${mtca4u-deviceaccess_DIR}" "external-mtca4u-deviceaccess" "")
  installSubPackage("mtca4uPy" "-Dmtca4u-deviceaccess_DIR=${mtca4u-deviceaccess_DIR}" "external-mtca4u-deviceaccess" "PythonBindings/MtcaMappedDevice")

  message("This is mtca4uInstallation installing to ${MTCA4U_BASE_DIR}/${MTCA4U_VERSION}.")

  configure_file(${PROJECT_SOURCE_DIR}/cmakemodules/${PROJECT_NAME}InitialCache.cmake.in
    "${MTCA4U_DIR}/${PROJECT_NAME}InitialCache.cmake" @ONLY)

  configure_file(${PROJECT_SOURCE_DIR}/cmakemodules/${PROJECT_NAME}.CONFIG.in
    "${MTCA4U_DIR}/${PROJECT_NAME}.CONFIG" @ONLY)

ENDMACRO(mtca4uInstallation)

if(NOT MTCA4U_VERSION STREQUAL "HEAD" )
  include(${PROJECT_SOURCE_DIR}/cmakemodules/prepare_debian_package.cmake)
endif(NOT MTCA4U_VERSION STREQUAL "HEAD" )
