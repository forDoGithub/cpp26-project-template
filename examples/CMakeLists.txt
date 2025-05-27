cmake_minimum_required(VERSION 3.20)

# Add examples
add_executable(feature_demo feature_demo.cpp)
target_link_libraries(feature_demo PRIVATE cpp26_features_lib)
set_target_properties(feature_demo PROPERTIES FOLDER "Examples")

# Additional examples can be added here 