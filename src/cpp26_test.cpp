#include <iostream>
#include <string>

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
    std::cout << "C++26 Feature Test\n\n";

    // Test C++26 std::print if available
    #if HAS_PRINT
        std::println("SUCCESS: std::print is available!");
        int value = 42;
        std::string name = "C++26";
        std::print("Formatted output: {0} = {1}\n", name, value);
    #else
        std::cout << "std::print is not available\n";
    #endif

    // Test C++26 std::spanstream if available
    #if HAS_SPANSTREAM
        std::cout << "\nC++26 spanstream is available!\n";
        
        // Create a span over some data
        char buffer[100] = {};
        std::span<char, 100> my_span(buffer);
        
        // Write to the span
        std::ospanstream oss(my_span);
        oss << "Hello from spanstream!";
        
        // Print the data in the span
        std::cout << "Data written to span: " << buffer << "\n";
    #else
        std::cout << "\nC++26 spanstream is not available\n";
    #endif

    std::cout << "\nCompiler Information:\n";
    std::cout << "Clang version: " << __clang_major__ << "." << __clang_minor__ << "\n";
    std::cout << "__cplusplus = " << __cplusplus << "\n";

    return 0;
} 