# C++26 Feature Demonstration (GCC 13.3.0)

## 1. Introduction

This document demonstrates a selection of C++26 language features that were successfully compiled using GCC 13.3.0 with the `-std=c++2b` flag.

C++26 is an upcoming standard, and compiler support for its features is currently experimental. The information presented here reflects the state of GCC 13.3.0 and is subject to change as the standard evolves and compiler implementations mature.

## 2. Environment

*   **Compiler:** GCC 13.3.0
*   **Flags:** `-std=c++2b`

## 3. Supported C++26 Features (in GCC 13.3.0 with `-std=c++2b`)

Below are features that demonstrated compatibility or expected behavior with GCC 13.3.0. For Defect Reports (DRs), the "feature" is often a clarification leading to consistent compiler behavior.

---

### DR98: Removing undefined behavior from lexing (P2621R3)

This defect report clarifies rules for lexing, aiming to remove undefined behavior in certain scenarios, such as with Universal Character Names (UCNs). The following code demonstrates correct interpretation of a UCN.

```cpp
#include <iostream>

int main() {
    // P2621R3 aims to ensure UCNs like this are handled consistently.
    const char* s = "\u002B"; // UCN for '+'
    if (s[0] == '+') {
        std::cout << "P2621R3 (Lexing DR): UCN for '+' correctly interpreted." << std::endl;
    } else {
        std::cout << "P2621R3 (Lexing DR): UCN for '+' NOT correctly interpreted." << std::endl;
    }
    return 0;
}

```

**Compilation Command:**

```bash
g++ -std=c++2b -o test_p2621r3 test_p2621r3.cpp && ./test_p2621r3
```

---

### DR98: Making non-encodable string literals ill-formed (P1854R4)

This defect report resolution makes it ill-formed if a string literal cannot be represented in the execution character set. The test involves trying to compile a string with a character ('é', common in UTF-8 source) for an execution character set (ASCII) where it's not representable.

```cpp
#include <iostream>

int main() {
    // Source file is assumed to be UTF-8 encoded.
    // The character 'é' (U+00E9) is not representable in ASCII.
    // According to P1854R4, this program should be ill-formed
    // if compiled with an execution character set of ASCII.
    const char* s = "é"; 
    
    // The following line is more for context; compilation should fail.
    std::cout << "P1854R4 (Non-encodable strings DR): Content: " << s << std::endl;
    std::cout << "Compilation should fail with -fexec-charset=ASCII." << std::endl;
    return 0;
}

```

**Compilation Command (expected to fail):**

```bash
g++ -std=c++2b -fexec-charset=ASCII -o test_p1854r4 test_p1854r4.cpp
```
*(Note: The command `&& ./test_p1854r4` is omitted as compilation failure is the expected outcome demonstrating support for the DR.)*

---

### Adding @, $, and \` to the basic character set (P2558R2)

This proposal adds the characters `@`, `$`, and ``` ` ``` to the C++ basic character set, allowing them to be used directly in source files (e.g., in string and character literals) without needing UCNs, assuming the source file encoding supports them.

```cpp
#include <iostream>
#include <string>

int main() {
    char c1 = '@';
    char c2 = '$';
    char c3 = '`';
    std::string s = "Hello @ World $ Test ` Backtick";

    std::cout << "P2558R2 (Extended Basic Charset):" << std::endl;
    std::cout << "Characters: " << c1 << ", " << c2 << ", " << c3 << std::endl;
    std::cout << "String: " << s << std::endl;
    return 0;
}

```

**Compilation Command:**

```bash
g++ -std=c++2b -o test_p2558r2 test_p2558r2.cpp && ./test_p2558r2
```

---

### DR20: On the ignorability of standard attributes (P2552R3)

This defect report clarifies that implementations should ignore unknown attributes in an attribute-list if the attribute-specifier-seq appertains to an entity and has a `std::` prefix (or any standard prefix). This test uses a hypothetical unknown `std::` attribute.

```cpp
#include <iostream>

// P2552R3 aims to ensure compilers ignore unknown standard attributes
// (often with a warning) rather than erroring out.
struct [[std::hypothetical_future_standard_attribute_for_struct(123)]] TestStruct_P2552R3 {
    int x;
};

[[std::another_unknown_one_for_P2552R3]] void test_func_P2552R3() {
    // Function to test attribute application
}

int main() {
    TestStruct_P2552R3 t;
    t.x = 10; 
    test_func_P2552R3(); 
    std::cout << "P2552R3 (Attribute Ignorability DR): Compiled." << std::endl;
    std::cout << "Check compiler output for warnings about unknown 'std::' attributes being ignored." << std::endl;
    return 0;
}

```

**Compilation Command:**

```bash
g++ -std=c++2b -o test_p2552r3 test_p2552r3.cpp && ./test_p2552r3
```
*(Note: Warnings for ignored unknown `std::` attributes are expected.)*

---

### DR11: Static storage for braced initializers (P2752R3)

This defect report clarifies that temporaries created by braced-init-lists for non-class types, when used to initialize an entity with static storage duration, also have static storage duration. This ensures the lifetime and initialization order are well-defined.

```cpp
#include <iostream>

// P2752R3: Static storage for braced initializers (compound literals).
// The temporary int {123} initializing this static reference
// should have static storage duration.
static const int& static_int_ref_p2752r3 = (const int&){123};

// Similarly, the temporary array {1,2,3} for this static pointer.
static const int* static_arr_ptr_p2752r3 = (const int[]){1, 2, 3};

int main() {
    bool ok = true;
    if (static_int_ref_p2752r3 != 123) ok = false;
    if (!static_arr_ptr_p2752r3 || static_arr_ptr_p2752r3[1] != 2) ok = false;
    
    if (ok) {
        std::cout << "P2752R3 (Static Braced Init DR): Behavior consistent." << std::endl;
    } else {
        std::cout << "P2752R3 (Static Braced Init DR): Unexpected behavior." << std::endl;
    }
    return !ok;
}

```

**Compilation Command:**

```bash
g++ -std=c++2b -o test_p2752r3 test_p2752r3.cpp && ./test_p2752r3
```

---

### DR11/20: Template parameter initialization (P2308R1)

This defect report clarifies rules for initializing template parameters, including non-type template parameters (NTTPs) with `auto`, from various initializers like lambdas or immediately-invoked lambda expressions (IILEs).

```cpp
#include <iostream>

// P2308R1: Template parameter initialization clarifications.
template<auto N = []{ return 42; }> // Lambda as default for NTTP
int function_with_lambda_default_p2308r1() {
    return N(); // N is the lambda, call it.
}

template<auto M = ([]{ return 1; }())> // IILE as default for NTTP
int function_with_iife_default_p2308r1() {
    return M; // M is the result of the IILE.
}

int main() {
    bool ok = true;
    if (function_with_lambda_default_p2308r1() != 42) ok = false;
    if (function_with_iife_default_p2308r1() != 1) ok = false;

    if (ok) {
        std::cout << "P2308R1 (Template Param Init DR): Behavior consistent." << std::endl;
    } else {
        std::cout << "P2308R1 (Template Param Init DR): Unexpected behavior." << std::endl;
    }
    return !ok;
}

```

**Compilation Command:**

```bash
g++ -std=c++2b -o test_p2308r1 test_p2308r1.cpp && ./test_p2308r1
```

---

## 4. Features Investigated But Not Supported (or Not Clearly Supported) in GCC 13.3.0 with `-std=c++2b`

The following C++26 core language features were also tested but found not to be supported, or their support was ambiguous, in GCC 13.3.0 with the `-std=c++2b` flag:

*   **Unevaluated strings (P2361R6):** Not supported (compilation error: `‘ue’ was not declared`).
*   **`constexpr` cast from `void*` (P2738R1):** Not supported (compilation error: `reinterpret_cast` not a constant expression).
*   **User-generated `static_assert` messages (P2741R3):** Not supported (compilation error: expects string-literal for `static_assert` message).
*   **Placeholder variables with no name (P2169R4):** Not supported (compilation error: `conflicting declaration ‘auto _’` when `_` used multiple times in structured binding).
*   **Pack indexing (P2662R3):** Not supported (compilation error: `parameter packs not expanded with ‘...’` for `args...[i]` syntax).
*   **Removing deprecated arithmetic conversion on enumerations (P2864R2):** Not supported (change not yet active; deprecated implicit conversions from unscoped enums to integers still allowed without error/warning by default).
*   **Disallow binding a returned reference to a temporary (P2748R5):** Not supported (problematic code involving range-for over a reference to a temporary's member compiled and exhibited undefined behavior, instead of a compile error as P2748R5 intends).
*   **Attributes for structured bindings (P0609R3):** Not supported (compilation errors when attempting to place attributes on individual decomposition names in structured bindings).
*   **Erroneous behavior for uninitialized reads, `[[indeterminate]]` (P2795R5):** Not supported for the `[[indeterminate]]` attribute (attribute directive ignored with a warning; uninitialized use warnings persist for variables marked with it). The deeper semantic changes are harder to verify with simple compile tests.
*   **`= delete("reason");` (P2573R2):** Not supported (compiler rejects the syntax `= delete("reason_string");`, expecting `= delete;`).

## 5. Disclaimer

C++26 is an actively developed standard. The features and their support status listed in this document are based on experimental support observed in **GCC 13.3.0 with the `-std=c++2b` flag** and are subject to change. Later versions of GCC or other compilers may have different levels of support.

For the most accurate and up-to-date information, please consult official C++ standard documentation (once C++26 is published) and the manuals for your specific compiler version.
