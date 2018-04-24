cmake_minimum_required(VERSION 2.8.9)

set(projects C CXX ASM)

project(luvi ${projects})

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")

# use, i.e. don't skip the full RPATH for the build tree
SET(CMAKE_SKIP_BUILD_RPATH FALSE CACHE INTERNAL "")
# when building, don't use the install RPATH already
# (but later on when installing)
SET(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE CACHE INTERNAL "")
SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib" CACHE INTERNAL "")
# add the automatically determined parts of the RPATH
# which point to directories outside the build tree to the install RPATH
SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE CACHE INTERNAL "")
# the RPATH to be used when installing, but only if it's not a system directory
LIST(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES "${CMAKE_INSTALL_PREFIX}/lib" isSystemDir)
IF("${isSystemDir}" STREQUAL "-1")
   SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
ENDIF("${isSystemDir}" STREQUAL "-1")

if (EXISTS "VERSION")
  file (STRINGS "VERSION" LUVI_VERSION)
  message("-- Found luvi version: ${LUVI_VERSION}")
else()
  set(LUVI_VERSION 2.8.0)
  message("-- Found luvi version: ${LUVI_VERSION}")
endif()

option(WithOpenSSL "Include OpenSSL" OFF)
option(WithOpenSSLASM "Enable Assembly Optimizations" OFF)
option(WithSharedOpenSSL "Shared or Static OpenSSL" ON)
option(WithPCRE "Include " OFF)
option(WithSharedPCRE "Shared or Static " OFF)
option(WithLPEG "Include " OFF)
option(WithSharedLPEG "Shared or Static " OFF)
option(WithZLIB "Include ZLIB" OFF)
option(WithSharedZLIB "Shared or Static ZLIB" ON)
option(WithPackageSH "Build shell-installable package." OFF)
option(WithPackageTGZ "Build gziped tarball package." OFF)
option(WithPackageTBZ2 "Build bzip2'd tarball package." OFF)

find_package(Threads)

# Build luv as static library insteas as module
set(BUILD_MODULE OFF CACHE STRING "Build luv as static library")
include_directories(deps/luv/src)
include_directories(deps/luv/deps/libuv/include)

include_directories(deps/luv/deps/lua)
set(LUVI_LIBRARIES luv lualib uv)

add_subdirectory(deps/luv)


if (WithOpenSSL)
  include(deps/openssl.cmake)
endif (WithOpenSSL)

if (WithPCRE)
  include (deps/pcre.cmake)
endif (WithPCRE)

if (WithLPEG)
  include (deps/lpeg.cmake)
endif (WithLPEG)

if (WithZLIB)
  include(deps/zlib.cmake)
endif (WithZLIB)

add_definitions( -DLUVI_VERSION="${LUVI_VERSION}" )

add_definitions(-Wall)

add_definitions(-DWITH_PLAIN_LUA)

lua_add_executable(luvi
  src/main.c
  src/lua/init.lua
  src/lua/luvipath.lua
  src/lua/luvibundle.lua
)

set(EXTRA_LIBS ${EXTRA_LIBS} rt)

target_link_libraries(luvi ${LUVI_LIBRARIES} ${EXTRA_LIBS} ${CMAKE_THREAD_LIBS_INIT})

###############################################################################
## Installation Targets
###############################################################################

install(TARGETS luvi DESTINATION bin)

###############################################################################
## Packaging
###############################################################################

if(WithPackageSH OR WithPackageTGZ OR WithPackageTBZ2 )

  set(CPACK_PACKAGE_NAME "luvi")
  set(CPACK_PACKAGE_VENDOR "Luvit Authors")
  set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "A project in-between luv and luvit")
  set(CPACK_PACKAGE_VERSION "0.7.2")
  set(CPACK_PACKAGE_VERSION_MAJOR "0")
  set(CPACK_PACKAGE_VERSION_MINOR "7")
  set(CPACK_PACKAGE_VERSION_PATCH "2")
  set(CPACK_PACKAGE_INSTALL_DIRECTORY "luvi")
  set(CPACK_NSIS_MODIFY_PATH ON)

  unset(PACKAGE_LIST)
  if (WithPackageSH)
    list(APPEND CPACK_GENERATOR "STGZ")
    list(APPEND PACKAGE_LIST "Shell-installable package (.sh)")
  endif ()
  if (WithPackageTGZ)
    list(APPEND CPACK_GENERATOR "TGZ")
    list(APPEND PACKAGE_LIST "gziped tarball (.tar.gz)")
  endif ()
  if (WithPackageTBZ2)
    list(APPEND CPACK_GENERATOR "TBZ2")
    list(APPEND PACKAGE_LIST "bzip2'd tarball (.tar.bz2)")
  endif ()
  string(REPLACE ";" ", " PACKAGE_LIST "${PACKAGE_LIST}")

  include(CPack)
else()
  set(PACKAGE_LIST "None")
endif()
