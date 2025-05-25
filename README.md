# C++26 Project Template for Windows

A professional C++26 project template with CMake, Ninja, and Clang, featuring automated setup scripts and comprehensive testing tools.

## Overview

This repository provides a complete starting point for C++26 development on Windows, including:

- **Full C++26 Support** with Clang 20.1.4+
- **Automated setup** of all required tools 
- **Modern CMake + Ninja** build configuration
- **Feature detection** for C++26 capabilities
- **Ready-to-use project structure** following best practices

## Features

- **Complete Environment Setup**: Automated installation of LLVM/Clang, CMake, Ninja, and other required tools
- **CMake Integration**: Modern CMake configuration with proper C++26 settings
- **C++26 Feature Detection**: Automatic detection and graceful fallback for C++26 features
- **Optimized vcpkg Setup**: Fast vcpkg integration using prebuilt binaries
- **Testing Infrastructure**: Comprehensive test scripts for all components
- **Windows Focus**: Designed specifically for Windows development

## Project Structure

```
cpp26-project-template/
├── CMakeLists.txt          # Main CMake configuration
├── README.md               # Project documentation
├── setup.bat               # Main setup script
├── run_all_tests.bat       # Run all test scripts
├── src/                    # Source files for root project
│   └── cpp26_test.cpp      # Demo C++26 features
├── include/                # Header files
├── examples/               # Example code
│   └── feature_demo.cpp    # Feature demonstration
├── scripts/
│   ├── setup/              # Setup scripts
│   ├── install/            # Installation scripts
│   └── build/              # Build and test scripts
│       ├── test_cpp26_simple.bat    # Simple C++26 test
│       └── test_cmake_ninja.bat     # CMake/Ninja build test
└── cmake/                  # CMake modules
```

## Getting Started

### First-Time Setup

Run the setup script to install all required tools:

```batch
setup.bat
```

This will:
1. Check for administrative privileges
2. Install required tools (Clang, CMake, Ninja, etc.)
3. Set up vcpkg for library management
4. Configure the environment

### Testing the Setup

The repository includes two test scripts in the `scripts/build` directory:

1. **Direct Compiler Test**:
   ```batch
   cd scripts/build
   test_cpp26_simple.bat
   ```
   This tests direct compilation with Clang, verifying C++26 feature support.

2. **CMake + Ninja Build Test**:
   ```batch
   cd scripts/build
   test_cmake_ninja.bat
   ```
   This tests the complete CMake/Ninja/Clang build pipeline, creating and building a C++26 project in the `example` directory.

### Run All Tests

For convenience, you can run all tests with a single command:

```batch
run_all_tests.bat
```

### Building Your Own Project

After setup, you can build the root project using:

```batch
mkdir build && cd build
cmake .. -G "Ninja" -DCMAKE_CXX_COMPILER=clang++
ninja
```

## C++26 Features

This template tests and supports various C++26 features:

- **`std::print`** and **`std::println`** for formatted output
- **`std::spanstream`** for I/O operations on spans
- **`std::expected`** for representing operations that can return a value or an error
- **Other C++26 features** as they become available

## Customization

To customize this template for your own project:

1. Modify the CMakeLists.txt to add your own source files
2. Adjust the project name and version
3. Add your own code to src/ and include/ directories
4. Run the build commands to verify everything works

## Requirements

- **Windows 10/11**
- **Administrator privileges** for setup
- **Visual Studio 2022** with C++ workload (for clang-cl)

## Version Information

- **Clang**: 20.1.4 (default)
- **CMake**: 3.27.8 (default)
- **Ninja**: Latest available

## Tools and Libraries

The setup script will automatically install or check for:

- **LLVM/Clang**: C++26-compatible compiler
- **CMake**: Modern build system
- **Ninja**: Fast build tool
- **Python**: Required for some tools
- **vcpkg**: C++ library manager

## Troubleshooting

If you encounter issues:

1. Check that Visual Studio with C++ workload is installed
2. Verify that the PATH environment variable includes the tools
3. Run the test scripts to identify specific issues
4. Check the log output for detailed error messages

## License

This project is released under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. 