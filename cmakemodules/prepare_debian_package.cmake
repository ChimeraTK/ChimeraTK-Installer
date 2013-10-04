# prepare the files to be installed by the debian package
set(DEBIAN_PACKAGE_DIR ${PROJECT_BINARY_DIR}/debian_package/mtca4u_${${PROJECT_NAME}_VERSION})

configure_file(${PROJECT_BINARY_DIR}/cmake/${PROJECT_NAME}ConfigVersion.cmake.in
  "${DEBIAN_PACKAGE_DIR}/${CMAKE_ROOT}/Modules/${PROJECT_NAME}ConfigVersion.cmake" @ONLY)
  
configure_file(${PROJECT_SOURCE_DIR}/cmakemodules/${PROJECT_NAME}Config.cmake.debian.in
  "${DEBIAN_PACKAGE_DIR}/${CMAKE_ROOT}/Modules/${PROJECT_NAME}Config.cmake" @ONLY)

configure_file(${PROJECT_SOURCE_DIR}/cmakemodules/${PROJECT_NAME}.CONFIG.debian
  ${DEBIAN_PACKAGE_DIR}/usr/share/mtca4u/${PROJECT_NAME}.CONFIG)

# now prepare the debian package control files

#Create major and minor version from the library version MM.mm.pp
#What the regex does:
# () creates a reference 
# . any character
# .+ multiple characters, at least one
# \. a dot, as \ has to be escaped in cmake it's \\.
# \1 the first reference, \\1 as \ has to be escaped
# First reference: everything up to the first .
# Second reference: everything between the first and second .
string(REGEX REPLACE "(.+)\\.(.+)\\..+" "\\1" MtcaMappedDevice_MAJOR_VERSION ${MtcaMappedDevice_VERSION})
string(REGEX REPLACE "(.+)\\.(.+)\\..+" "\\2" MtcaMappedDevice_MINOR_VERSION ${MtcaMappedDevice_VERSION})

set(MtcaMappedDevice_DEBIAN_SUFFIX "${MtcaMappedDevice_MAJOR_VERSION}-${MtcaMappedDevice_MINOR_VERSION}")
#message(" MtcaMappedDevice_DEBIAN_SUFFIX is ${MtcaMappedDevice_DEBIAN_SUFFIX}")

#increase the minor version by one
MATH(EXPR MtcaMappedDevice_NEXT_MINOR_VERSION "${MtcaMappedDevice_MINOR_VERSION}+1")
#ensure that there is a leading 0 for numbers up to 9
string(REGEX REPLACE "^(.)$" "0\\1" MtcaMappedDevice_NEXT_MINOR_VERSION ${MtcaMappedDevice_NEXT_MINOR_VERSION})

set(MtcaMappedDevice_NEXT_SOVERSION "${MtcaMappedDevice_MAJOR_VERSION}.${MtcaMappedDevice_NEXT_MINOR_VERSION}")
#message("MtcaMappedDevice_NEXT_SOVERSION ${MtcaMappedDevice_NEXT_SOVERSION}")

#The same for the MTCA4U version
string(REGEX REPLACE "(.+)\\.(.+)\\..+" "\\1" MTCA4U_MAJOR_VERSION ${MTCA4U_VERSION})
string(REGEX REPLACE "(.+)\\.(.+)\\..+" "\\2" MTCA4U_MINOR_VERSION ${MTCA4U_VERSION})
#increase the minor version by one
MATH(EXPR MTCA4U_NEXT_MINOR_VERSION "${MTCA4U_MINOR_VERSION}+1")
#ensure that there is a leading 0 for numbers up to 9
string(REGEX REPLACE "^(.)$" "0\\1" MTCA4U_NEXT_MINOR_VERSION ${MTCA4U_NEXT_MINOR_VERSION})

set(MTCA4U_NEXT_SOVERSION "${MTCA4U_MAJOR_VERSION}.${MTCA4U_NEXT_MINOR_VERSION}")

#Nothing to change, just copy
file(COPY ${CMAKE_SOURCE_DIR}/cmakemodules/debian_package_templates/compat
     ${CMAKE_SOURCE_DIR}/cmakemodules/debian_package_templates/copyright
     ${CMAKE_SOURCE_DIR}/cmakemodules/debian_package_templates/mtca4u.install
     ${CMAKE_SOURCE_DIR}/cmakemodules/debian_package_templates/rules
     DESTINATION debian_from_template)

file(COPY ${CMAKE_SOURCE_DIR}/cmakemodules/debian_package_templates/source/format
     DESTINATION debian_from_template/source)

#Set the version number
configure_file(${CMAKE_SOURCE_DIR}/cmakemodules/debian_package_templates/control.in
               debian_from_template/control @ONLY)

configure_file(${CMAKE_SOURCE_DIR}/cmakemodules/debian_package_templates/dev-mtca4u.install.in
               debian_from_template/dev-mtca4u.install @ONLY)

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
set(PACKAGE_DEV_NAME "dev-mtca4u")
set(PACKAGE_FILES_WILDCARDS "${PACKAGE_NAME}_*.deb ${PACKAGE_DEV_NAME}_*.deb ${PACKAGE_NAME}_*.changes")

configure_file(${CMAKE_SOURCE_DIR}/cmakemodules/install_debian_package_at_DESY.sh.in
               install_debian_package_at_DESY.sh @ONLY)
