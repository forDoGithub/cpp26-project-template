cmake_minimum_required(VERSION 3.20)

# Simple test framework for C++26 features
add_executable(features_test
    features_test.cpp
)

# Link to the main library
target_link_libraries(features_test PRIVATE ${PROJECT_NAME}_lib)

# Add test
add_test(
    NAME features_test
    COMMAND features_test
) 