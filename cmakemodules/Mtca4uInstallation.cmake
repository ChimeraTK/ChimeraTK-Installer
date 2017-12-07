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
set(GIT_BASE_URL "https://github.com/ChimeraTK")

#macro to set and intstall the sub package as external project from the git repository
MACRO(installSubPackage subPackage additionalCMakeArgs dependecies gitRepo)

  # If a subpackage is not defined, it is not added. This allows
  # to control which subpackages are installed from the version file.
  if( ${subPackage}_VERSION )

    set(${subPackage}_INSTALL_DIR "${MTCA4U_DIR}")
    set(${subPackage}_DIR "${${subPackage}_INSTALL_DIR}/share/cmake-${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}/Modules")
    set(EXTERN_CMAKE_MODULE_PATH ${EXTERN_CMAKE_MODULE_PATH} ${${subPackage}_DIR})
    # replace semicolons with a "double hat" to pass a semicolon separated list as one
    # parameter of a list which itself is semicolon separated
    string(REGEX REPLACE ";" "^^" DOUBLE_HAT_SEPARATED_MODULE_PATH "${EXTERN_CMAKE_MODULE_PATH}")

    if ("${gitRepo}" STREQUAL "")
      set( ${subPackage}_GIT_REPO "${subPackage}" )
    else ("${gitRepo}" STREQUAL "")
      set( ${subPackage}_GIT_REPO "${gitRepo}" )
    endif ("${gitRepo}" STREQUAL "")

    if( ${subPackage}_VERSION STREQUAL "HEAD" )
      #use the git master in case of the head version
      set(${subPackage}_TAG "master")
    else( ${subPackage}_VERSION STREQUAL "HEAD" )
      #use the tagged version
      set(${subPackage}_TAG "${${subPackage}_VERSION}")
    endif( ${subPackage}_VERSION STREQUAL "HEAD" )

    message("${subPackage}_VERSION is ${${subPackage}_VERSION}")

    ExternalProject_Add(external-${subPackage} 
      DEPENDS ${dependecies}
      GIT_REPOSITORY ${GIT_BASE_URL}/${${subPackage}_GIT_REPO}
      GIT_TAG ${${subPackage}_TAG}
      CMAKE_ARGS "-DCMAKE_INSTALL_PREFIX=${${subPackage}_INSTALL_DIR}" "${additionalCMakeArgs}" 
      "-DCMAKE_MODULE_PATH=${DOUBLE_HAT_SEPARATED_MODULE_PATH}"
      LIST_SEPARATOR "^^"
      INSTALL_DIR ${${subPackage}_INSTALL_DIR}
      )

  endif( ${subPackage}_VERSION )  
ENDMACRO(installSubPackage)

MACRO(checkOrInstallPugixml)
  if ( (MTCA4U_VERSION  STREQUAL "HEAD") OR (NOT (MTCA4U_VERSION  VERSION_LESS 01.04) ) ) 
    message("PUGIXML not needed.")
  else ( (MTCA4U_VERSION  STREQUAL "HEAD") OR (NOT (MTCA4U_VERSION  VERSION_LESS 01.04) ) ) 

    if( INSTALL_PUGIXML )
      if( ${pugixml_MIN_VERSION} VERSION_EQUAL "1.3" )
	message( FATAL_ERROR "Error: pugixml version 1.3 requested. Please use the latest patch tag!" )
      endif( ${pugixml_MIN_VERSION} VERSION_EQUAL "1.3" )
    
      set(pugixml_INSTALL_VERSION "1.4")
      set(pugixml_external_project_name "installed_pugixml")
      set(pugixml_DIR "${MTCA4U_DIR}/pugixml/${pugixml_INSTALL_VERSION}")
      ExternalProject_Add(${pugixml_external_project_name}
	DOWNLOAD_COMMAND rm -rf ${pugixml_external_project_name} && bzr export ${pugixml_external_project_name} -r tag:${pugixml_INSTALL_VERSION} http://www.desy.de/~killenb/pugixml-desy 
	CMAKE_ARGS "-DCMAKE_INSTALL_PREFIX=${pugixml_DIR}" "${additionalCMakeArgs}"
	INSTALL_DIR ${pugixml_DIR}
	)
      set( pugixml_FOUND true )
    else( INSTALL_PUGIXML )    	   
      find_package(pugixml ${pugixml_MIN_VERSION})
    endif( INSTALL_PUGIXML )

    if( NOT pugixml_FOUND )
      message( FATAL_ERROR "pugixml not found. Edit the CMakeLists.txt file and either provide pugixml_DIR or set INSTALL_PUGIXML to true to have it installed together with mtca4u" )
    endif( NOT pugixml_FOUND )

  endif ( (MTCA4U_VERSION  STREQUAL "HEAD") OR (NOT (MTCA4U_VERSION  VERSION_LESS 01.04) ) ) 
ENDMACRO(checkOrInstallPugixml)

# The mtca4uInstallation stores which sub-packages to install and where they are located
MACRO(mtca4uInstallation)
  
  find_package(Boost REQUIRED)
  checkOrInstallPugixml()

  installSubPackage("mtca4u-deviceaccess" "" "" "DeviceAccess")
  installSubPackage("QtHardMon" "" "external-mtca4u-deviceaccess" "")
  installSubPackage("MotorDriverCard" "-Dpugixml_DIR=${pugixml_DIR}"
	"external-mtca4u-deviceaccess;${pugixml_external_project_name}" "")
  installSubPackage("CommandLineTools" "" "external-mtca4u-deviceaccess" "")
  installSubPackage("mtca4uPy" "" "external-mtca4u-deviceaccess" "DeviceAccess-PythonBindings")
  installSubPackage("mtca4uVirtualLab" "" "external-mtca4u-deviceaccess" "VirtualLab")
  installsubPackage("MotorDriverCard-PythonBindings" "" "external-MotorDriverCard" "")
  installsubPackage("ControlSystemAdapter" "" "external-mtca4u-deviceaccess" "")
  installsubPackage("ControlSystemAdapter-OPC-UA-Adapter" "" "external-ControlSystemAdapter" "")
  
  message("This is mtca4uInstallation installing to ${MTCA4U_DIR}.")

  configure_file(${PROJECT_SOURCE_DIR}/cmakemodules/${PROJECT_NAME}InitialCache.cmake.in
    "${MTCA4U_DIR}/share/mtca4u/${PROJECT_NAME}InitialCache.cmake" @ONLY)

ENDMACRO(mtca4uInstallation)

if(NOT MTCA4U_VERSION STREQUAL "HEAD" )
  include(${PROJECT_SOURCE_DIR}/cmakemodules/prepare_debian_package.cmake)
endif(NOT MTCA4U_VERSION STREQUAL "HEAD" )
