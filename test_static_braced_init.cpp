#include <iostream>

// P2752R3: Static storage for braced initializers
// Clarifies that temporaries from braced-init-lists for non-class types
// (like compound literals) used to initialize entities with static storage
// duration also have static storage duration.

// Case 1: A static variable initialized by a compound literal.
// The temporary array {10, 20, 30} should have static storage duration.
static const int* static_arr_ptr_direct = (const int[]){10, 20, 30};

// Case 2: A static reference initialized by a compound literal.
// The temporary int 123 should have static storage duration.
static const int& static_int_ref_direct = (const int&){123};

// Case 3: Function returning a pointer to a static temporary.
// This is what the DR is really about for function-local statics.
const int* get_pointer_to_static_temporary_array() {
    // This static variable ensures the compound literal has static lifetime.
    static const int* ptr = (const int[]){1,2,3,4,5};
    return ptr;
}

const int& get_reference_to_static_temporary_int() {
    static const int& ref = (const int&){777};
    return ref;
}


int main() {
    bool success = true;

    // Test Case 1 & 2
    if (static_arr_ptr_direct[0] != 10 || static_arr_ptr_direct[2] != 30) {
        std::cout << "Error: static_arr_ptr_direct values incorrect." << std::endl;
        success = false;
    }
    if (static_int_ref_direct != 123) {
        std::cout << "Error: static_int_ref_direct value incorrect." << std::endl;
        success = false;
    }

    // Test Case 3
    const int* arr_ptr1 = get_pointer_to_static_temporary_array();
    const int* arr_ptr2 = get_pointer_to_static_temporary_array();

    if (arr_ptr1 != arr_ptr2) {
        std::cout << "Error: arr_ptr1 (" << arr_ptr1 << ") != arr_ptr2 (" << arr_ptr2 << ") for static temporary array." << std::endl;
        // This should now be true as 'ptr' inside the function is static and initialized once.
        success = false;
    }
    if (arr_ptr1[0] != 1 || arr_ptr1[4] != 5) {
        std::cout << "Error: Values from get_pointer_to_static_temporary_array are incorrect." << std::endl;
        success = false;
    }

    const int& int_ref1 = get_reference_to_static_temporary_int();
    const int& int_ref2 = get_reference_to_static_temporary_int();

    if (&int_ref1 != &int_ref2) {
        std::cout << "Error: &int_ref1 (" << &int_ref1 << ") != &int_ref2 (" << &int_ref2 << ") for static temporary int." << std::endl;
        // This should now be true as 'ref' inside the function is static and initialized once.
        success = false;
    }
     if (int_ref1 != 777) {
        std::cout << "Error: Value from get_reference_to_static_temporary_int is incorrect." << std::endl;
        success = false;
    }


    if (success) {
        std::cout << "P2752R3 test seems to behave as expected." << std::endl;
        std::cout << "static_arr_ptr_direct[0] = " << static_arr_ptr_direct[0] << std::endl;
        std::cout << "static_int_ref_direct = " << static_int_ref_direct << std::endl;
        std::cout << "arr_ptr1[0] = " << arr_ptr1[0] << std::endl;
        std::cout << "int_ref1 = " << int_ref1 << std::endl;
    } else {
        std::cout << "P2752R3 test failed." << std::endl;
    }

    return !success;
}
