#include <iostream>

int main() {
    // This string contains a character 'é' (U+00E9).
    // If the execution character set is set to ASCII, this character
    // cannot be represented and the program should be ill-formed
    // according to P1854R4.
    const char* s = "é";

    std::cout << "Content: " << s << std::endl;
    std::cout << "Test for P1854R4 (non-encodable string literals)." << std::endl;
    std::cout << "If compiled with an execution charset that cannot represent 'é'," << std::endl;
    std::cout << "this program should fail to compile." << std::endl;
    return 0;
}
