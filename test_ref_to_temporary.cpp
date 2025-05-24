#include <iostream>
#include <vector>
#include <string>

// P2748R5: Disallow binding a returned reference to a temporary (especially in range-for)

struct TempHolder {
    std::vector<int> v = {1,2,3};
    const std::vector<int>& get_v_ref() const { 
        std::cout << "TempHolder::get_v_ref() called for object at " << this << std::endl;
        return v; 
    }
    TempHolder() {
        std::cout << "TempHolder created at " << this << std::endl;
    }
    ~TempHolder() {
        std::cout << "TempHolder destroyed at " << this << std::endl;
    }
};

// This function returns a reference to a member of a temporary.
const std::vector<int>& get_vector_ref_from_temp() {
    std::cout << "get_vector_ref_from_temp() called" << std::endl;
    const auto& ref_to_member = TempHolder().get_v_ref(); 
    // TempHolder() is a prvalue. Its lifetime ends here.
    // ref_to_member is now dangling if TempHolder is destroyed.
    // P2748R5 aims to make uses of such references in for-range-initializers ill-formed.
    std::cout << "get_vector_ref_from_temp() returning..." << std::endl;
    return ref_to_member;
}

int main() {
    std::cout << "P2748R5 (Disallow binding returned reference to temporary) test." << std::endl;
    
    // According to P2748R5, this should be ill-formed because TempHolder() in get_vector_ref_from_temp()
    // is a temporary, its lifetime is not extended by the reference binding in the for-range-initializer,
    // so 'x' would effectively iterate over a dangling reference.
    // The range expression `get_vector_ref_from_temp()` itself returns a reference, but this reference
    // refers to a part of a temporary object (`TempHolder()`) whose lifetime has ended.
    
    std::cout << "Calling range-for loop..." << std::endl;
    for (int x : get_vector_ref_from_temp()) { // <<< This is the key test
        std::cout << "x: " << x << std::endl; // This will likely crash if compiled.
    }
    std::cout << "Range-for loop finished." << std::endl;

    std::cout << "If the range-for loop above causes a compile error, the feature (P2748R5) is supported." << std::endl;
    std::cout << "If it compiles and runs (likely crashing or showing garbage), it's not." << std::endl;

    return 0;
}
