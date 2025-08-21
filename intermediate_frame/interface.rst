==================
System Interface
==================

The system interface block contains the set of publicly accessible methods that send messages to the state machine. 
The interface block is 
indicated by the **interface:** keyword and must be after the **operations:** block if it is present and 
before the **machine:** block if it is present. 

Interface methods have two primary responsibilities:

#. Create and initialize a FrameEvent with the data provided by the caller 
#. Send the event to the runtime kernel and return any value returned by the event handler

The three parts of the signature for interface methods are:

#. Method name
#. Parameter list
#. Return type

.. admonition:: Interface Method Syntax

    <method_name> '(' (<prm_name> (':' <prm_type>)? (',' <prm_name> (':' <prm_type>)?)*)? ')' (':' <ret_type>)? 
  
Interface Method Name 
---------------------

The interface method name must be a string of alphanumeric characters plus the underscore '_' character and
the name must not start with a number.  Ultimately this name must also be valid in the target language as 
a method identifier.

Interface Parameter List    
---------------------

The parameter list for interface methods follows the same rules as :ref:`functions and actions<functions-and-actions>`. 
Although any combination of typed or untyped parameters is permitted, the target language must support 
the generated syntax. Interface methods without parameters must still include empty parentheses **()**.

**Important**: Interface method parameters must have identical names and types to their corresponding 
event handlers in the machine block to ensure proper event routing and type safety. 

Parameter types can be superstrings.

Return Type
-----------

As with variable typing, method return types are indicated by **': ret_type'** syntax. 
Return types are optional and can be any valid identifier or superstring. 


Examples
--------

The following examples show the permitted variations in method signatures:

.. code-block::
    :caption: Interface Method Examples

    interface:
        simple_method()                           // no params, no return type
        method_untyped_params(p1, p2)             // untyped params, no return type
        method_superstring_params(p1: `[]int`)    // superstring param type, no return type
        method_typed_params(p1: T1, p2: T2)       // typed parameters, no return type
        method_params_ret(p1: T1, p2: T2): T3     // typed parameters, has return type
        method_superstring_ret(): `[]int`         // no parameters, superstring return type
        method_mixed(p1, p2: T2): T3              // mixed parameter types, has return type

Complete Interface Example
--------------------------

The following example shows how interface methods correspond to event handlers in the machine block:

.. code-block::
    :caption: Interface to Machine Block Mapping

    system Calculator {
        interface:
            add(x: int, y: int): int
            subtract(x: int, y: int): int
            reset()
            
        machine:
            $Ready {
                add(x: int, y: int): int {
                    return x + y
                }
                
                subtract(x: int, y: int): int {
                    return x - y
                }
                
                reset() {
                    print("Calculator reset")
                    return
                }
            }
    }

**Note**: The parameter names and types in the interface block must exactly match 
those in the corresponding event handlers in the machine block.