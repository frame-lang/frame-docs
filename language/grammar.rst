============
Frame Grammar v0.30
============

This grammar specification reflects Frame v0.30 syntax with multi-entity support, deprecated feature cleanup, and modern block structure. It has been comprehensively validated with 98 working Frame systems and 100% test success rate for modern syntax.

**v0.30 Architecture**: Frame now uses a proper modular architecture with ``FrameModule`` as the top-level AST container, ensuring systems and functions are peer entities within modules rather than artificial hierarchies.

Module Structure
================

.. code-block:: bnf

    frame_module: module_metadata (function | system)*
    module_metadata: module_attribute*
    module_attribute: attribute_expr

    // Legacy for compatibility - now generates FrameModule internally
    module: function* system*

Functions
=========

Frame v0.30 supports multiple functions with any names per module. Functions serve as entry points and utilities, while systems provide state machine functionality.

.. code-block:: bnf

    function: 'fn' IDENTIFIER '(' parameter_list? ')' type? function_body
    function_body: '{' stmt* '}'
    parameter_list: parameter (',' parameter)*
    parameter: IDENTIFIER type?
    type: ':' type_expr
    type_expr: IDENTIFIER | SUPERSTRING

**Note**: Function parameter lists always require parentheses ``()``, even when empty. The ``parameter_list?`` indicates the parameters inside are optional, but the parentheses themselves are mandatory.

**v0.30 Features**: 
- Multiple functions per module with any valid identifiers as names
- Empty parameter lists ``()`` fully supported, enabling conventional method call patterns
- Functions can coexist with multiple systems in the same module

Function Examples
^^^^^^^^^^^^^^^^^

.. code-block:: frame

    // Basic main function
    fn main() {
        print("Hello, Frame!")
    }

    // Main with return type
    fn main(): int {
        return 0
    }

    // Main with system interaction
    fn main() {
        var calc = Calculator()
        var result = calc.add(5, 3)
        print("Result: " + str(result))
    }

Systems
=======

.. code-block:: bnf

    system: 'system' IDENTIFIER system_params? '{' system_component* '}'
    system_params: '(' system_param_list ')'
    system_param_list: system_param (',' system_param)*
    system_param: start_state_param | enter_event_param | domain_param
    start_state_param: '$(' parameter_list ')'
    enter_event_param: '$>(' parameter_list ')'
    domain_param: IDENTIFIER type?

    system_component: operations_block
                    | interface_block
                    | machine_block
                    | actions_block
                    | domain_block

**Component Order**: System components must appear in the specified order when present: ``operations:``, ``interface:``, ``machine:``, ``actions:``, ``domain:``. Components are optional but order is enforced by the parser.

System Examples
^^^^^^^^^^^^^^^

Basic System
++++++++++++

.. code-block:: frame

    system TrafficLight {
        interface:
            start()
            stop()
            
        machine:
            $Red {
                start() {
                    -> $Green
                    return
                }
            }
            
            $Green {
                stop() {
                    -> $Red
                    return
                }
            }
    }

System with Parameters
++++++++++++++++++++++

.. code-block:: frame

    // System with start state parameters
    system StartStateParameters ($(msg)) {
        machine:
            $Start(msg) {
                $>() {
                    print(msg)
                    return
                }
            }
    }

    // System with start state enter event parameters
    system StartStateEnterParameters ($>(msg)) {
        machine:
            $Start {
                $>(msg) {
                    print(msg)
                    return
                }
            }
    }

    // System with domain parameters
    system DomainParameters (msg) {
        domain:
            var msg = nil
            
        machine:
            $Start {
                $>() {
                    print(msg)
                    return
                }
            }
    }

System Instantiation
^^^^^^^^^^^^^^^^^^^^

System instantiation uses flattened argument lists:

.. code-block:: frame

    fn main() {
        // No parameters
        var sys1 = TrafficLight()
        
        // Start state parameters - flattened list
        var sys2 = StartStateParameters("hello")
        
        // Start state enter event parameters - flattened list
        var sys3 = StartStateEnterParameters("world")
        
        // Domain parameters - flattened list
        var sys4 = DomainParameters("message")
    }

Interface Block
===============

.. code-block:: bnf

    interface_block: 'interface:' interface_method*
    interface_method: IDENTIFIER '(' parameter_list? ')' type?

Machine Block
=============

.. code-block:: bnf

    machine_block: 'machine:' state*
    state: '$' IDENTIFIER ('=>' '$' IDENTIFIER)? '{' event_handler* state_var* '}'
    event_handler: event_selector '{' stmt* terminator? '}'
    event_selector: IDENTIFIER '(' parameter_list? ')' type?
                   | '$>' '(' parameter_list? ')'  // Enter handler
                   | '<$' '(' parameter_list? ')'  // Exit handler
    terminator: 'return' expr?
              | '=>'              // Forward/dispatch event
              | '->' '$' IDENTIFIER  // Transition
    state_var: 'var' IDENTIFIER type? '=' expr

Hierarchical State Machines
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Frame supports hierarchical state machines where child states can inherit behavior from parent states:

.. code-block:: bnf

    hierarchy: '$' IDENTIFIER '=>' '$' IDENTIFIER

**Event Forwarding to Parent States**

The ``=> $^`` statement forwards events from child states to their parent states:

.. code-block:: frame

    machine:
        // Parent state
        $Parent {
            commonEvent() {
                print("Handled in parent")
                return
            }
        }
        
        // Child state inherits from parent
        $Child => $Parent {
            specificEvent() {
                print("Processing in child first")
                => $^  // Forward to parent state
                print("This continues after parent unless parent transitions")
                return
            }
        }

Domain Block
============

.. code-block:: bnf

    domain_block: 'domain:' domain_var*
    domain_var: 'var' IDENTIFIER type? '=' expr

Operations Block
================

.. code-block:: bnf

    operations_block: 'operations:' operation*
    operation: attribute* IDENTIFIER '(' parameter_list? ')' type? '{' stmt* '}'
    attribute: '@' IDENTIFIER  // Python-style attributes (e.g., @staticmethod)

Operations Examples
^^^^^^^^^^^^^^^^^^^

Instance Operations
+++++++++++++++++++

.. code-block:: frame

    system Calculator {
        operations:
            // Instance operation - includes implicit 'self' parameter
            getResult(): int {
                return currentValue
            }
        
        domain:
            var currentValue: int = 0
    }

Static Operations  
+++++++++++++++++

.. code-block:: frame

    system MathUtils {
        operations:
            // Static operation - no 'self' parameter, callable without instance
            @staticmethod
            add(a: int, b: int): int {
                return a + b
            }
            
            @staticmethod
            multiply(x: int, y: int): int {
                return x * y
            }
    }

Actions Block
=============

.. code-block:: bnf

    actions_block: 'actions:' action*
    action: IDENTIFIER '(' parameter_list? ')' type? action_body
    action_body: '{' stmt* '}'

Action Method Examples
^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: frame

    actions:
        // Simple action with return
        add(x: int, y: int): int {
            return x + y
        }
        
        // Action with conditional returns
        classify(score: int): string {
            if score >= 90 {
                return "A"
            } elif score >= 80 {
                return "B"
            } elif score >= 70 {
                return "C"
            } else {
                return "F"
            }
        }

Statements
==========

.. code-block:: bnf

    stmt: expr_stmt
        | var_decl
        | assignment
        | if_stmt
        | for_stmt
        | while_stmt
        | loop_stmt
        | return_stmt
        | return_assign_stmt
        | parent_dispatch_stmt
        | transition_stmt
        | state_stack_op
        | block_stmt
        | break_stmt
        | continue_stmt

    expr_stmt: expr
    var_decl: 'var' IDENTIFIER type? '=' expr
    assignment: lvalue '=' expr
    return_stmt: 'return' expr?
    return_assign_stmt: 'return' '=' expr
    parent_dispatch_stmt: '=>' '$^'
    transition_stmt: '->' '$' IDENTIFIER
    state_stack_op: '$$[' '+' ']' | '$$[' '-' ']'
    block_stmt: '{' stmt* '}'
    break_stmt: 'break'
    continue_stmt: 'continue'

Conditional Statements
======================

.. code-block:: bnf

    if_stmt: 'if' expr ':' stmt elif_clause* else_clause?
           | 'if' expr block elif_clause* else_clause?

    elif_clause: 'elif' expr ':' stmt
               | 'elif' expr block

    else_clause: 'else' ':' stmt  
               | 'else' block

    block: '{' stmt* '}'

Frame supports both Python-style colon syntax for single statements and braced blocks for multiple statements:

.. code-block:: frame

    // Python-style
    if x > 5:
        doSomething()
    elif y < 10:
        doOther()
    else:
        doDefault()

    // Braced blocks
    if x > 5 {
        doSomething()
        doMore()
    } elif y < 10 {
        doOther()
        doAnother()
    } else {
        doDefault()
    }

Loop Statements
===============

.. code-block:: bnf

    // For loops
    for_stmt: 'for' (var_decl | identifier) 'in' expr ':' stmt
            | 'for' (var_decl | identifier) 'in' expr block
            | 'for' var_decl ';' expr ';' expr block  // C-style for loop

    // While loops  
    while_stmt: 'while' expr ':' stmt
              | 'while' expr block

    // Legacy loop syntax (maintained for backward compatibility)
    loop_stmt: 'loop' '{' stmt* '}'
             | 'loop' var_decl ';' expr ';' expr '{' stmt* '}'
             | 'loop' (var_decl | identifier) 'in' expr '{' stmt* '}'

Loop Examples
^^^^^^^^^^^^^

.. code-block:: frame

    // For-in loops
    for item in items:
        process(item)

    for item in items {
        process(item)
        doMore()
    }

    // C-style for loops
    for var i = 0; i < 10; i = i + 1 {
        print("Item " + str(i))
    }

    // While loops
    while x < 10:
        x = x + 1

    while x < 10 {
        x = x + 1
        doSomething()
    }

State Stack Operations
======================

Frame v0.20 provides comprehensive state stack operations for implementing history mechanisms and state preservation:

.. code-block:: bnf

    state_stack_op: '$$[' '+' ']' | '$$[' '-' ']'

**State Stack Examples**

.. code-block:: frame

    // State stack push - saves current state
    gotoModal() {
        $$[+]          // Push current state onto stack
        -> $ModalState // Transition to new state
        return
    }

    // State stack pop - returns to saved state
    closeModal() {
        -> $$[-]       // Pop and transition to previous state
        return
    }

**State Stack Operators:**

- **``$$[+]``** - Push current state compartment onto stack (preserves variables)
- **``$$[-]``** - Pop state compartment from stack and use as transition target

**Key Features:**

- **State Preservation**: Variables maintain their values when using stack operations
- **Generic Return**: No need to hardcode which state to return to
- **Compartment Management**: Works with Frame's state compartment system
- **Flexible Usage**: Can be combined with transitions and other statements

Parent Dispatch Statement
=========================

Frame v0.20 introduces the ``=> $^`` statement for forwarding events from child states to their parent states in hierarchical state machines:

.. code-block:: frame

    machine:
        $Child => $Parent {
            testEvent() {
                print("Child processing first")
                => $^  // Forward to parent state
                print("This executes after parent unless parent transitions")
                return
            }
        }

**Key Features:**

- **Statement syntax**: Can appear anywhere in event handler, not just at the end
- **Transition detection**: Code after ``=> $^`` doesn't execute if parent triggers a transition
- **Validation**: Parser prevents usage in non-hierarchical states
- **Flexibility**: Multiple ``=> $^`` calls allowed in same handler

Interface Return Assignment
===========================

Frame v0.20 introduces the ``return = expr`` syntax for setting interface return values:

.. code-block:: frame

    // Setting interface return values in event handlers
    machine:
        $ProcessingState {
            validateInput(data: string): bool {
                if data == "" {
                    return = false  // Set interface return value
                    return          // Exit event handler  
                }
                
                if checkFormat(data) {
                    return = true   // Set interface return value
                    return          // Exit event handler
                }
                
                return = false      // Default case
                return
            }
        }

Expressions
===========

.. code-block:: bnf

    expr: binary_expr | unary_expr | primary_expr | call_expr

    binary_expr: expr operator expr
    operator: '+' | '-' | '*' | '/' | '%'
            | '==' | '!=' | '<' | '>' | '<=' | '>='
            | '&&' | '||'

    unary_expr: ('-' | '!' | '~') expr

    primary_expr: IDENTIFIER | NUMBER | STRING | SUPERSTRING
                | 'true' | 'false' | 'nil'
                | '(' expr ')' | '$@'

    call_expr: IDENTIFIER '(' arg_list? ')'
    arg_list: expr (',' expr)*

Tokens
======

.. code-block:: bnf

    IDENTIFIER: [a-zA-Z_][a-zA-Z0-9_]*
    NUMBER: [0-9]+ ('.' [0-9]+)?
    STRING: '"' (ESC | ~["])* '"'
    SUPERSTRING: '`' ~[`]* '`' | '```' ~* '```'

Keywords
========

.. code-block::

    system interface machine actions operations domain
    fn var return
    if elif else for while loop in break continue
    true false nil

Special Symbols
===============

- ``$`` - State prefix and enter event symbol
- ``<$`` - Exit event symbol  
- ``->`` - Transition operator
- ``=>`` - Dispatch/hierarchy operator
- ``=> $^`` - Forward event to parent state (v0.20)
- ``$@`` - Current event reference
- ``$$[+]`` - Push current state onto stack
- ``$$[-]`` - Pop state from stack and transition

Deprecated Features (v0.11 → v0.20)
====================================

The following syntax from Frame v0.11 is deprecated in v0.20:

1. **System declaration**: 
   - Old: ``#SystemName ... ##``
   - New: ``system SystemName { ... }``

2. **System parameters**:
   - Old: ``#SystemName [$[start], >[enter], #[domain]]``
   - New: ``system SystemName ($(start), $>(enter), domain)``

3. **System instantiation**:
   - Old: ``SystemName($("a"), >("b"), #("c"))``
   - New: ``SystemName("a", "b", "c")`` (flattened arguments)

4. **Block markers**: 
   - Old: ``-interface-``, ``-machine-``, ``-actions-``, ``-domain-``
   - New: ``interface:``, ``machine:``, ``actions:``, ``domain:``

5. **Return token**: 
   - Old: ``^`` and ``^(value)``
   - New: ``return`` and ``return value``

6. **Parameter lists**: 
   - Old: ``[param1, param2]``
   - New: ``(param1, param2)``

7. **Event selectors**: 
   - Old: ``|eventName|``
   - New: ``eventName()``

8. **Enter/Exit events**:
   - Old: ``|>|`` and ``|<|``
   - New: ``$>()`` and ``<$()``

9. **Event forwarding to parent**:
   - Old: ``:>`` (v0.11-v0.19), ``@:>`` (early v0.20)
   - New: ``=> $^`` (v0.20)

10. **Attributes**:
    - Old: ``#[static]`` (Rust-style)
    - New: ``@staticmethod`` (Python-style)

11. **Current event reference**:
    - Old: ``@`` for current event
    - New: ``$@`` for current event (single ``@`` now reserved for attributes)

Implementation Status
=====================

**v0.20 Features Validated (100% Working):**

- ✅ **Core Syntax**: System declarations, event handlers, actions, interfaces, domains
- ✅ **Control Flow**: if/elif/else, for/while/loop, return statements, break/continue
- ✅ **State Management**: Transitions, hierarchical states, enter/exit events, state variables
- ✅ **Modern Syntax**: Conventional parameter syntax, block structure, flattened arguments
- ✅ **System Parameters**: Start state, enter event, and domain parameter syntax
- ✅ **Event Forwarding**: ``=> $^`` statement for parent state dispatch with router-based architecture
- ✅ **Return Mechanisms**: Both return statements and return assignment (``return = expr``)
- ✅ **Test Coverage**: 100% of comprehensive test files passing for v0.20 features (98/98 files)
- ✅ **Empty Parameter Lists**: Full support for ``()`` syntax in all contexts
- ✅ **Router Architecture**: Unified parent dispatch through dynamic router infrastructure
- ✅ **State Stack Operations**: Complete ``$$[+]`` and ``$$[-]`` implementation