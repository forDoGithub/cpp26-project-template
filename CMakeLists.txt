cmake_minimum_required(VERSION 3.20)

# C++26 Project Template
project(cpp26-project-template 
  VERSION 0.1.0
  DESCRIPTION "C++26 project template with CMake, Ninja, and Clang"
  LANGUAGES CXX
)

# Set C++26 standard
set(CMAKE_CXX_STANDARD 26)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Use folders in IDE solutions
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

# Compiler-specific options
if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  if(MSVC)
    add_compile_options(/std:c++latest)
  else()
    add_compile_options(-std=c++2c)
  endif()
endif()

# Default to Release build type if not specified
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")

# Output binary to predictable location
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# Simple example executable to test C++26 features
add_executable(cpp26_test src/cpp26_test.cpp)

# Display compiler information
message(STATUS "C++ compiler: ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "C++ standard: C++26")

# Include directories
include_directories(${PROJECT_SOURCE_DIR}/include)

# Print configuration summary
message(STATUS "")
message(STATUS "=== ${PROJECT_NAME} v${PROJECT_VERSION} Configuration Summary ===")
message(STATUS "Build type:              ${CMAKE_BUILD_TYPE}")
message(STATUS "C++ Standard:            ${CMAKE_CXX_STANDARD}")
message(STATUS "Compiler:                ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "Install prefix:          ${CMAKE_INSTALL_PREFIX}")
message(STATUS "======================================================")
message(STATUS "") 