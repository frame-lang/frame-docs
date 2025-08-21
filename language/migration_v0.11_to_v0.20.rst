=============================
Frame v0.11 to v0.20 Migration Guide
=============================

This guide provides a comprehensive reference for migrating Frame systems from v0.11 syntax to v0.20 syntax. Frame v0.20 introduces conventional syntax patterns that make the language more familiar to developers coming from mainstream programming languages.

Quick Reference
===============

.. list-table:: Syntax Migration Quick Reference
    :widths: 40 40 20
    :header-rows: 1

    * - v0.11 Syntax
      - v0.20 Syntax  
      - Status
    * - ``#SystemName ... ##``
      - ``system SystemName { ... }``
      - ✅ Required
    * - ``-interface-``, ``-machine-``
      - ``interface:``, ``machine:``
      - ✅ Required
    * - ``[param1, param2]``
      - ``(param1, param2)``
      - ✅ Required
    * - ``|eventName|``
      - ``eventName()``
      - ✅ Required
    * - ``|>|``, ``|<|``
      - ``$>()``, ``<$()``
      - ✅ Required
    * - ``^``, ``^(value)``
      - ``return``, ``return value``
      - ✅ Required
    * - ``:>`` (parent dispatch)
      - ``=> $^``
      - ✅ Required
    * - ``#[static]``
      - ``@staticmethod``
      - ✅ Required
    * - ``@`` (current event)
      - ``$@``
      - ✅ Required

System Declaration Changes
==========================

v0.11 Legacy Syntax
--------------------

.. code-block:: frame

    #TrafficLight
        
        -interface-
            start
            stop
            
        -machine-
            $Red
                |start| -> $Green ^
                
            $Green  
                |stop| -> $Red ^
                
        -actions-
            
        -domain-
    ##

v0.20 Modern Syntax
-------------------

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
                
        actions:
            
        domain:
    }

Key Changes Explained
=====================

1. System Declaration
---------------------

**Before (v0.11):**
- Systems wrapped in ``#SystemName ... ##``
- Closing ``##`` required

**After (v0.20):**
- Conventional ``system SystemName { ... }`` syntax
- Standard braces for block structure

2. Block Markers
-----------------

**Before (v0.11):**
- Dash-wrapped markers: ``-interface-``, ``-machine-``, ``-actions-``, ``-domain-``

**After (v0.20):**
- Colon syntax: ``interface:``, ``machine:``, ``actions:``, ``domain:``

3. Parameter Lists
------------------

**Before (v0.11):**
- Square brackets: ``[param1, param2]``

**After (v0.20):**
- Parentheses: ``(param1, param2)``
- Empty lists: ``()`` (fully supported)

4. Event Handlers
-----------------

**Before (v0.11):**
- Pipe syntax: ``|eventName|``
- Enter/exit: ``|>|``, ``|<|``

**After (v0.20):**
- Function-like: ``eventName()``
- Enter/exit: ``$>()``, ``<$()``
- Braces required: ``eventName() { ... }``

5. Return Statements
--------------------

**Before (v0.11):**
- Caret token: ``^``
- With value: ``^(value)``

**After (v0.20):**
- Standard keyword: ``return``
- With value: ``return value``
- Can be used as regular statements in if/elif/else

6. Parent Event Dispatch
-------------------------

**Before (v0.11):**
- Terminator only: ``:>``

**After (v0.20):**
- Statement syntax: ``=> $^``
- Can appear anywhere in event handler
- Allows code after dispatch (unless parent transitions)

7. Attributes
-------------

**Before (v0.11):**
- Rust-style: ``#[static]``

**After (v0.20):**
- Python-style: ``@staticmethod``

8. Current Event Reference
---------------------------

**Before (v0.11):**
- Simple: ``@``

**After (v0.20):**
- Prefixed: ``$@``
- Single ``@`` now reserved for attributes

System Parameters Migration
===========================

v0.11 Complex Parameter Syntax
-------------------------------

.. code-block:: frame

    #Calculator[$[initialValue], >[startMsg], #[precision]]
        
        -machine-
            $Init[initialValue]
                |>[startMsg] 
                    print(startMsg + str(initialValue))
                    ^
                    
        -domain-
            var precision = 2
    ##

v0.20 Simplified Parameter Syntax
----------------------------------

.. code-block:: frame

    system Calculator ($(initialValue), $>(startMsg), precision) {
        
        machine:
            $Init(initialValue) {
                $>(startMsg) {
                    print(startMsg + str(initialValue))
                    return
                }
            }
                    
        domain:
            var precision = 2
    }

System Instantiation Changes
=============================

**Before (v0.11):**

.. code-block:: frame

    fn main() {
        var calc = Calculator($(42), >("Starting: "), #(4))
    }

**After (v0.20):**

.. code-block:: frame

    fn main() {
        var calc = Calculator(42, "Starting: ", 4)
    }

Note: Arguments are flattened in v0.20 - no special prefixes needed.

Control Flow Improvements
=========================

v0.20 introduces conventional if/elif/else syntax that works as regular statements:

**New in v0.20:**

.. code-block:: frame

    processRequest(status: int) {
        if status == 0 {
            logError("Invalid status")
            return
        } elif status == 1 {
            processNormal()
            return  
        } elif status == 2 {
            processUrgent()
            return
        } else {
            logWarning("Unknown status: " + str(status))
            return
        }
    }

Hierarchical State Machines
============================

**Before (v0.11):**

.. code-block:: frame

    #HSMDemo
        -machine-
            $Parent
                |commonEvent| 
                    print("Handled in parent")
                    ^
                    
            $Child => $Parent
                |specificEvent|
                    print("Handled in child")
                    :>  // Forward to parent - terminates handler
    ##

**After (v0.20):**

.. code-block:: frame

    system HSMDemo {
        machine:
            $Parent {
                commonEvent() {
                    print("Handled in parent")
                    return
                }
            }
                    
            $Child => $Parent {
                specificEvent() {
                    print("Handled in child")
                    => $^  // Forward to parent - can continue after
                    print("Back in child after parent processing")
                    return
                }
            }
    }

State Stack Operations
======================

State stack syntax remains the same in v0.20, but now has comprehensive documentation:

.. code-block:: frame

    system ModalSystem {
        machine:
            $MainMenu {
                openDialog() {
                    $$[+]      // Push current state
                    -> $Dialog // Transition to dialog
                    return
                }
            }
            
            $Dialog {
                closeDialog() {
                    -> $$[-]   // Pop and return to previous state
                    return
                }
            }
    }

**Key Features:**
- ``$$[+]`` - Push current state compartment (preserves variables)
- ``$$[-]`` - Pop state compartment and transition to it
- Variables maintain their values across push/pop operations

Migration Strategy
==================

1. **Automated Search and Replace**
-----------------------------------

Use these patterns for bulk conversion:

.. code-block:: bash

    # System declarations
    s/#([A-Za-z_][A-Za-z0-9_]*)/system \1 {/g
    s/##/}/g
    
    # Block markers
    s/-interface-/interface:/g
    s/-machine-/machine:/g
    s/-actions-/actions:/g
    s/-domain-/domain:/g
    
    # Parameters
    s/\[([^]]*)\]/(\1)/g
    
    # Event handlers
    s/\|([^|]*)\|/\1()/g
    s/\|\>\|/$>()/g
    s/\|\<\|/<$()/g
    
    # Returns
    s/\^/return/g
    s/:>/=> $^/g

2. **Manual Updates Required**
------------------------------

- Add braces ``{ }`` around event handler bodies
- Update system parameter syntax
- Fix function calls to use parentheses
- Update attribute syntax from ``#[static]`` to ``@staticmethod``
- Change ``@`` to ``$@`` for current event references

3. **Testing and Validation**
-----------------------------

After migration:

1. **Syntax Check**: Compile with Frame v0.20 transpiler
2. **Behavioral Test**: Verify generated code works correctly
3. **Code Review**: Ensure readability improvements are realized

Common Migration Issues
=======================

Issue 1: Missing Braces
------------------------

**Problem**: Event handlers missing required braces

.. code-block:: frame

    // WRONG - missing braces
    eventName() 
        doSomething()
        return

**Solution**: Add braces around handler body

.. code-block:: frame

    // CORRECT
    eventName() {
        doSomething()
        return
    }

Issue 2: Empty Parameter Lists
-------------------------------

**Problem**: Methods with no parameters missing parentheses

.. code-block:: frame

    // WRONG
    interface:
        start
        stop

**Solution**: Add empty parentheses

.. code-block:: frame

    // CORRECT
    interface:
        start()
        stop()

Issue 3: Parent Dispatch Semantics
-----------------------------------

**Problem**: Expecting ``:>`` terminator behavior with ``=> $^``

**Solution**: Remember ``=> $^`` is a statement, not a terminator

.. code-block:: frame

    // v0.20 - code can continue after parent dispatch
    childEvent() {
        => $^  // Forward to parent
        print("This executes unless parent transitions")
        return
    }

Benefits of v0.20 Syntax
========================

1. **Familiarity**: Syntax more familiar to mainstream developers
2. **Consistency**: Conventional parameter lists and block structure
3. **Flexibility**: Return statements work as regular statements
4. **Readability**: Clear separation between declarations and implementations
5. **Maintainability**: Standard patterns reduce cognitive load
6. **Tooling**: Better IDE support with conventional syntax

Migration Checklist
===================

.. checklist::

   ☐ Update system declarations (``#`` → ``system``, ``##`` → ``}``)
   ☐ Convert block markers (``-interface-`` → ``interface:``)
   ☐ Change parameter syntax (``[]`` → ``()``)
   ☐ Update event handlers (``|event|`` → ``event()``)
   ☐ Add braces to event handler bodies
   ☐ Convert return statements (``^`` → ``return``)
   ☐ Update parent dispatch (``:>`` → ``=> $^``)
   ☐ Change attributes (``#[static]`` → ``@staticmethod``)
   ☐ Update current event references (``@`` → ``$@``)
   ☐ Fix system instantiation (remove prefixes)
   ☐ Test with Frame v0.20 transpiler
   ☐ Verify generated code behavior
   ☐ Update documentation and comments

Further Resources
=================

- **Grammar Reference**: Complete v0.20 BNF grammar
- **Test Suite**: 98 working v0.20 examples in Frame transpiler repository  
- **Documentation**: Updated Frame v0.20 documentation with all new features
- **Migration Tools**: Consider writing scripts for large codebases