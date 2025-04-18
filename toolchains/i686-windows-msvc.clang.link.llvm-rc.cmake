##
# @file
# @brief A CMake toolchain file for Clang
# @details Sets the following:
#          - platform       : i686-windows-msvc
#          - compiler       : Clang / Clang++
#          - linker         : link (MSVC)
#          - std-library    : Default (MSVC)
#          - resource-comp. : llvm-rc (LLVM)
#

# Cross-compiling?
if (NOT CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "X86" OR NOT CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
    set( CMAKE_SYSTEM_PROCESSOR "X86" )
    set( CMAKE_SYSTEM_NAME      "Windows" )
endif()
if (NOT CMAKE_SYSTEM_VERSION)
    set( CMAKE_SYSTEM_VERSION   "6.3.9600" )  # Windows 8.1
endif()

# What MSVC runtime to use?
if (NOT DEFINED CMAKE_MSVC_RUNTIME_LIBRARY)
    set( CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL" )  # dynamic runtime
endif()

# Fix for CMake versions before v3.23?
if (CMAKE_VERSION VERSION_LESS 3.23)
    set( CMAKE_C_LINKER_SUPPORTS_PDB   ON )
    set( CMAKE_CXX_LINKER_SUPPORTS_PDB ON )
endif()

set( CMAKE_C_COMPILER "clang" )
set( CMAKE_C_COMPILER_TARGET "i686-windows-msvc" )
set( CMAKE_CXX_COMPILER "clang++" )
set( CMAKE_CXX_COMPILER_TARGET "i686-windows-msvc" )
set( CMAKE_RC_COMPILER "llvm-rc" )

set( CMAKE_LINKER "link" CACHE FILEPATH "Path to the linker." )
set( CMAKE_EXE_LINKER_FLAGS_INIT "-fuse-ld=link" )
set( CMAKE_MODULE_LINKER_FLAGS_INIT "-fuse-ld=link" )
set( CMAKE_SHARED_LINKER_FLAGS_INIT "-fuse-ld=link" )
