#include <iostream>

int main() {
    // This UCN might have been problematic in some older lexers
    // if not handled correctly, especially if it mapped to a character
    // that could alter the tokenization.
    // P2621R3 aims to clarify and make such cases well-defined.
    const char* s = "\u002B"; // UCN for '+'
    if (s[0] == '+') {
        std::cout << "Lexing test: UCN for + correctly interpreted." << std::endl;
    } else {
        std::cout << "Lexing test: UCN for + NOT correctly interpreted." << std::endl;
    }
    return 0;
}
