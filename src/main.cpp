#include "cpp26_features.h"
#include <iostream>

int main() {
    // Print header
    std::cout << "===================================\n";
    std::cout << "C++26 Modern Template Demonstration\n";
    std::cout << "===================================\n\n";

    // Get and display the feature report
    const auto report = cpp26::Features::getFeatureReport();
    std::cout << report << "\n\n";

    // Demonstrate std::print if available
    std::cout << "Demonstrating print functionality:\n";
    cpp26::Features::demonstratePrint("The answer is", 42);
    std::cout << "\n";

    // Demonstrate spanstream if available
    std::cout << "Demonstrating spanstream functionality:\n";
    const auto result = cpp26::Features::demonstrateSpanstream("C++26 is awesome");
    std::cout << result << "\n\n";

    // Demonstrate std::expected if available
    std::cout << "Demonstrating std::expected functionality:\n";
    const auto expected_result = cpp26::Features::demonstrateExpected();
    std::cout << expected_result << "\n\n";

    // Success message
    std::cout << "===================================\n";
    std::cout << "Demo completed successfully!\n";
    std::cout << "===================================\n";

    return 0;
} 