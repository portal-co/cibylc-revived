cmake_minimum_required (VERSION 2.6)
set(CMAKE_LEGACY_CYGWIN_WIN32 0) # Remove when CMake >= 2.8.4 is required

# ====================================
# project name and version
# ====================================
project (cibylc-revived)
set (PROJECT_VERSION_MAJOR  22)
set (PROJECT_VERSION_MINOR  0)
set (PROJECT_VERSION_PATCH  0)
set (PROJECT_VERSION "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}")

include(cmake/zlib.cmake)
include(cmake/elfutils.cmake)


set (translator_SRCS
	src/basicblock.cc
    src/builtins.cc
    src/calltablemethod.cc
    src/codeblock.cc
	src/controller.cc
    src/elf.cc
    src/emit.cc
    src/function.cc
    src/functioncolocation.cc
	src/instruction.cc
	src/javamethod.cc
    src/javaclass.cc
    src/mips.cc
    src/mips-dwarf.c
    src/registerallocator.cc
    src/string-instruction.cc
    src/syscall-wrappers.cc
    src/utils.cc)


add_executable (xcibyl-translator ${translator_SRCS} src/main.cc)
add_dependencies(xcibyl-translator omnitrace-elfutils-build zlib_copy_headers_to_destination)
if (CYGWIN)
	target_link_libraries (xcibyl-translator ${ElfUtils_LIBRARIES} pthread ${zlib_STATIC_LIBRARIES} intl)
else()
	target_link_libraries (xcibyl-translator ${ElfUtils_LIBRARIES} pthread ${zlib_STATIC_LIBRARIES})
endif()
target_include_directories(xcibyl-translator PUBLIC
	${ElfUtils_INCLUDE_DIRS}
	external/
	include/
)
