/**
 * C++26 Feature Demonstration
 * 
 * This file demonstrates some of the key features available in C++26
 * that are supported by Clang.
 */

#include <iostream>
#include <string>
#include <vector>
#include <utility>

// Check for C++26 features
#if __has_include(<print>)
#include <print>
#define HAS_PRINT 1
#else
#define HAS_PRINT 0
#endif

#if __has_include(<spanstream>)
#include <spanstream>
#include <span>
#define HAS_SPANSTREAM 1
#else
#define HAS_SPANSTREAM 0
#endif

int main() {
    std::cout << "C++26 Feature Demonstration\n";
    std::cout << "===========================\n\n";

    // 1. std::print and std::println
    std::cout << "1. std::print/println Feature:\n";
    #if HAS_PRINT
        std::println("  - std::println is available!");
        
        // Format specifiers with named arguments
        int value = 42;
        std::string name = "C++26";
        std::print("  - Named arguments: {{name}} = {{value}}\n", 
                 std::make_format_args("name"_a = name, "value"_a = value));
                 
        // Positional arguments
        std::print("  - Positional arguments: {0} = {1}\n", name, value);
    #else
        std::cout << "  - std::print is not available\n";
    #endif
    std::cout << "\n";

    // 2. std::spanstream (if available)
    std::cout << "2. std::spanstream Feature:\n";
    #if HAS_SPANSTREAM
        // Create a span over some data
        char buffer[100] = {};
        std::span<char, 100> my_span(buffer);
        
        // Write to the span
        std::ospanstream oss(my_span);
        oss << "Hello from spanstream!";
        
        // Print the data in the span
        std::cout << "  - Data written to span: " << buffer << "\n";
        
        // Read from a span
        const char* input_data = "42 3.14 Hello";
        std::ispanstream iss(std::span<const char>{input_data, std::strlen(input_data)});
        
        int i;
        double d;
        std::string s;
        
        iss >> i >> d >> s;
        std::cout << "  - Read from span: " << i << ", " << d << ", " << s << "\n";
    #else
        std::cout << "  - std::spanstream is not available\n";
    #endif
    std::cout << "\n";

    // Compiler information
    std::cout << "Compiler Information:\n";
    std::cout << "  - Clang version: " << __clang_major__ << "." << __clang_minor__ << "\n";
    std::cout << "  - __cplusplus = " << __cplusplus << "\n";

    return 0;
} 