#include <cstdint>

struct MyType {
    int value;
};

consteval bool test_cast() {
    MyType obj = {42};
    const void* vp = &obj;

    // P2738R1: Allow reinterpret_cast from void* in constexpr contexts
    // if the void* actually points to an object of the target type.
    const MyType* ptr = reinterpret_cast<const MyType*>(vp);

    if (ptr->value == 42) {
        return true;
    }
    return false;
}

// Further test: casting to char* to inspect object representation
consteval char get_first_byte() {
    int i = 0x12345678; // Assuming little-endian, first byte is 0x78
    const void* vp = &i;
    const char* cp = reinterpret_cast<const char*>(vp);
    return cp[0];
}

int main() {
    static_assert(test_cast(), "Constexpr cast from void* to MyType* failed");
    
    // Note: The proposal P2738R1 explicitly mentions that casting T* to void*
    // and then to char* to inspect object representation is a key motivation.
    constexpr char first_byte = get_first_byte();
    // On a little-endian system, this should be 0x78.
    // On a big-endian system, this would be 0x12.

    // We can't easily print this at compile time without more machinery,
    // but if the static_assert passes and this compiles, the feature is working.
    // To make it verifiable at runtime:
    if (first_byte == (char)0x78 || first_byte == (char)0x12) {
        // One of these must be true depending on endianness
    } else {
        return 1; // Fail
    }

    return 0;
}
