#include <iostream>

// P2308R1: Template parameter initialization
// This DR clarifies rules for initializing template parameters.

// Example 1: Lambda as default argument for a template auto parameter
template<auto N = []{ return 42; }>
int function_with_lambda_default() {
    return N(); // N is the lambda, call it.
}

// Example 2: Immediately-invoked lambda as default argument
template<auto M = ([]{ return 1; }())>
int function_with_iife_default() {
    return M; // M is the result of the IIFE.
}

// Example 3: From paper - default member initializer for a template parameter
template<typename T, T Value = T{42}>
struct S {
    T data = Value;
};


// Example 4: Another one from the paper (more complex)
// template<auto x = delete, decltype(x) y = x> struct X; // Ill-formed: x is not a constant
// This tests interaction with 'delete' and how decltype works in this context.
// This is more about ensuring ill-formed code is correctly diagnosed.

// Example 5: Dependent default argument
template<typename T> struct Identity { using type = T; };
template<typename T, typename U = typename Identity<T>::type>
struct DepDefault {
    T t_val;
    U u_val;
    DepDefault(T t, U u) : t_val(t), u_val(u) {}
};


int main() {
    int res1 = function_with_lambda_default();
    std::cout << "function_with_lambda_default(): " << res1 << std::endl;

    int res2 = function_with_iife_default();
    std::cout << "function_with_iife_default(): " << res2 << std::endl;

    S<int> s_int; // Uses default Value = 42
    std::cout << "S<int>().data: " << s_int.data << std::endl;

    S<long, 100L> s_long; // Explicit value
    std::cout << "S<long, 100L>().data: " << s_long.data << std::endl;
    
    // S<double, 3.14> s_double; // T{42} would be int{42} -> 42.0 if T is double.
    // std::cout << "S<double>().data (default init with T{42}): " << s_double.data << std::endl;

    DepDefault<float, float> dd_float(1.2f, 3.4f);
    std::cout << "DepDefault<float, float>: " << dd_float.t_val << ", " << dd_float.u_val << std::endl;
    
    // This uses the default for U
    DepDefault<double, double> dd_double_default_u(5.6, 0.0); // Need to provide U if it can't be deduced or defaulted from T simply
    // The default U = typename Identity<T>::type makes U same as T.
    DepDefault<char> dd_char_default_u('A', 'B'); // T='char', U defaults to 'char'
    dd_char_default_u.u_val = dd_char_default_u.t_val; // To make it more interesting
    std::cout << "DepDefault<char> (U defaults to char): " << dd_char_default_u.t_val << ", " << dd_char_default_u.u_val << std::endl;


    std::cout << "P2308R1 (Template parameter initialization) test." << std::endl;
    std::cout << "If compiles and runs, implies DR clarifications are consistent with compiler behavior." << std::endl;

    return 0;
}
