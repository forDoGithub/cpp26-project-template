#pragma once

#include <string>
#include <vector>

// C++26 feature detection
#if __has_include(<print>)
#include <print>
#define HAS_PRINT 1
#else
#define HAS_PRINT 0
#endif

#if __has_include(<spanstream>)
#include <spanstream>
#define HAS_SPANSTREAM 1
#else
#define HAS_SPANSTREAM 0
#endif

#if __has_include(<expected>)
#include <expected>
#define HAS_EXPECTED 1
#else
#define HAS_EXPECTED 0
#endif

namespace cpp26 {

/**
 * @brief A class demonstrating C++26 features
 */
class Features {
public:
    /**
     * @brief Get a report of available C++26 features
     * @return A string containing the feature report
     */
    static std::string getFeatureReport();

    /**
     * @brief Get compiler version information
     * @return A string containing compiler info
     */
    static std::string getCompilerInfo();

    /**
     * @brief Demonstrate the use of std::print if available
     * @param text The text to print
     * @param value A value to format
     */
    static void demonstratePrint(const std::string& text, int value);

    /**
     * @brief Demonstrate the use of std::spanstream if available
     * @param data The data to write to a span
     * @return The resulting string from the spanstream operation
     */
    static std::string demonstrateSpanstream(const std::string& data);

    /**
     * @brief Get all detected C++26 features
     * @return A vector of feature names
     */
    static std::vector<std::string> getDetectedFeatures();
};

} // namespace cpp26 