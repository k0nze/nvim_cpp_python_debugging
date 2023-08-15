cmake_minimum_required(VERSION 3.16)
project(pybind_example CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

find_package(Git)

# download submodules if they aren't present
if(GIT_FOUND AND EXISTS "${PROJECT_SOURCE_DIR}/.git")
    # update submodules
    option(GIT_SUBMODULE "Check submodules during build" ON)
    if(GIT_SUBMODULE)
        message(STATUS "Submodule update")
        execute_process(
            COMMAND ${GIT_EXECUTABLE} submodule update --init --recursive
            WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
            RESULT_VARIABLE GIT_SUBMOD_RESULT)
        if(NOT GIT_SUBMOD_RESULT EQUAL "0")
            message(
                FATAL_ERROR
                    "git submodule update --init --recursive failed with $GIT_SUBMOD_RESULT}, please check git log"
            )
        endif()
    endif()
endif()

# generate debug symbols
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g")

# globally enable -fPIC
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

set(MOVE_LIB
    "OFF"
    CACHE STRING "libpybind_example is moved into src/backend")

set(MOVE_CPYTHON_SO
    "OFF"
    CACHE STRING "cpython.so is moved into src/backend")

# tell CMake where pybind11 is
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/external/pybind11)

set(BACKEND_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src/backend)

add_library(
    libpybind_example SHARED
    ${BACKEND_SOURCE_DIR}/animal.cc ${BACKEND_SOURCE_DIR}/dog.cc
    ${BACKEND_SOURCE_DIR}/cat.cc)

target_compile_options(libpybind_example INTERFACE "-fsized-deallocation")

# rename liblibpybind_example to libpybind_example
set_target_properties(libpybind_example PROPERTIES OUTPUT_NAME "pybind_example")

if(MOVE_LIB)
    # move lib into backend directory
    set_target_properties(libpybind_example PROPERTIES LIBRARY_OUTPUT_DIRECTORY
                                                       ${BACKEND_SOURCE_DIR})
endif()

pybind11_add_module(pybind_example ${BACKEND_SOURCE_DIR}/wrapper.cc)

target_link_libraries(pybind_example PRIVATE libpybind_example)

if(MOVE_CPYTHON_SO)
    # move cpython.so into backend directory
    set_target_properties(pybind_example PROPERTIES LIBRARY_OUTPUT_DIRECTORY
                                                    ${BACKEND_SOURCE_DIR})
endif()
