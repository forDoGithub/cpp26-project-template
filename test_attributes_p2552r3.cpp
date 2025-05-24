// P2552R3: On the ignorability of standard attributes.
// This DR clarifies rules for ignoring standard attributes in certain positions.

// Example from the paper:
// struct [[nodiscard]] S {}; // This was previously ill-formed.
// P2552R3 makes it so that if [[nodiscard]] appertains to S, it's fine.

struct [[nodiscard]] S1 {}; // Test case 1: attribute on the struct definition itself

[[nodiscard]] struct S2 {}; // Standard usage for comparison

class C1 {
    // The paper mentions: "A standard attribute should not be specified in a location
    // where it is not defined to be applicable."
    // "Implementations should diagnose such usages."
    // "However, if an attribute-specifier-seq appertains to an entity and consists
    // of an attribute-using-prefix followed by an attribute-list, an implementation
    // shall ignore unknown attributes in the attribute-list."
    // This DR seems to focus more on *unknown* attributes or attributes whose grammar
    // allows them in a position but semantics aren't defined.

    // Let's try a standard attribute on a member variable where it might not have a defined meaning,
    // but is syntactically plausible.
    // [[nodiscard]] int x; // This is often allowed and means getter should be nodiscard.

    // Let's try a hypothetical "unknown" standard attribute.
    // The challenge is that the compiler doesn't know it's "standard".
    // [[std::some_future_attribute_that_is_unknown_now]] int y;

    // P2552R3 is subtle. Let's try the exact example from the paper's abstract.
    int f [[nodiscard]] (); // attribute appertains to f
};

// The core point of the example in the paper:
// struct [[nodiscard]] S {}; was ill-formed because the attribute didn't appertain to the name S in that position.
// The resolution is that if the attribute specifier sequence appertains to an entity, unknown attributes are ignored.
// And standard attributes should be ignored if they appear in a location not specified by the standard,
// *provided the attribute syntax allows them there*.

// Let's try the struct example.
struct [[nodiscard]] MyStruct { int i; }; // Example from paper abstract.

// And a function example
int my_func [[nodiscard]] (); // attribute for my_func

int main() {
    MyStruct s_obj; // To ensure MyStruct is used.
    // (void)s_obj; // Avoid unused warning, though nodiscard on struct is about the type.
    return 0;
}
