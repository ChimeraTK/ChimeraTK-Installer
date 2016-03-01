# prepare the files to be installed by the debian package
set(DEBIAN_PACKAGE_DIR ${PROJECT_BINARY_DIR}/debian_package/mtca4u_${${PROJECT_NAME}_VERSION})

file(COPY  ${CMAKE_SOURCE_DIR}/Manual.txt ${CMAKE_SOURCE_DIR}/ReadMe.DOOCS.txt ${CMAKE_SOURCE_DIR}/Releases.txt 
  DESTINATION ${DEBIAN_PACKAGE_DIR})

# now prepare the debian package control files
MACRO( createDebianControlVariables subPackage )
  #In older versions not all packages are available.
  #This also allows CMake to configure correctly with custom configuration, where not all packages are installed.
  #In this case you cannot create a debian package, which is intentional.
  if( DEFINED ${subPackage}_VERSION )
    #Create major and minor version from the library version MM.mm.pp
    #What the regex does:
    # () creates a reference 
    # . any character
    # .+ multiple characters, at least one
    # \. a dot, as \ has to be escaped in cmake it's \\.
    # \1 the first reference, \\1 as \ has to be escaped
    # First reference: everything up to the first .
    # Second reference: everything between the first and second .
    string(REGEX REPLACE "(.+)\\.(.+)\\..+" "\\1" ${subPackage}_MAJOR_VERSION ${${subPackage}_VERSION})
    string(REGEX REPLACE "(.+)\\.(.+)\\..+" "\\2" ${subPackage}_MINOR_VERSION ${${subPackage}_VERSION})
    
    set(${subPackage}_DEBIAN_SUFFIX "${${subPackage}_MAJOR_VERSION}-${${subPackage}_MINOR_VERSION}")
    #increase the minor version by one
    MATH(EXPR ${subPackage}_NEXT_MINOR_VERSION "${${subPackage}_MINOR_VERSION}+1")
    #ensure that there is a leading 0 for numbers up to 9
    if( ${subPackage}_NEXT_MINOR_VERSION LESS 10 )
      string(REGEX REPLACE "^(.)$" "0\\1" ${subPackage}_NEXT_MINOR_VERSION ${${subPackage}_NEXT_MINOR_VERSION})
    endif( ${subPackage}_NEXT_MINOR_VERSION LESS 10 )
    
    set(${subPackage}_NEXT_SOVERSION "${${subPackage}_MAJOR_VERSION}.${${subPackage}_NEXT_MINOR_VERSION}")
    #message("${subPackage}_NEXT_SOVERSION ${${subPackage}_NEXT_SOVERSION}")
    
    #The same for the MTCA4U version
    string(REGEX REPLACE "(.+)\\.(.+)\\..+" "\\1" MTCA4U_MAJOR_VERSION ${MTCA4U_VERSION})
    string(REGEX REPLACE "(.+)\\.(.+)\\..+" "\\2" MTCA4U_MINOR_VERSION ${MTCA4U_VERSION})
    #increase the minor version by one
    MATH(EXPR MTCA4U_NEXT_MINOR_VERSION "${MTCA4U_MINOR_VERSION}+1")
    #ensure that there is a leading 0 for numbers up to 9
    string(REGEX REPLACE "^(.)$" "0\\1" MTCA4U_NEXT_MINOR_VERSION ${MTCA4U_NEXT_MINOR_VERSION})
  endif( DEFINED ${subPackage}_VERSION )
ENDMACRO( createDebianControlVariables )

createDebianControlVariables( mtca4u-deviceaccess )
createDebianControlVariables( MotorDriverCard )
createDebianControlVariables( MTCA4U )
createDebianControlVariables( CommandLineTools )
createDebianControlVariables( mtca4uPy )
createDebianControlVariables( mtca4uVirtualLab )

#Nothing to change, just copy
file(COPY ${CMAKE_SOURCE_DIR}/cmakemodules/debian_package_templates/compat
     ${CMAKE_SOURCE_DIR}/cmakemodules/debian_package_templates/copyright
     ${CMAKE_SOURCE_DIR}/cmakemodules/debian_package_templates/rules
     DESTINATION debian_from_template)

configure_file(${CMAKE_SOURCE_DIR}/cmakemodules/debian_package_templates/docs
  debian_from_template/mtca4u.docs)
configure_file(${CMAKE_SOURCE_DIR}/cmakemodules/debian_package_templates/docs
  debian_from_template/libmtca4u-dev.docs)

file(COPY ${CMAKE_SOURCE_DIR}/cmakemodules/debian_package_templates/source/format
     DESTINATION debian_from_template/source)

#Set the version number
configure_file(${CMAKE_SOURCE_DIR}/cmakemodules/debian_package_templates/control.in
               debian_from_template/control @ONLY)

#Copy and configure the shell script which performs the actual 
#building of the package
configure_file(${CMAKE_SOURCE_DIR}/cmakemodules/make_debian_package.sh.in
               make_debian_package.sh @ONLY)

#A custom target so you can just run make debian_package
#(You could instead run make_debian_package.sh yourself, hm...)
add_custom_target(debian_package ${CMAKE_BINARY_DIR}/make_debian_package.sh
                  COMMENT Building debian package for tag ${MTCA4U_VERSION})

#For convenience: Also create an install script for DESY
set(PACKAGE_NAME "mtca4u")
set(PACKAGE_DEV_NAME "libmtca4u-dev")
set(PACKAGE_FILES_WILDCARDS "${PACKAGE_NAME}_*.deb ${PACKAGE_DEV_NAME}_*.deb ${PACKAGE_NAME}_*.changes")

configure_file(${CMAKE_SOURCE_DIR}/cmakemodules/install_debian_package_at_DESY.sh.in
               install_debian_package_at_DESY.sh @ONLY)

configure_file(${CMAKE_SOURCE_DIR}/cmakemodules/prepare_dependent_debian_packages.py.in
               prepare_dependent_debian_packages.py @ONLY)
