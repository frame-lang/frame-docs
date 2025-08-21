==================
Conditionals
==================

Frame v0.20 introduces conventional conditional statements with support for both Python-style and braced syntax.
This provides developers with familiar control flow patterns while maintaining Frame's unique capabilities.

Basic If Statements
-------------------

Frame supports standard ``if`` statements for conditional execution:

.. code-block:: frame
    :caption: Basic If Statement

    fn checkTemperature(temp: int) {
        if temp > 100 {
            print("Warning: Temperature too high!")
            shutdownSystem()
        }
    }

Python-style Single Statements
-------------------------------

For single statements, Frame supports Python-style syntax with colons:

.. code-block:: frame
    :caption: Python-style If Statement

    fn processValue(x: int) {
        if x > 0:
            print("Positive")
    }

If-Elif-Else Chains
-------------------

Frame provides full support for ``elif`` and ``else`` clauses:

.. code-block:: frame
    :caption: Complete If-Elif-Else Chain

    fn calculateGrade(score: int): string {
        var grade: string = ""
        
        if score >= 90 {
            grade = "A"
            print("Excellent!")
        } elif score >= 80 {
            grade = "B"
            print("Good job!")
        } elif score >= 70 {
            grade = "C"
            print("Satisfactory")
        } elif score >= 60 {
            grade = "D"
            print("Needs improvement")
        } else {
            grade = "F"
            print("Failed")
        }
        
        return grade
    }

Mixed Syntax Styles
-------------------

Frame allows mixing Python-style and braced syntax within the same conditional chain:

.. code-block:: frame
    :caption: Mixed Syntax Example

    fn processRequest(status: int, priority: bool) {
        if status == 0:
            logQuick("Pending")
        elif status == 1 && priority {
            logDetailed("High priority processing")
            expediteRequest()
            notifyManagement()
        } elif status == 1:
            logQuick("Normal processing")
        else {
            logError("Unknown status")
            createTicket()
        }
    }

Nested Conditionals
-------------------

Conditionals can be nested to arbitrary depths:

.. code-block:: frame
    :caption: Nested Conditionals

    fn validateAndProcess(user: string, data: int) {
        if user != "" {
            if data > 0 {
                if data < 1000 {
                    process(data)
                } else {
                    print("Data exceeds limit")
                }
            } else {
                print("Invalid data value")
            }
        } else {
            print("User required")
        }
    }

Conditionals in State Machines
-------------------------------

Conditionals work seamlessly within Frame's state machine event handlers:

.. code-block:: frame
    :caption: Conditionals in Event Handlers

    system Controller {
        interface:
            processInput(value: int)
            
        machine:
            $Idle {
                processInput(value: int) {
                    if value < 0 {
                        print("Invalid input")
                        return
                    } elif value == 0 {
                        print("Resetting")
                        -> $Idle
                        return
                    } else {
                        print("Processing: " + str(value))
                        -> $Active
                        return
                    }
                }
            }
            
            $Active {
                processInput(value: int) {
                    if value == 999:
                        -> $Idle
                    else:
                        print("Active processing: " + str(value))
                    return
                }
            }
    }

Boolean Expressions
-------------------

Conditionals support all standard boolean operators:

.. code-block:: frame
    :caption: Boolean Expressions

    fn checkConditions(x: int, y: int, enabled: bool) {
        // Comparison operators
        if x == y:
            print("Equal")
        
        if x != y:
            print("Not equal")
            
        if x < y && y <= 100:
            print("In range")
            
        // Logical operators
        if enabled && (x > 0 || y > 0):
            print("Enabled with positive value")
            
        if !enabled:
            print("Disabled")
    }

Conditionals with Returns
-------------------------

Conditionals can contain return statements for early exit:

.. code-block:: frame
    :caption: Early Returns

    fn findFirstPositive(a: int, b: int, c: int): int {
        if a > 0:
            return a
        elif b > 0:
            return b
        elif c > 0:
            return c
        else:
            return -1
    }

Actions Block Example
---------------------

Conditionals in action methods follow the same rules:

.. code-block:: frame
    :caption: Conditionals in Actions

    system DataProcessor {
        actions:
            validateData(value: int): bool {
                if value < 0 {
                    logError("Negative value")
                    return false
                } elif value > 1000 {
                    logError("Value too large")
                    return false
                } else {
                    return true
                }
            }
            
            processData(value: int) {
                if validateData(value) {
                    // Multi-line processing
                    transform(value)
                    store(value)
                    notify()
                } else:
                    handleError()
            }
    }

Common Patterns
---------------

Guard Clauses
+++++++++++++

Use early returns to simplify logic:

.. code-block:: frame
    :caption: Guard Clause Pattern

    fn processUser(user: string, age: int): bool {
        // Guard clauses first
        if user == "":
            return false
            
        if age < 0:
            return false
            
        if age > 150:
            return false
            
        // Main logic
        processValidUser(user, age)
        return true
    }

State-Based Logic
+++++++++++++++++

Conditionals for state-dependent behavior:

.. code-block:: frame
    :caption: State-Based Conditionals

    system Device {
        actions:
            checkStatus() {
                if !isOn:
                    return
                    
                if temperature < 20 {
                    setMode("heating")
                } elif temperature > 25 {
                    setMode("cooling")
                } else {
                    setMode("idle")
                }
            }
            
        domain:
            var temperature = 0
            var isOn = false
    }

Syntax Rules
------------

1. **Python-style**: After ``:`` only single statements are allowed
2. **Braced blocks**: Required for multiple statements
3. **No mixed blocks**: Cannot use ``{ }`` after ``:``
4. **Parentheses optional**: Conditions don't require parentheses

Valid Syntax
++++++++++++

.. code-block:: frame
    :caption: Valid Conditional Syntax

    // Python-style single statements
    if x > 0: doSomething()
    elif x < 0: doOther()
    else: doDefault()
    
    // Braced blocks
    if x > 0 {
        doSomething()
        doMore()
    }
    
    // Mixed styles
    if simple: quick()
    elif complex {
        first()
        second()
    }

Invalid Syntax
++++++++++++++

.. code-block:: frame
    :caption: Invalid Conditional Syntax

    // ERROR: Block after colon
    if x > 0: {
        doSomething()
    }
    
    // ERROR: Multiple statements after colon
    if x > 0: first() second()
    
    // ERROR: Missing braces for multiple statements
    if x > 0
        first()
        second()

Summary
-------

Frame v0.20's conditional statements provide:

- Familiar ``if/elif/else`` keywords
- Python-style single-line syntax
- Braced blocks for multiple statements
- Full boolean expression support
- Seamless integration with state machines
- Consistent behavior across all Frame contexts

The syntax is designed to be intuitive for developers coming from mainstream languages while maintaining Frame's unique state machine capabilities.