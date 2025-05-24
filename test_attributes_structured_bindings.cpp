#include <iostream>
#include <tuple>

// P0609R3: Attributes for structured bindings

struct Point {
    int x;
    int y;
};

std::pair<int, int> get_pair() {
    return {10, 20};
}

Point get_point() {
    return {100, 200};
}

int main() {
    // Test 1: [[maybe_unused]] on structured binding elements
    auto [ [[maybe_unused]] first_val, [[maybe_unused]] second_val ] = get_pair();
    // Use only one to see if the other's [[maybe_unused]] is respected.
    std::cout << "Used only first_val from get_pair(): " << first_val << std::endl;


    // Test 2: Apply to a non-POD type
    auto [ [[maybe_unused]] px, py ] = get_point();
    // Only use py
    std::cout << "Used only py from get_point(): " << py << std::endl;


    // Test 3: Using a custom attribute (if the syntax is generally allowed)
    // This is unlikely to work unless the attribute is known, but tests the grammar.
    // struct [[my_attr]] MyS {}; // This would require the attribute to be defined.
    // For structured bindings, the attribute applies to the generated variable.
    // auto [ [[my_silly_attr]] v1, v2 ] = get_pair(); 


    // Test 4: Multiple attributes
    // This is syntactically challenging with current attribute syntax if not careful.
    // P0609R3 shows examples like: auto [x, [[maybe_unused]] y, [[deprecated]] z]
    std::tuple<int, int, int> my_tuple = {1,2,3};
    auto [ val_x, [[maybe_unused]] val_y, [[deprecated("This binding is deprecated")]] val_z ] = my_tuple;
    
    std::cout << "val_x from tuple: " << val_x << std::endl;
    // std::cout << "val_z from tuple: " << val_z << std::endl; // Accessing would give deprecation warning

    std::cout << "P0609R3 (Attributes for structured bindings) test." << std::endl;
    std::cout << "Check for warnings (e.g., unused for non-attributed, deprecated for attributed)." << std::endl;
    std::cout << "Successful if compiles and warnings behave as expected." << std::endl;

    return 0;
}
