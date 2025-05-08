#include "cpp26_features.h"
#include <iostream>
#include <sstream>

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
    char buffer[256] = {};
    std::span my_span(buffer);
    
    // Write to the span
    std::ospanstream oss(my_span);
    oss << "Spanstream demo: " << data;
    
    return std::string(buffer);
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

} // namespace cpp26 