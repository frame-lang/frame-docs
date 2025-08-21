==================
Loops
==================

Frame v0.20 provides modern loop constructs with familiar ``for`` and ``while`` keywords, supporting both Python-style and braced syntax.

While Loops
-----------

While loops execute a block of code as long as a condition remains true:

Basic While Loop
++++++++++++++++

.. code-block:: frame
    :caption: Basic While Loop

    fn countdown() {
        var count = 10
        
        while count > 0 {
            print(count)
            count = count - 1
        }
        
        print("Liftoff!")
    }

Python-style While
++++++++++++++++++

For single statements, use Python-style syntax with a colon:

.. code-block:: frame
    :caption: Python-style While Loop

    fn waitForReady(timeout: int) {
        var elapsed = 0
        
        while !isReady() && elapsed < timeout:
            elapsed = elapsed + 1
            
        if elapsed == timeout:
            print("Timeout reached")
    }

For Loops
---------

For loops iterate over collections or ranges:

For-In Loop
+++++++++++

.. code-block:: frame
    :caption: For-In Loop

    fn processItems(items: list) {
        for item in items {
            validate(item)
            process(item)
            log(item)
        }
    }

Python-style For
++++++++++++++++

.. code-block:: frame
    :caption: Python-style For Loop

    fn printNames(names: list) {
        for name in names:
            print("Hello, " + name)
    }

With Variable Declaration
+++++++++++++++++++++++++

.. code-block:: frame
    :caption: For Loop with Variable Declaration

    fn sumValues(values: list): int {
        var total = 0
        
        for var value in values {
            total = total + value
        }
        
        return total
    }

Loop Control Statements
-----------------------

Break Statement
+++++++++++++++

The ``break`` statement exits the loop immediately:

.. code-block:: frame
    :caption: Break Statement

    fn findFirst(items: list, target: string): int {
        var index = 0
        
        for item in items {
            if item == target {
                break
            }
            index = index + 1
        }
        
        return index
    }

Continue Statement
++++++++++++++++++

The ``continue`` statement skips to the next iteration:

.. code-block:: frame
    :caption: Continue Statement

    fn processPositive(numbers: list) {
        for num in numbers {
            if num <= 0 {
                continue
            }
            
            // Process only positive numbers
            result = calculate(num)
            store(result)
        }
    }

Nested Loops
------------

Loops can be nested to process multi-dimensional data:

.. code-block:: frame
    :caption: Nested Loops

    fn printMatrix(matrix: list) {
        for row in matrix {
            for cell in row {
                print(cell + " ")
            }
            print("\n")
        }
    }

Mixed nested syntax:

.. code-block:: frame
    :caption: Mixed Nested Loop Syntax

    fn findInMatrix(matrix: list, target: int): bool {
        for row in matrix {
            var col = 0
            while col < length(row):
                if row[col] == target:
                    return true
                col = col + 1
        }
        return false
    }

Loops in State Machines
-----------------------

Loops work naturally within state machine event handlers:

.. code-block:: frame
    :caption: Loops in State Machines

    system BatchProcessor {
        interface:
            processBatch(items: list)
            
        machine:
            $Idle {
                processBatch(items: list) {
                    -> $Processing
                    return
                }
            }
            
            $Processing {
                $>() {
                    for item in currentBatch {
                        if !validate(item) {
                            logError(item)
                            continue
                        }
                        
                        processItem(item)
                        
                        if isCritical(item):
                            handleCritical(item)
                    }
                    
                    -> $Idle
                    return
                }
            }
            
        domain:
            var currentBatch = nil
    }

Infinite Loops
--------------

Create infinite loops with ``while true``:

.. code-block:: frame
    :caption: Infinite Loop Pattern

    fn eventLoop() {
        while true {
            var event = getNextEvent()
            
            if event == nil:
                continue
                
            if event == "quit":
                break
                
            handleEvent(event)
        }
    }

Common Patterns
---------------

Search Pattern
++++++++++++++

.. code-block:: frame
    :caption: Search Pattern

    fn search(list: list, predicate: function): int {
        var index = 0
        
        for item in list {
            if predicate(item):
                return index
            index = index + 1
        }
        
        return -1
    }

Filter Pattern
++++++++++++++

.. code-block:: frame
    :caption: Filter Pattern

    fn filterPositive(numbers: list): list {
        var result = []
        
        for num in numbers {
            if num > 0 {
                append(result, num)
            }
        }
        
        return result
    }

Accumulator Pattern
+++++++++++++++++++

.. code-block:: frame
    :caption: Accumulator Pattern

    fn aggregate(data: list): int {
        var sum = 0
        var count = 0
        
        for value in data {
            sum = sum + value
            count = count + 1
        }
        
        if count > 0:
            return sum / count
        else:
            return 0
    }

Early Exit Pattern
++++++++++++++++++

.. code-block:: frame
    :caption: Early Exit Pattern

    fn validateAll(items: list): bool {
        for item in items {
            if !isValid(item) {
                logInvalid(item)
                return false
            }
        }
        return true
    }

Loops in Actions
----------------

Loops in action methods follow the same rules:

.. code-block:: frame
    :caption: Loops in Actions

    system DataValidator {
        actions:
            cleanData(records: list) {
                for record in records {
                    // Skip invalid records
                    if !record.isValid() {
                        logSkipped(record)
                        continue
                    }
                    
                    // Process valid records
                    normalize(record)
                    
                    // Stop on critical error
                    if record.hasError():
                        break
                }
            }
            
            waitForCondition(maxAttempts: int): bool {
                var attempts = 0
                
                while attempts < maxAttempts {
                    if checkCondition():
                        return true
                        
                    sleep(1000)
                    attempts = attempts + 1
                }
                
                return false
            }
    }

Range-Based Iteration (Future)
-------------------------------

Frame will support range-based iteration in future versions:

.. code-block:: frame
    :caption: Future Range Support

    // Simple range (0 to 9)
    for i in range(10):
        print(i)
    
    // Range with start and stop
    for i in range(5, 10):
        print(i)
    
    // Range with step
    for i in range(0, 10, 2):
        print(i)

Syntax Rules
------------

1. **Python-style**: After ``:`` only single statements are allowed
2. **Braced blocks**: Required for multiple statements
3. **No mixed blocks**: Cannot use ``{ }`` after ``:``
4. **Variable declaration**: Optional ``var`` keyword in for loops

Valid Syntax
++++++++++++

.. code-block:: frame
    :caption: Valid Loop Syntax

    // Python-style single statements
    while x < 10: x = x + 1
    for item in items: process(item)
    
    // Braced blocks
    while x < 10 {
        print(x)
        x = x + 1
    }
    
    // Mixed styles
    for item in items:
        if isValid(item):
            process(item)

Invalid Syntax
++++++++++++++

.. code-block:: frame
    :caption: Invalid Loop Syntax

    // ERROR: Block after colon
    while x < 10: {
        x = x + 1
    }
    
    // ERROR: Multiple statements after colon
    for item in items: process(item) log(item)
    
    // ERROR: Missing braces for multiple statements
    while x < 10
        print(x)
        x = x + 1

Legacy Loop Syntax
------------------

Frame v0.20 maintains backward compatibility with the original ``loop`` keyword:

.. code-block:: frame
    :caption: Legacy Loop Syntax (Still Supported)

    // Infinite loop
    loop {
        if done():
            break
        process()
    }
    
    // C-style for loop
    loop var i = 0; i < 10; i = i + 1 {
        print(i)
    }
    
    // For-in style
    loop item in items {
        process(item)
    }

However, the new ``for`` and ``while`` keywords are recommended for new code.

Summary
-------

Frame v0.20's loop constructs provide:

- Familiar ``for`` and ``while`` keywords
- Python-style single-line syntax
- Braced blocks for multiple statements
- Standard ``break`` and ``continue`` control flow
- Natural integration with state machines
- Backward compatibility with legacy ``loop`` syntax

The syntax is designed to be immediately familiar to developers from mainstream languages while maintaining Frame's unique state machine capabilities.