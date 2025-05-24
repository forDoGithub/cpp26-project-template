#include <tuple>
#include <optional>
#include <iostream>

// P2169R4: Placeholder variables with no name

struct Point { int x, y, z; };

std::tuple<int, double, char> get_tuple() {
    return {1, 2.5, 'a'};
}

int main() {
    // Case 1: Structured bindings
    Point p = {10, 20, 30};
    auto [x, _, z] = p; // y is unused, placeholder _
    std::cout << "x: " << x << ", z: " << z << std::endl;

    // Case 2: Simple declaration
    // int _ = 123; // This is not the primary motivation, but should be valid.
                 // P2169R4 states: "A declaration that declares only placeholder variables is well-formed."
                 // "An underscore token can be used as an identifier in a declaration."
                 // "A name that is a placeholder variable can be used anywhere a variable
                 //  name is permitted but has no effect."

    // Let's test if it can be "used" (which should have no effect or be optimized out)
    // int Porter = 5; // Deliberately naming it something else to avoid confusion with the placeholder.
    // Porter = Porter + 1; // This would be an error if _ was a "true" placeholder that can't be read.
                     // The proposal says "has no effect" which is subtle.
                     // "A placeholder variable is intentionally not used. Any use of a placeholder variable
                     //  as an expression should be ill-formed."
                     // So, `_ = _ + 1;` should be ill-formed.

    // Let's try the ill-formed case:
    // int _ = 10;
    // _ = _ + 5; // This should be an error if _ is a placeholder variable.
    // However, if it's just a regular variable named _, it's fine.
    // The proposal makes `_` special when *introduced* as a placeholder.

    // The paper says: "An id-expression that names a placeholder variable is ill-formed."

    // Test with function parameters (if applicable, though less common focus)
    // auto func = [](int _, double val){ std::cout << "Value: " << val << std::endl; };
    // func(100, 3.14);

    // Test with tuple decomposition
    auto [val_i, _, val_c] = get_tuple();
    std::cout << "val_i: " << val_i << ", val_c: " << val_c << std::endl;

    // Test with std::optional
    std::optional<int> opt_val(42);
    if (auto [_] = opt_val; _.has_value()) { // Using _ in the init-statement of if
        // The _ here refers to the optional itself, not its value.
        // This specific syntax for if-init with structured binding for optional
        // is a bit convoluted. Let's simplify.
    }

    // More direct test:
    // A declaration of just `_`
    // int _; // This declares a variable named underscore. P2169R4 intends to make this a placeholder.
    // The proposal: "An underscore token that appears as an identifier in a simple-declaration,
    // where the declared name is not preceded by a decl-specifier-seq, is a placeholder variable declaration."
    // This seems to conflict with "A name that is a placeholder variable can be used anywhere a variable name is permitted"
    // The core idea is that `_` in a *destructuring* context (like structured bindings) is a placeholder.

    // Let's focus on structured bindings as the primary test case.
    auto [a, _, _] = p; // Multiple placeholders
    std::cout << "a: " << a << std::endl;

    // Test from paper: for loop
    for (int arr[] = {1,2,3}, _ : arr) {
        // Here, _ should be a placeholder for the element.
        // Using _ in the loop body should be ill-formed.
        // (void)_; // This would be an error if _ is a placeholder.
    }
    std::cout << "For loop with placeholder compiled." << std::endl;


    // Test from paper: lambda
    auto l = [_ = 100](int x){ return _ + x; }; // Here _ is a capture with init, a normal variable.
    // auto l_placeholder = [](int _){ return _ + 1; }; // This should be an error if _ is placeholder.
    // The paper clarifies: "An underscore token used as an identifier in a lambda declarator
    // does not declare a placeholder variable." So this is not a test for P2169R4.

    // The most unambiguous test is structured bindings.
    std::cout << "P2169R4 (Placeholder variables) test focuses on structured bindings." << std::endl;

    return 0;
}
