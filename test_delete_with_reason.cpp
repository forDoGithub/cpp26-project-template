#include <iostream>

// P2573R2: = delete("reason");

struct NoCopy {
    NoCopy() = default;
    NoCopy(const NoCopy&) = delete("This class is not copyable because it's unique.");
    NoCopy& operator=(const NoCopy&) = delete("This class cannot be copy-assigned.");
};

struct NoSpecialNew {
    // Example from the paper
    void* operator new(std::size_t) = delete("Not allowed to allocate NoSpecialNew with regular new");
    void* operator new[](std::size_t) = delete("Not allowed to allocate NoSpecialNew array with regular new");
};


void use_deleted_function() = delete("This function is deleted because it's obsolete.");

template<typename T>
void process(T t) = delete("Generic process is not allowed, specialize for your type.");

// Specialization is okay
template<>
void process<int>(int val) {
    std::cout << "Processing int: " << val << std::endl;
}


int main() {
    NoCopy nc1;
    // NoCopy nc2 = nc1; // This should fail and ideally show the reason string.
    // NoCopy nc3;
    // nc3 = nc1; // This should also fail and show the reason.

    // NoSpecialNew* nsn_ptr = new NoSpecialNew; // Should fail with reason.
    // NoSpecialNew* nsn_arr_ptr = new NoSpecialNew[5]; // Should fail with reason.

    // use_deleted_function(); // Should fail with reason.
    
    process(10); // OK
    process(10.0); // Should fail with reason. Uncomment this line to test.


    std::cout << "P2573R2 (= delete(\"reason\")) test." << std::endl;
    std::cout << "To verify, uncomment one of the failing lines and check compiler error message for the reason string." << std::endl;
    return 0;
}
