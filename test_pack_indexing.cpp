#include <iostream>
#include <string>

// P2662R3: Pack indexing

template<typename... Ts>
void print_element(size_t i, Ts... args) {
    // This is the proposed syntax: args...[i]
    // However, direct use in a simple function like this is tricky because
    // the type of args...[i] is not known at compile time in a way that
    // std::cout can easily handle without further machinery (like std::variant or std::any).

    // A common use case is with std::get on a tuple created from the pack.
    // P2662R3 aims to make direct indexing more intuitive.
    // The paper shows examples like:
    // template<class... Types>
    // struct variant { Types...[idx] data; /* ... */ };
    //
    // template<class R, class... Types>
    // R invoke(R(*f)(Types...), Types... args) {
    //   return f(args...[0], args...[1]); // if pack has at least 2 elements
    // }

    // Let's try to implement a simple tuple-like get.
    // We need a helper to get the type.
    // This is more involved than a simple print.

    // For a minimal test, let's try to assign it, assuming types are compatible or convertible.
    // This requires knowing the types in the pack.
    if constexpr (sizeof...(args) > 0) {
        // The following line is the direct test of the feature's syntax.
        // If the syntax args...[i] is not supported, this will fail to compile.
        // To make it runnable, we need to ensure 'i' is within bounds and the type is printable.
        // Let's assume 'i' is 0 and the first type is printable.
        if (i < sizeof...(args)) {
            // This is still problematic for a generic std::cout.
            // Let's try to get the first element if it exists.
            // auto first_element = args...[0]; // This is the syntax
            // std::cout << "Element at index 0: " << first_element << std::endl;

            // The proposal mentions "The type of the pack-indexing-expression args...[i] is
            // the type of the i-th element of the pack args."
            //
            // "A pack-indexing-expression is an xvalue if the i-th element of the pack is an rvalue reference,
            // and an lvalue otherwise."

            // Let's try a context where types are known and limited.
            // This specific test might be too simple or misuse the intended context.
        }
    }
}

template <typename T, typename... Ts>
void print_specific_index(size_t index, const T& first, const Ts&... rest) {
    if (index == 0) {
        std::cout << "Element at index " << index << ": " << first << std::endl;
    } else if constexpr (sizeof...(rest) > 0) {
        // This is recursive, not using pack indexing directly for selection.
        // print_specific_index(index - 1, rest...);
    }
}


// Example from P2662R3 (adapted)
template<class... Types>
struct S {
    std::tuple<Types...> t;
    template<size_t N>
    decltype(auto) get() {
        // This is how you'd do it with std::get
        // return std::get<N>(t);

        // With pack indexing, if Types... was directly accessible as a pack 'values':
        // return values...[N]; // This is hypothetical if 'values' was a pack here.
        // The proposal is about indexing the pack 'Types' itself in certain contexts,
        // or a function parameter pack 'args...'.
        return 0; // Placeholder
    }
};


// More direct test based on paper's intent for function parameter packs
template<typename... Args>
void process_args(Args... args) {
    if constexpr (sizeof...(Args) > 1) {
        // Get the element at index 1 (second element)
        // The type of element_1 will be the type of the second argument.
        auto element_1 = args...[1]; 
        std::cout << "Second element: " << element_1 << std::endl;
    } else {
        std::cout << "Not enough elements for index 1." << std::endl;
    }

    if constexpr (sizeof...(Args) > 0) {
        auto element_0 = args...[0];
        std::cout << "First element: " << element_0 << std::endl;
    } else {
        std::cout << "No elements." << std::endl;
    }
}


int main() {
    print_element(0, 10, "hello", 3.14);
    print_element(1, 10, "hello", 3.14);

    process_args(100, std::string("test"), 2.718);
    process_args(42);
    process_args();

    std::cout << "P2662R3 (Pack indexing) test." << std::endl;
    return 0;
}
