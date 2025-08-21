==================
Interface Return Values
==================

This documentation covers Frame v0.20 syntax with conventional return statements and modern block structure. All examples use the updated syntax patterns.

Frame has a powerful syntax to simplify returning values through the interface. 
Although this seems like a trivial system design aspect, the compartmentalization of 
the machine introduces complexities into how and when this value should be set.  

Default Interface Return Value Syntax
-------------

As we have seen, interface methods that return a value can declare a return type or elide it
depending on the requirements of the target language. Declaring a return type for a target language 
that does not require one will be ignored in the generated code.

.. code-block:: frame
    :caption: Default Return Value for Interface Method

    system InterfaceMethodReturnTypes {
        interface:
            getDecisionTyped(): String  // Typed method
            getDecisionUntyped()        // Untyped method
    }
    
By default, unhandled calls to the interface method will return the default value for the 
type depending on the language (null, None, 0 etc). However Frame also provides a means to 
override the default language value and initialize a 
default return value: 

.. code-block:: frame
    :caption: Default Return Value for Interface Method

    fn main() {
        var sys = InterfaceReturnYes()
        print(sys.getDecision())
    }

    system InterfaceReturnYes {
        interface:
            // Set default return value to be "yes".
            getDecision(): String = "yes"
    }

Above we see the syntax for setting the default return value uses the assignment operator `=` after the type declaration. This provides a clean way to specify default interface return values in Frame v0.20. 

Run the `program <https://onlinegdb.com/S5sG-PXIc>`_. 

.. code-block::
    :caption: Output

    yes


Overriding Interface Return Values
-------------

The syntax for setting the default interface return value  provides a nice way to easily 
ensure the base case return value for an interface call. This same syntax is used in 
event handlers as well to modify the interface return value.

.. code-block:: frame
    :caption: Override Return Value for Interface Method

    fn main() {
        var sys = InterfaceReturnNo()
        print(sys.getDecision())
    }

    system InterfaceReturnNo {
        interface:
            getDecision() = "yes"

        machine:
            $No {
                getDecision() {
                    // Modify the default from "yes" value to "no".
                    return "no"
                }
            }
    }

Run the `program <https://onlinegdb.com/g5HmA2IIy>`_. 

.. code-block::
    :caption: Output

    no

An important, but somewhat subtle, aspect of the return mechanism is that the value can be 
reset at any point in the handling of an event. This doesn't always happen in the 
first event handler to process a message. 

.. code-block:: frame
    :caption: Overriding an Override    

    fn main() {
        var sys = InterfaceReturnMaybe()
        print(sys.getDecision())
    }

    system InterfaceReturnMaybe {
        interface:
            // 1. Default return value set to "yes". 
            getDecision() = "yes"

        machine:
            $No {
                getDecision() {
                    // 2. First override of return value to "no". 
                    // 3. Transition to $Maybe state.
                    return = "no"
                    -> $Maybe
                    return
                }
            }
        
            $Maybe {
                $>() {
                    // 4. Upon entry set return value to "maybe". 
                    return = "maybe"
                    return
                }
            }
    }


Run the `program <https://onlinegdb.com/dq0JN5HbB>`_. 

.. code-block::
    :caption: Output

    maybe

Above we can see how the return value is set multiple times throughout the handling of an 
interface call. However,  
Frame v0.20 now supports `return` statements as regular statements anywhere within event handlers, providing much more flexibility than the previous version's terminator-only approach.


The Return Assign Operator
-------------

To facilitate setting the return value during any point in the execution, Frame v0.20 supports the 
"return assign" syntax **return = value**. This allows setting the interface return value 
anywhere in event handlers or actions. 

.. code-block:: frame
    :caption: return = Syntax to Set Return Value 

    fn main() {
        var sys = InterfaceReturnMaybeAnotherWay()
        print(sys.getDecision())
    }

    system InterfaceReturnMaybeAnotherWay {
        interface:
            getDecision() = "yes"

        machine:
            $No {
                getDecision() {
                    return = "no"
                    -> $Maybe
                    return
                }
            }
        
            $Maybe {
                $>() {
                    // Setting the interface return 
                    // using the "return assign" syntax.
                    return = "maybe another way"
                    return
                }
            }
    }

Run the `program <https://onlinegdb.com/d4zJ-s_Vr>`_. 

.. code-block::
    :caption: Output

    maybe another way

Actions and Return Values
-------------

Action return value syntax works somewhat differently than event handler return syntax. In 
an action, the `return` statement returns a value from the *action* 
to the *event handler*. It *does not set the interface return value*. 
In order to set the interface return value inside of an action, always use 
the return assign **return = value** syntax instead. 

This example demonstrates how to properly set an interface return value from inside an action:

.. code-block:: frame
    :caption: Interface Return from Actions 

    fn main() {
        var sys = InterfaceReturnFromAction()

        // 6. Print final interface return value. 
        print(sys.getDecision())
    }

    system InterfaceReturnFromAction {
        interface:
            getDecision() = "yes"

        machine:
            $No {
                getDecision() {
                    return = "no"
                    -> $Maybe
                    return
                }
            }
        
            $Maybe {
                $>() {
                    // 1. Set interface return with the return assignment syntax. 
                    return = "maybe another way"

                    // 5. Print action return value. 
                    print(
                        // 2. Call action. 
                        actionReturn()
                    )
                    return
                }
            }

        actions:
            actionReturn() {
                // 3. Reset interface return again.
                return = "action interface return"

                // 4. Do normal return from action.
                return "action call return"
            }
    }   

In the code above, step 3 sets the final interface return value while step 4 uses 
the `return` statement to return a value from the action to the event handler, which 
is then printed first. The main function then prints the final interface return value. 

Run the `program <https://onlinegdb.com/8c9zBT-9m>`_. 

.. code-block::
    :caption: Output

    action call return
    action interface return

Initialization and Interface Return Values 
-------------

One final twist to interface return value behavior is how it works in 
in relationship to system initialization. During system initialization
no value is returned to anything as it is the system factory that 
is making the call. Therefore the return value is simply ignored. 

.. code-block:: frame
    :caption: System Init Return Behavior 

    fn main() {
        var sys = InterfaceReturnSurprise()
        print(sys.getDecision())
    }

    system InterfaceReturnSurprise {
        interface:
            // 3. getDecision is called after system initialization completed
            getDecision() = "yes - surprised?"

        machine:
            $No {
                // 1. Init call from system instantiation.
                // NOTE: this happens *before* getDecision is called!
                $>() {
                    return = "no"
                    -> $Maybe
                    return
                }
            }
        
            $Maybe {
                // 2. Still in the context of the system initialization
                $>() {
                    return = "maybe another way"
                    return
                }
            }
    }    

As a reminder, the Frame system runtime provides a system factory that does all system initialization 
and then sends the **$>** message to the start state, which in this case is **$No**. Therefore 
no value will be returned, despite being set in steps 1 and 2, in this phase of system operation. 

In step 3, therefore, the interface simply returns the default "yes - surprised?" value.

Run the `program <https://onlinegdb.com/tGAmJI8U0L>`_. 

.. code-block::
    :caption: Output

    yes - surprised?