Attributes 
===========

Frame v0.20 adopts `Python-style decorator syntax <https://docs.python.org/3/reference/compound_stmts.html#function-definitions>`_ using the **@** symbol to 
add metadata to various entity types. This approach aligns Frame with mainstream language conventions.

Static Operations
-----------------

To make an operation static, add the **@staticmethod** decorator to the function declaration:

.. code-block::
    :caption: Static Operation using Python-style Decorator

    fn main() {
        print(Calculator.add(5, 3))
        print(Calculator.multiply(4, 7))
    }

    system Calculator {

        operations:

            @staticmethod
            add(a: int, b: int): int {
                return a + b
            }

            @staticmethod
            multiply(x: int, y: int): int {
                return x * y
            }
    }

Static vs Instance Operations
-----------------------------

The **@staticmethod** decorator creates important distinctions in how operations behave:

**Static Operations:**
- Called directly on the system type: ``Calculator.add(5, 3)``
- No access to instance data (domain variables)
- No implicit ``self`` parameter in generated code
- Useful for utility functions and pure computations

**Instance Operations:**
- Called on system instances: ``calc.getValue()``
- Full access to domain variables and system state
- Include implicit ``self`` parameter in generated code
- Can modify system state and access domain data

.. code-block::
    :caption: Comparison of Static vs Instance Operations

    system BankAccount {

        operations:

            // Static operation - utility function
            @staticmethod
            validateAccountNumber(accountNum: string): bool {
                return accountNum.length() == 10
            }

            // Instance operation - accesses domain data
            getBalance(): float {
                return balance
            }

            // Instance operation - modifies domain data
            deposit(amount: float) {
                balance = balance + amount
            }

        domain:

            var balance: float = 0.0
    }

Usage examples:

.. code-block::
    :caption: Using Static and Instance Operations

    fn main() {
        // Static operation - no instance needed
        var isValid = BankAccount.validateAccountNumber("1234567890")
        print("Account valid: " + str(isValid))

        // Instance operations - require system instance
        var account = BankAccount()
        account.deposit(100.0)
        print("Balance: " + str(account.getBalance()))
    }

Python-style Decorator Syntax
------------------------------

Frame v0.20 adopts Python's decorator conventions:

- **@staticmethod** - Creates static methods (equivalent to Python's @staticmethod)
- **@** prefix - Follows Python's decorator naming pattern
- **lowercase_with_underscores** - Frame custom attributes follow Python naming conventions

Future Attribute Support
-------------------------

Frame's Python-style attribute system is designed to support additional decorators:

- **@classmethod** - Class methods (when class-level functionality is added)
- **@property** - Property accessors (when property syntax is supported)
- **@deprecated** - Mark operations as deprecated
- **@async** - Asynchronous operations (when async support is added)

The Python-aligned syntax ensures Frame attributes remain familiar to developers from mainstream languages.