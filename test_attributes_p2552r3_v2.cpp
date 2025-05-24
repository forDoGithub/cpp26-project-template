#include <iostream>
// P2552R3: On the ignorability of standard attributes.
// If an attribute-specifier-seq appertains to an entity and consists of
// an attribute-using-prefix followed by an attribute-list, an implementation
// shall ignore unknown attributes in the attribute-list.

struct [[std::hypothetical_future_standard_attribute_for_struct(123)]] TestStruct {
    int x;
};

[[std::another_unknown_one]] void test_func() {
    std::cout << "Test function called." << std::endl;
}

int main() {
    TestStruct t;
    t.x = 10;
    test_func();
    std::cout << "Test for P2552R3: Ignorability of unknown standard attributes." << std::endl;
    std::cout << "If compiled without error for unknown 'std::' attributes, it's a sign of support." << std::endl;
    return 0;
}
