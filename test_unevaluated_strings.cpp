#include <string_view>

// Example from P2361R6 (modified slightly for a standalone test)
template<std::string_view V>
struct S {
    static constexpr auto value = V;
};

// This would ideally use an unevaluated string if the feature is fully implemented
// for template arguments. P2361R6 mentions this as a motivation.
// However, direct support as NTTP might require P2468R2 as well.

// For now, let's test the basic syntax if it's recognized by the lexer/parser
// even if full semantic integration isn't there.
// The proposal mentions syntax like: static_assert(true, ue"message");

int main() {
    // The core idea is that ue"..." might not allocate storage or pass through
    // normal string literal processing if its value isn't needed at runtime.
    // A direct test of "unevaluated-ness" is hard.
    // Let's check if the syntax is accepted.

    // P2361R6 proposes `ue"..."` and `UE"..."` (for wide)
    // The proposal doesn't make them directly assignable to char* in the examples,
    // but rather used in contexts like static_assert or as input to other mechanisms.

    // Let's try it in a context where a string literal is normally used,
    // and see if 'ue' prefix is accepted or causes an error.
    // If it's truly "unevaluated", its type might be different or it might only be
    // usable in specific contexts.

    // The paper says: "An unevaluated string literal is a core language construct
    // that behaves like a string literal, except that it is not evaluated."
    // And "The type of an unevaluated string literal is const char[N] (const wchar_t[N]
    // for a wide unevaluated string literal), where N is the number of characters
    // in the string including the null terminator."

    // This implies it *should* be usable like a normal string literal in many cases,
    // but the compiler might optimize it differently.

    const char* str = ue"hello"; // Test basic assignment

    if (str[0] == 'h') {
        // This doesn't prove it's unevaluated, but tests if the syntax is accepted
        // and produces a somewhat expected result.
    }

    // A better test might be in a static_assert message.
    static_assert(true, ue"This is an unevaluated string message for static_assert.");

    return 0;
}
