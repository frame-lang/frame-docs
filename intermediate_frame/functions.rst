==================
Functions
==================

Frame v0.30 supports multiple functions per module that can work alongside system specifications. Functions are optional and, when present, provide entry points and utility functionality.

.. note:: Frame v0.30 supports multiple functions with any names per module. Functions can interact with systems through interface methods and operations (which are public), while actions remain private implementation details within systems.

Basic Function Syntax
======================

.. code-block:: frame
    :caption: Basic Main Function

    fn main() {
        print("Hello, Frame!")
    }

.. code-block:: frame
    :caption: Main Function with Return Type

    fn main(): int {
        return 0
    }

Multiple Functions and Systems  
===============================

Frame v0.30 supports multiple functions within a module alongside systems. Functions can call system interface methods and operations (which are public), but cannot directly access actions (which are private implementation details).

**Function-System Interaction Rules:**
- **Operations**: Functions call operations using `SystemName.operationName()` syntax (static method calls)
- **Interface Methods**: Functions call interface methods using `systemInstance.methodName()` syntax (instance method calls)  
- **Actions**: Functions cannot call actions (actions are private implementation details within systems)

.. code-block:: frame
    :caption: Functions Calling System Operations (Static Methods)

    fn main() {
        var result = Utils.add(5, 3)
        print("5 + 3 = " + str(result))
        
        var category = Utils.categorizeNumber(42)
        print("42 is " + category)
    }

    system Utils {
        operations:
            add(x: int, y: int): int {
                return x + y
            }

            categorizeNumber(num: int): string {
                if num < 0 {
                    return "negative"
                } elif num == 0 {
                    return "zero"
                } elif num < 10 {
                    return "single digit"
                } elif num < 100 {
                    return "double digit"
                } else {
                    return "large number"
                }
            }
    }

.. code-block:: frame
    :caption: Functions Calling System Interface Methods (Instance Methods)

    fn main() {
        var counter = Counter()
        
        // Call interface methods on system instance
        counter.increment()
        counter.increment()
        counter.increment()
        
        print("Final count: " + str(counter.getCount()))
    }

    system Counter {
        interface:
            increment()
            getCount(): int

        machine:
            $Start {
                increment() {
                    count = count + 1
                }
                
                getCount(): int {
                    return count
                }
            }

        domain:
            var count: int = 0
    }

Return Statements in Action Methods
====================================

Action methods support conventional `return` statements with both simple values and complex expressions. This is a major improvement in Frame v0.20, enabling conventional control flow patterns.

.. code-block:: frame
    :caption: Operations with Return Values

    fn main() {
        var result = MathUtils.add(5, 3)
        print("5 + 3 = " + str(result))
        
        var fact = MathUtils.factorial(5)
        print("5! = " + str(fact))
    }

    system MathUtils {
        operations:
            add(x: int, y: int): int {
                return x + y
            }

            factorial(n: int): int {
                if n <= 1 {
                    return 1
                } else {
                    return n * MathUtils.factorial(n - 1)
                }
            }
    }

Control Flow with Return Statements
===================================

Frame v0.20 action methods support conventional control flow patterns with if/elif/else chains and return statements. This enables clean, readable logic similar to traditional programming languages.

.. code-block:: frame
    :caption: Operations with Conditional Logic

    fn main() {
        var category1 = NumberClassifier.categorize(-5)
        print("-5 is " + category1)
        
        var category2 = NumberClassifier.categorize(42)
        print("42 is " + category2)
    }

    system NumberClassifier {
        operations:
            categorize(num: int): string {
                if num < 0 {
                    return "negative"
                } elif num == 0 {
                    return "zero"
                } elif num < 10 {
                    return "single digit"
                } elif num < 100 {
                    return "double digit"
                } else {
                    return "large number"
                }
            }
    }

Main Function with System Integration
=====================================

Frame v0.20 allows a main function to interact with systems, enabling hybrid programming approaches where the main function serves as the entry point and systems provide structured functionality.

.. code-block:: frame
    :caption: Main Function with System Integration

    fn main() {
        var counter = Counter()
        
        // Demonstrate system interaction with manual loop
        counter.increment()
        counter.increment()
        counter.increment()
        
        print("Final count: " + counter.getCount())
    }

    system Counter {
        interface:
            increment()
            getCount(): int

        machine:
            $Start {
                increment() {
                    count = count + 1
                }
                
                getCount(): int {
                    return count
                }
            }

        domain:
            var count: int = 0
    }

Event Handlers with Return Statements
=====================================

One of the major improvements in Frame v0.20 is support for return statements within event handlers, enabling conventional conditional logic patterns.

.. code-block:: frame
    :caption: Event Handler with Complex Return Logic

    fn main() {
        var grader = GradeProcessor()
        var grade = grader.processScore(85)
        print("Grade: " + grade)
    }

    system GradeProcessor {
        interface:
            processScore(score: int): string

        machine:
            $Start {
                processScore(score: int): string {
                    // Validate input
                    if score < 0 {
                        return "Invalid"
                    } elif score > 100 {
                        return "Invalid"
                    }
                    
                    // Calculate letter grade
                    if score >= 90 {
                        return "A"
                    } elif score >= 80 {
                        return "B"
                    } elif score >= 70 {
                        return "C"
                    } elif score >= 60 {
                        return "D"
                    } else {
                        return "F"
                    }
                }
            }
    }

Best Practices for Frame v0.20
=============================

1. **Clear Method Names**: Use descriptive names for action methods and event handlers
2. **Type Annotations**: Always specify parameter and return types for clarity
3. **Early Returns**: Use return statements to simplify control flow in action methods and event handlers
4. **Single Responsibility**: Keep methods focused on one task
5. **Error Handling**: Use conditional returns for error cases
6. **System Organization**: Use systems to group related functionality

.. code-block:: frame
    :caption: Best Practices Example

    fn main() {
        var discount = DiscountCalculator.calculate(100.0, "premium")
        print("Discount amount: $" + str(discount))
    }

    system DiscountCalculator {
        operations:
            calculate(price: float, customerType: string): float {
                // Validate input
                if price <= 0 {
                    return 0.0
                }
                
                // Calculate discount based on customer type
                if customerType == "premium" {
                    return price * 0.2  // 20% discount
                } elif customerType == "regular" {
                    return price * 0.1  // 10% discount
                } elif customerType == "new" {
                    return price * 0.05 // 5% discount
                } else {
                    return 0.0  // No discount for unknown types
                }
            }
    }

Key Features Enabled in v0.20
=============================

The return statement fix in Frame v0.20 enables several important patterns:

- **Conventional Conditionals**: if/elif/else chains with return statements work in both action methods and event handlers
- **Early Returns**: Validation and error handling using early return patterns
- **Complex Logic**: Multi-level conditional logic with clear control flow
- **Readable Code**: Generated code follows conventional programming patterns

This represents a significant improvement over previous Frame versions and enables more conventional programming approaches while maintaining Frame's unique state machine capabilities.

