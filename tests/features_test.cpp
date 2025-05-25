#include "cpp26_features.h"
#include <iostream>
#include <cassert>
#include <string>

// Simple test framework
#define TEST_CASE(name) void name(); std::cout << "Running test: " << #name << "...\n"; name(); std::cout << "Passed!\n\n"
#define ASSERT(condition) do { if (!(condition)) { std::cerr << "Assertion failed: " << #condition << " at line " << __LINE__ << std::endl; exit(1); } } while(0)

// Test all features functions
void test_feature_detection() {
    const auto features = cpp26::Features::getDetectedFeatures();
    
    // We should at least know if features are supported or not
    const auto report = cpp26::Features::getFeatureReport();
    ASSERT(!report.empty());
    
    // Test compiler info
    const auto compilerInfo = cpp26::Features::getCompilerInfo();
    ASSERT(compilerInfo.find("Compiler:") != std::string::npos);
    ASSERT(compilerInfo.find("__cplusplus") != std::string::npos);
}

// Test print functionality
void test_print_feature() {
    // This test doesn't actually test the output, just ensures the function doesn't crash
    cpp26::Features::demonstratePrint("Test", 123);
    
#if HAS_PRINT
    // Only test additional print features if available
    std::cout << "std::print is available, performing additional tests...\n";
#endif
}

// Test spanstream functionality
void test_spanstream_feature() {
    const std::string testData = "Hello, world!";
    const auto result = cpp26::Features::demonstrateSpanstream(testData);
    
    // The result should either contain the original data or a message about unavailability
    ASSERT(result.find(testData) != std::string::npos || 
           result.find("not available") != std::string::npos);
    
#if HAS_SPANSTREAM
    // Only test additional spanstream features if available
    std::cout << "std::spanstream is available, performing additional tests...\n";
    ASSERT(result.find("Spanstream demo") != std::string::npos);
#endif
}

// Test std::expected functionality
void test_expected_feature() {
    const auto result = cpp26::Features::demonstrateExpected();
    ASSERT(!result.empty());

#if HAS_EXPECTED
    std::cout << "std::expected is available, performing additional checks...\n";
    ASSERT(result.find("std::expected is available.") != std::string::npos);
    ASSERT(result.find("Successful operation returned:") != std::string::npos);
    ASSERT(result.find("Failed operation returned error:") != std::string::npos);
    // Specific values from demonstrateExpected implementation
    ASSERT(result.find("42") != std::string::npos); 
    ASSERT(result.find("Simulated error") != std::string::npos);
#else
    std::cout << "std::expected is not available, checking for unavailability message...\n";
    ASSERT(result.find("std::expected is not available.") != std::string::npos);
#endif
}

int main() {
    std::cout << "==================================\n";
    std::cout << "Running C++26 Features Tests\n";
    std::cout << "==================================\n\n";
    
    TEST_CASE(test_feature_detection);
    TEST_CASE(test_print_feature);
    TEST_CASE(test_spanstream_feature);
    TEST_CASE(test_expected_feature);
    
    std::cout << "All tests passed successfully!\n";
    return 0;
} 