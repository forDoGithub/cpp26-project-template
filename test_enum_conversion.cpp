#include <iostream>

// P2864R2: Removing deprecated arithmetic conversion on enumerations

enum class MyScopedEnum { Val1 = 1, Val2 = 2 };
enum MyUnscopedEnum { V1 = 10, V2 = 20 };

int main() {
    MyScopedEnum se = MyScopedEnum::Val1;
    MyUnscopedEnum ue = V1;

    // For scoped enums, implicit conversion to int is already disallowed.
    // int r1 = se + 1; // ERROR: MyScopedEnum to int not allowed for arithmetic
    // To make this work, one needs:
    int r1_ok = static_cast<int>(se) + 1;
    std::cout << "r1_ok: " << r1_ok << std::endl;

    // For unscoped enums, implicit conversion to int is currently allowed (but deprecated).
    // P2864R2 aims to remove this.
    // If P2864R2 is implemented, the following line should be an error.
    int r2 = ue + 1; 
    // If it's not implemented (or if the deprecation removal is not yet active), it will compile.

    std::cout << "ue (raw): " << ue << std::endl; // This direct use might still be okay or use underlying type
    std::cout << "r2 (ue + 1): " << r2 << std::endl;

    // To be sure, let's try an operation that forces arithmetic promotion
    long r3 = ue + 1L; // ue promotes to int, then to long.
    std::cout << "r3 (ue + 1L): " << r3 << std::endl;

    // If the feature is active, one would need:
    int r2_explicit = static_cast<int>(ue) + 1;
    std::cout << "r2_explicit: " << r2_explicit << std::endl;

    // Another test: comparison
    // bool b1 = ue < 15; // This would also be affected.
    // If P2864R2 is implemented, this should be an error.
    bool b1 = ue < 15; 
    std::cout << "ue < 15: " << (b1 ? "true" : "false") << std::endl;
    
    bool b1_explicit = static_cast<int>(ue) < 15;
    std::cout << "static_cast<int>(ue) < 15: " << (b1_explicit ? "true" : "false") << std::endl;


    // Check if the compiler issues a warning for the deprecated conversion if the feature is not yet fully removing it.
    // (This would depend on warning levels like -Wdeprecated or -Wc++23-compat etc.)

    std::cout << "P2864R2 (Removing deprecated arithmetic conversion on enumerations) test." << std::endl;
    std::cout << "If implicit conversion 'ue + 1' or 'ue < 15' fails to compile, the feature is supported." << std::endl;
    std::cout << "Otherwise, it's not, or the compiler is still allowing deprecated conversions." << std::endl;

    return 0;
}
