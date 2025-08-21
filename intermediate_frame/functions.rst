==================
Functions
==================

Frame v0.20 supports a main function that can work alongside system specifications. The main function is optional and, when present, provides the entry point for program execution.

.. note:: Frame v0.20 currently supports one main function per module. Additional functionality can be implemented as action methods within systems, which support full v0.20 syntax including conventional if/elif/else patterns with return statements.

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

Action Methods as Function-Like Behavior
=========================================

While Frame v0.20 currently supports only a main function, you can achieve function-like behavior using action methods within systems. These support full v0.20 syntax including return statements and conditional logic.

.. code-block:: frame
    :caption: Action Methods with Function-Like Behavior

    fn main() {
        var utils = Utils()
        var result = utils.add(5, 3)
        print("5 + 3 = " + str(result))
        
        var category = utils.categorizeNumber(42)
        print("42 is " + category)
    }

    system Utils {
        actions:
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

Return Statements in Action Methods
====================================

Action methods support conventional `return` statements with both simple values and complex expressions. This is a major improvement in Frame v0.20, enabling conventional control flow patterns.

.. code-block:: frame
    :caption: Action Methods with Return Values

    fn main() {
        var math = MathUtils()
        var result = math.add(5, 3)
        print("5 + 3 = " + str(result))
        
        var fact = math.factorial(5)
        print("5! = " + str(fact))
    }

    system MathUtils {
        actions:
            add(x: int, y: int): int {
                return x + y
            }

            factorial(n: int): int {
                if n <= 1 {
                    return 1
                } else {
                    return n * factorial(n - 1)
                }
            }
    }

Control Flow with Return Statements
===================================

Frame v0.20 action methods support conventional control flow patterns with if/elif/else chains and return statements. This enables clean, readable logic similar to traditional programming languages.

.. code-block:: frame
    :caption: Action Method with Conditional Logic

    fn main() {
        var classifier = NumberClassifier()
        var numbers = [-5, 0, 7, 42, 123]
        
        // Note: Manual array iteration in current Frame v0.20
        var category1 = classifier.categorize(-5)
        print("-5 is " + category1)
        
        var category2 = classifier.categorize(42)
        print("42 is " + category2)
    }

    system NumberClassifier {
        actions:
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
        var calculator = DiscountCalculator()
        var discount = calculator.calculate(100.0, "premium")
        print("Discount amount: $" + str(discount))
    }

    system DiscountCalculator {
        actions:
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

