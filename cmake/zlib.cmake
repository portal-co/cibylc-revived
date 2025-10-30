include (ExternalProject)

  set(zlib_INCLUDE_DIR ${CMAKE_CURRENT_BINARY_DIR}/external/zlib_archive)
  set(ZLIB_URL https://github.com/zlib-ng/zlib-ng.git)
  set(ZLIB_BUILD ${CMAKE_CURRENT_BINARY_DIR}/zlib/src/zlib)
  set(ZLIB_INSTALL ${CMAKE_CURRENT_BINARY_DIR}/zlib/install)
  # Match zlib version in tensorflow/workspace.bzl
  set(ZLIB_TAG 2.2.5)

  if(WIN32)
    if(${CMAKE_GENERATOR} MATCHES "Visual Studio.*")
      set(zlib_STATIC_LIBRARIES
          debug ${CMAKE_CURRENT_BINARY_DIR}/zlib/install/lib/zlibstaticd.lib
          optimized ${CMAKE_CURRENT_BINARY_DIR}/zlib/install/lib/zlibstatic.lib)
    else()
      if(CMAKE_BUILD_TYPE EQUAL Debug)
        set(zlib_STATIC_LIBRARIES
            ${CMAKE_CURRENT_BINARY_DIR}/zlib/install/lib/zlibstaticd.lib)
      else()
        set(zlib_STATIC_LIBRARIES
            ${CMAKE_CURRENT_BINARY_DIR}/zlib/install/lib/zlibstatic.lib)
      endif()
    endif()
  else()
    set(zlib_STATIC_LIBRARIES
        ${CMAKE_CURRENT_BINARY_DIR}/zlib/install/lib/libz.a)
  endif()

  set(ZLIB_HEADERS
      "${ZLIB_INSTALL}/include/zconf.h"
      "${ZLIB_INSTALL}/include/zlib.h"
  )

  ExternalProject_Add(zlib
      PREFIX zlib
      GIT_REPOSITORY ${ZLIB_URL}
      GIT_TAG ${ZLIB_TAG}
      INSTALL_DIR ${ZLIB_INSTALL}
      BUILD_IN_SOURCE 1
      BUILD_BYPRODUCTS ${zlib_STATIC_LIBRARIES}
      DOWNLOAD_DIR "${DOWNLOAD_LOCATION}"
      CMAKE_CACHE_ARGS
          -DCMAKE_BUILD_TYPE:STRING=Release
          -DCMAKE_INSTALL_PREFIX:STRING=${ZLIB_INSTALL}
    CMAKE_ARGS
    -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
    -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
    -DBUILD_SHARED_LIBS=OFF -DZLIB_BUILD_SHARED=OFF -DZLIB_BUILD_TESTING=OFF -DZLIB_BUILD_MINIZIP=OFF -DEMSCRIPTEN=1 -DZLIB_ENABLE_TESTS=OFF -DZLIB_COMPAT=ON
  )

  # put zlib includes in the directory where they are expected
  add_custom_target(zlib_create_destination_dir
      COMMAND ${CMAKE_COMMAND} -E make_directory ${zlib_INCLUDE_DIR}
      DEPENDS zlib)

  add_custom_target(zlib_copy_headers_to_destination
      DEPENDS zlib_create_destination_dir)

  foreach(header_file ${ZLIB_HEADERS})
      add_custom_command(TARGET zlib_copy_headers_to_destination PRE_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy_if_different ${header_file} ${zlib_INCLUDE_DIR})
  endforeach()
