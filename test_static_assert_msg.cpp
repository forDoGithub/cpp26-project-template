#include <string>
#include <string_view>

// P2741R3: User-generated static_assert messages

consteval std::string generate_error_message_string() {
    return "This is a compile-time generated error message from std::string.";
}

consteval std::string_view generate_error_message_string_view() {
    return "This is a compile-time generated error message from std::string_view.";
}

struct MyType {
    int val;
};

consteval std::string check_my_type(MyType mt) {
    if (mt.val > 10) {
        return ""; // Empty means success / no message
    }
    return "MyType::val must be > 10";
}

int main() {
    // Test 1: static_assert(false, ...) to see the message
    // static_assert(false, generate_error_message_string()); 
    // static_assert(false, generate_error_message_string_view());

    // Test 2: A condition that is true, should not trigger message generation (or evaluate if not needed)
    static_assert(true, generate_error_message_string());

    // Test 3: Using it with a condition
    constexpr MyType m_ok = {20};
    constexpr MyType m_fail = {5};

    // This one should pass silently
    static_assert(check_my_type(m_ok).empty(), check_my_type(m_ok).data());
    
    // This one should fail and show the message from check_my_type(m_fail)
    // static_assert(check_my_type(m_fail).empty(), check_my_type(m_fail).data());
    // However, the .data() part is tricky, as the string from check_my_type might be a temporary.
    // The proposal is that the consteval function *itself* is the second argument.

    // Correct usage according to P2741R3:
    // static_assert(false, generate_error_message_string); // Pass the function itself
    // static_assert(false, generate_error_message_string_view);

    // static_assert(check_my_type(m_fail).empty(), check_my_type(m_fail)); // This is not quite right
    // The intent is: static_assert(condition, consteval_message_generator_func);

    // Let's try the direct examples from the paper if the above is problematic.
    // The paper suggests:
    // static_assert(cond, f(args...)); where f is consteval returning string/string_view
    
    // So this should be the way:
    // static_assert(m_fail.val > 10, check_my_type(m_fail));
    
    // To actually see the message, we need a failing static_assert.
    // We will enable one of the failing assertions to check the output.
    // For now, let's just check if it compiles with a succeeding one.
    static_assert(m_ok.val > 10, check_my_type(m_ok));

    return 0;
}
