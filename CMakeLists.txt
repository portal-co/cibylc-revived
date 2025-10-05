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


set (translator_SRCS
	external/elfutils/dwarf_abbrev_hash.c
	external/elfutils/dwarf_attr.c
	external/elfutils/dwarf_attr_integrate.c
	external/elfutils/dwarf_begin_elf.c
	external/elfutils/dwarf_child.c
	external/elfutils/dwarf_end.c
	external/elfutils/dwarf_end.c
	external/elfutils/dwarf_error.c
	external/elfutils/dwarf_formaddr.c
	external/elfutils/dwarf_formref.c
	external/elfutils/dwarf_formref_die.c
	external/elfutils/dwarf_formudata.c
	external/elfutils/dwarf_getabbrev.c
	external/elfutils/dwarf_hasattr.c
	external/elfutils/dwarf_hasattr_integrate.c
	external/elfutils/dwarf_lowpc.c
	external/elfutils/dwarf_nextcu.c
	external/elfutils/dwarf_offdie.c
	external/elfutils/dwarf_siblingof.c
	external/elfutils/dwarf_sig8_hash.c
	external/elfutils/dwarf_tag.c
	external/elfutils/frame-cache.c
	external/elfutils/libdw_alloc.c
	external/elfutils/libdw_findcu.c
	external/elfutils/libdw_form.c
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

include_directories(
	external/elfutils/
	external/
	include/
)

add_executable (xcibyl-translator ${translator_SRCS})
if (CYGWIN)
	target_link_libraries (xcibyl-translator elf intl)
else()
	target_link_libraries (xcibyl-translator elf)
endif()
