#include "cpp26_features.h"
#include <iostream>
#include <sstream>
#include <string>
#include <vector> // Already included but good to ensure

#ifdef __clang__
#define COMPILER_NAME "Clang"
#define COMPILER_VERSION __clang_major__ << "." << __clang_minor__
#elif defined(_MSC_VER)
#define COMPILER_NAME "MSVC"
#define COMPILER_VERSION _MSC_VER
#elif defined(__GNUC__)
#define COMPILER_NAME "GCC"
#define COMPILER_VERSION __GNUC__ << "." << __GNUC_MINOR__
#else
#define COMPILER_NAME "Unknown"
#define COMPILER_VERSION "?"
#endif

namespace cpp26 {

std::string Features::getFeatureReport() {
    std::ostringstream report;
    report << "C++26 Feature Report:\n";
    report << "------------------\n";
    
    // List detected features
    auto features = getDetectedFeatures();
    if (features.empty()) {
        report << "No C++26 features detected.\n";
    } else {
        report << "Detected C++26 features:\n";
        for (const auto& feature : features) {
            report << "- " << feature << "\n";
        }
    }
    
    report << "\n" << getCompilerInfo() << "\n";
    return report.str();
}

std::string Features::getCompilerInfo() {
    std::ostringstream info;
    info << "Compiler: " << COMPILER_NAME << " " << COMPILER_VERSION << "\n";
    info << "__cplusplus = " << __cplusplus;
    return info.str();
}

void Features::demonstratePrint(const std::string& text, int value) {
#if HAS_PRINT
    std::print("Demonstrating std::print: {} = {}\n", text, value);
    std::println("This line uses std::println");
#else
    std::cout << "std::print is not available.\n";
    std::cout << "Using std::cout instead: " << text << " = " << value << "\n";
#endif
}

std::string Features::demonstrateSpanstream(const std::string& data) {
#if HAS_SPANSTREAM
    const std::string prefix = "Spanstream demo: ";
    // Allocate buffer for prefix, data, and a potential null terminator.
    std::vector<char> buffer(prefix.length() + data.length() + 1); 

    std::span<char> my_span(buffer.data(), buffer.size());
    
    std::ospanstream oss(my_span);
    oss << prefix << data;
    
    // oss.str() returns a span of the characters actually written.
    std::span<char> written_span = oss.str();
    return std::string(written_span.data(), written_span.size());
#else
    return "std::spanstream is not available. Input data: " + data;
#endif
}

std::vector<std::string> Features::getDetectedFeatures() {
    std::vector<std::string> features;
    
#if HAS_PRINT
    features.push_back("std::print & std::println");
#endif

#if HAS_SPANSTREAM
    features.push_back("std::spanstream");
#endif

#if HAS_EXPECTED
    features.push_back("std::expected");
#endif

    return features;
}

std::string Features::demonstrateExpected() {
    std::ostringstream oss;
#ifdef HAS_EXPECTED
    oss << "std::expected is available.\n";

    // Helper function
    auto operation = [](bool succeed) -> std::expected<int, std::string> {
        if (succeed) {
            return 42; // Success
        } else {
            return std::unexpected("Simulated error"); // Failure
        }
    };

    // Demonstrate success
    auto success_result = operation(true);
    if (success_result.has_value()) {
        oss << "Successful operation returned: " << success_result.value() << "\n";
    } else {
        oss << "Successful operation failed unexpectedly: " << success_result.error() << "\n";
    }

    // Demonstrate failure
    auto failure_result = operation(false);
    if (!failure_result.has_value()) {
        oss << "Failed operation returned error: " << failure_result.error() << "\n";
    } else {
        oss << "Failed operation succeeded unexpectedly: " << failure_result.value() << "\n";
    }

#else
    oss << "std::expected is not available.\n";
#endif
    return oss.str();
}

} // namespace cpp26 