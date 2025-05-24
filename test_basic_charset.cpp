#include <iostream>
#include <string>

int main() {
    // P2558R2 adds @, $, and ` to the basic character set.
    // This means they can be used directly in string and character literals
    // without relying on extended character sets or UCNs.

    char c1 = '@';
    char c2 = '$';
    char c3 = '`';

    std::string s = "Hello @ World $ Test ` Backtick";

    std::cout << "c1: " << c1 << std::endl;
    std::cout << "c2: " << c2 << std::endl;
    std::cout << "c3: " << c3 << std::endl;
    std::cout << "s: " << s << std::endl;

    // The real test is that the compiler doesn't complain about these
    // characters appearing directly in the source, assuming the source file
    // encoding itself (e.g., UTF-8) supports them.
    // The "basic character set" means the compiler *must* support them
    // at a fundamental level.

    // Using them in identifiers is a related but distinct topic (P1759R6).
    // P2558R2 is about their presence in general source text, especially literals.
    // int my`var = 5; // This would be for identifier usage, likely not allowed by P2558R2 alone.

    std::cout << "Test for P2558R2 (extended basic character set) successful if compiled without warnings/errors related to these characters." << std::endl;

    return 0;
}
