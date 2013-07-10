# prepare the files to be installed by the debian package
set(DEBIAN_PACKAGE_DIR ${PROJECT_BINARY_DIR}/debian_package/mtca4u_${${PROJECT_NAME}_VERSION})

configure_file(${PROJECT_BINARY_DIR}/cmake/${PROJECT_NAME}ConfigVersion.cmake.in
  "${DEBIAN_PACKAGE_DIR}/${CMAKE_ROOT}/Modules/${PROJECT_NAME}ConfigVersion.cmake" @ONLY)
  
configure_file(${PROJECT_SOURCE_DIR}/cmakemodules/${PROJECT_NAME}Config.cmake.debian.in
  "${DEBIAN_PACKAGE_DIR}/${CMAKE_ROOT}/Modules/${PROJECT_NAME}Config.cmake" @ONLY)

configure_file(${PROJECT_SOURCE_DIR}/cmakemodules/${PROJECT_NAME}.CONFIG.debian
  ${DEBIAN_PACKAGE_DIR}/usr/share/mtca4u/${PROJECT_NAME}.CONFIG)

# now prepare the debian package control files
execute_process(COMMAND lsb_release -c COMMAND sed "{s/Codename:\\s*//}" RESULT_VARIABLE CODENAME_OK
                OUTPUT_VARIABLE DEBIAN_CODENAME OUTPUT_STRIP_TRAILING_WHITESPACE)

if (CODENAME_OK!=0)
  message("Could not determine debian codename. Creation of debian packages will not work")
endif (CODENAME_OK!=0)

#message("DEBIAN_CODENAME is ${DEBIAN_CODENAME}")

#Create the devian library suffix MM-mm from the library version MM.mm.pp
#What the regex does:
# () creates a reference 
# . any character
# .* any number of any character
# \. a dot, as \ has to be escaped in cmake it's \\.
# \1 the first reference, \\1 as \ has to be escaped
# First reference: everything up to the first .
# Second reference: everything between the first end second .
string(REGEX REPLACE "(.*)\\.(.*)\\..*" "\\1-\\2" MtcaMappedDevice_DEBIAN_SUFFIX ${MtcaMappedDevice_VERSION})

message(" MtcaMappedDevice_DEBIAN_SUFFIX is ${MtcaMappedDevice_DEBIAN_SUFFIX}")

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
