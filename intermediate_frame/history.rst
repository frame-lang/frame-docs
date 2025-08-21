=============
State History
=============

This documentation covers Frame v0.20 syntax with conventional parameter syntax, return statements, and modern block structure.

It is sometimes useful to be able to be able to generically transition to a previous state.
An example of this situation is state that
manages a dialog box that can be shown in many different situations. When the dialog
is dismissed, however, the system needs to return to its previous context, which  
may have been any number of possible states that launched the dialog.

To address this kind of scenario Frame supports a “history” mechanism.

History 101
-----------

The following spec illustrates the limitation of state machines with regards
to history. Below we see states **$B** and **$C** both transition into state **$D**.


.. code-block:: frame

    system History101 {
        machine:
            $A {
                gotoB() {
                    -> "B" $B
                    return
                }
                gotoC() {
                    -> "C" $C
                    return
                }
            }

            $B {
                gotoD() {
                    -> "D" $D
                    return
                }
            }

            $C {
                gotoD() {
                    -> "D" $D
                    return
                }
            }

            $D {
            }
    }

.. image:: images/history1.png

To return to the previous state there needs to be a way to save that information and 
use it to decide between the two possible return paths. There are a few 
ways we could do this but for this example we will simply choose to pass a state argument containing 
the name of the state that we transitioned from. This value will be used 
in **$D** to determine which state to return to.

.. code-block:: frame
    :caption: History 102 - Return to State Using a State Name

    system History102 {
        machine:
            $A {
                gotoB() {
                    -> "B" $B
                    return
                }
                gotoC() {
                    -> "C" $C
                    return
                }
            }

            $B {
                gotoD() {
                    -> "D" $D("B")
                    return
                }
            }

            $C {
                gotoD() {
                    -> "D" $D("C")
                    return
                }
            }

            $D(previous_state) {
                ret() {
                    if previous_state == "B" {
                        -> "ret" $B
                        return
                    } elif previous_state == "C" {
                        -> "ret" $C
                        return
                    }
                    return
                }
            }
    }

.. image:: images/history2.png

This approach enables us to return to our previous state, but not in a generic way. 
Every time we add another state that transitions to **$D** we will need to add 
another conditional test to make a test to determine if the machine should return 
to that new state. Functional, but not elegant or scalable. 

In addition, this approach does not allow us to return to the previous state *in the same 
condition we left it*. Consider this update: 

.. code-block:: frame
    :caption: History 102-1 - Return to State Using a State Name

    fn main() {
        var sys = History102_1()
        sys.gotoB()
        sys.gotoD()
        sys.ret()
    }

    system History102_1 {
        interface:
            gotoB()
            gotoC()
            gotoD()
            ret()

        machine:
            $A {
                gotoB() {
                    -> "B" $B
                    return
                }
                gotoC() {
                    -> "C" $C
                    return
                }
            }

            $B {
                // b is set to 0 when $B is initialized
                var b = 0

                $>() {
                    print("Entering $B. b = " + str(b))
                    return
                }

                gotoD() {
                    // b set to 1 when leaving $B
                    b = 1
                    print("Going to $D. b = " + str(b))
                    -> "D" $D("B")
                    return
                }
            }

            $C {
                // c is set to 0 when $C is initialized
                var c = 0

                $>() {
                    print("Entering $C. c = " + str(c))
                    return
                }

                gotoD() {
                    // c set to 1 when leaving $C
                    c = 1
                    print("Going to $D. $C = " + str(c))
                    -> "D" $D("C")
                    return
                }
            }

            $D(previous_state) {
                ret() {
                    if previous_state == "B" {
                        -> "return to $B" $B
                        return
                    } elif previous_state == "C" {
                        -> "return to $C" $C
                        return
                    }
                    return
                }
            }
    }

.. image:: images/history102_1.png

Run the `program <https://onlinegdb.com/6FnhU1jUR>`_. 

The program generates the following output:

.. code-block::
    :caption: History 102-1 Output

    Hello World
    Entering B. b = 0
    Going to D. b = 1
    Entering B. b = 0

The first time the system entered **$B** it initialized **b** to 0. 
When transitioning from $B -> $D this variable was set to 1, but 
when transitioning $D -> $B we can see it is reset to 0 again.

This is behavior is fine, and in many cases desirable. 
However, if we want to return to a state *in 
the condition it was prior to the transition* this approach does not work. 
In order to support returning to the *same* state we left, Frame provides a **history** feature which 
enables preservation of the previous state's data (low level state).

Let's explore how the Frame **state stack** can address this requirement. 

State Stack Operators
------------

Frame implements a generic mechanism for **history** utilizing a special **state stack** 
runtime mechanism. 
Stacks have two basic operations - **push** and **pop**. Frame provides two tokens 
to perform those operations:

.. list-table:: State Stack Operators
    :widths: 25 25
    :header-rows: 1

    * - Operator
      - Name
    * - $$[+]
      - State Stack Push
    * - $$[-]
      - State Stack Pop

Let’s see how these are used:

.. code-block:: frame

    system History103 {
        machine:
            $A {
                gotoC() {
                    $$[+]
                    -> "$$[+]" $C
                    return
                }
            }

            $B {
                gotoC() {
                    $$[+]
                    -> "$$[+]" $C
                    return
                }
            }

            $C {
                ret() {
                    -> "$$[-]" $$[-]
                    return
                }
            }
    }

.. image:: images/history103.png

What we see above is that the state stack push token precedes a transition to a
new state:

.. code-block:: frame

    $$[+]
    -> $NewState

while the state stack pop operator produces the state to be transitioned into:

.. code-block:: frame

    -> $$[-]

With this understanding of the state stack operators we can now contrast the differing behavior of transitioning 
to states directly vs when using the state stack.

The State Stack and Compartments
------------

The following example explores the differences between returning to a state using a standard transition 
versus returning to it using the history mechanisms. 

.. code-block:: frame
    :caption: History 104 Demo 

    fn main() {
        var sys = History104()
        print("--------------")
        sys.gotoB()
        sys.gotoD()
        sys.retToB()
        sys.gotoC()
        sys.gotoD()
        sys.retToC()
        print("--------------")
    }

    system History104 {
        interface:
            gotoB()
            retToB()
            gotoC()
            retToC()
            gotoD()

        machine:
            $A {
                $>() {
                    print("In $A")
                    return
                }
                gotoB() {
                    -> "B" $B
                    return
                }
            }

            $B {
                var b = 0

                // upon reentry using a transition, b == 0
                $>() {
                    print("Entering $B. b = " + str(b))
                    return
                }

                gotoC() {
                    print("--------------")
                    print("Going to $C.")
                    print("--------------")
                    -> "C" $C
                    return
                }
                gotoD() {
                    b = 1
                    print("Going to $D. b = " + str(b))
                    -> "D" $D
                    return
                }
            }

            $C {
                var c = 0

                // upon reentry using history pop, c == 1
                $>() {
                    print("Entering $C. c = " + str(c))
                    return
                }

                gotoD() {
                    c = 1
                    print("Going to $D. c = " + str(c))
                    $$[+]
                    -> "D" $D
                    return
                }
            }

            $D {
                $>() {
                    print("In $D")
                    return
                }
                retToB() {
                    print("Returning to $B")
                    -> "retToB" $B
                    return
                }
                retToC() {
                    print("Returning to $C")
                    -> "retToC" $$[-]
                    return
                }
            }
    }

.. image:: images/history104.png

Run the `program <https://onlinegdb.com/GWZya9TRJ>`_. 

The program generates the following output:

.. code-block::
    :caption: History 104 Demo Output

    In $A
    --------------
    Entering $B. b = 0
    Going to $D. b = 1
    In $D
    Returning to $B
    Entering $B. b = 0
    --------------
    Going to $C.
    --------------
    Entering $C. c = 0
    Going to $D. c = 1
    In $D
    Returning to $C
    Entering $C. c = 1
    --------------

Notice these lines in particular:

.. code-block::

    In $D
    Returning to $B
    Entering $B. b = 0

    In $D
    Returning to $C
    Entering $C. c = 1

When transitioning from **$D** -> **$B** we can see that the state variable **b** is reset to 0.
When using the history mechanism to go from **$D** -> **$C** we can see that **c** still has its previous 
value of 1. 

This behavior is possible due to how Frame implements states as first-class objects called
**State Compartments** or simply **Compartments**. When pushing a state to the state stack
using the **$$[+]** operator, the 
Frame runtime is actually pushing the current state compartment onto a stack that the 
runtime maintains. Likewise, when popping the state with **$$[-]**, the runtime removes
the compartment from the stack. If the popped state is also the target of a transition, 
the runtime will then set that state as the current state and transition to it as well. 

Compartments will be covered in depth in the advanced section later.

History using the State Stack 
------------

Finally we will examine a demo that fully utilizes the state stack for the use case that was initially 
discussed - generically returning to the previous state without recording
explicitly in some way what it was. 

The demo below demonstrates this capability by showing that states **$A** and **B** can 
transition to state **$C** and return to those states anonymously using a state stack transition. 

.. code-block:: frame
    :caption: History 105 Demo 

    fn main() {
        var sys = History105()
        // Currently in $A
        sys.gotoC()
        // Now in $C
        sys.ret()
        // Now back in $A
        sys.gotoB()
        // Now in $B
        sys.gotoC()
        // Now in $C
        sys.ret()
        // Now back in $B
    }

    system History105 {
        interface:
            gotoB()
            gotoC()
            ret()

        machine:
            $A {
                var a = 0

                $>() {
                    print("In $A. a = " + str(a))
                    return
                }

                gotoB() {
                    print("Transitioning to $B")
                    -> $B
                    return
                }

                gotoC() {
                    // When we return, a == 1
                    a = a + 1
                    print("Incrementing a to " + str(a))
                    $$[+]
                    -> $C
                    return
                }
            }

            $B {
                var b = 0

                $>() {
                    print("In $B. b = " + str(b))
                    return
                }

                gotoC() {
                    // When we return, b == 1
                    b = b + 1
                    print("Incrementing b to " + str(b))
                    $$[+]
                    -> $C
                    return
                }
            }

            $C {
                $>() {
                    print("In $C")
                    return
                }

                ret() {
                    print("Return to previous state")
                    -> $$[-]
                    return
                }
            }
    }


.. image:: images/history105.png

In the **History105** demo above the system starts in **$A** and transition to **$C** after 
incrementing a state local variable **a** and pushing **$A** onto the state stack. 

.. code-block:: frame
    :caption: $A's transition to $C 

    gotoC() {
        // When we return, a == 1
        a = a + 1
        print("Incrementing a to " + str(a))
        $$[+]
        -> $C
        return
    }

When the system returns to **$A** using a state stack transition, the enter event handler 
will print the updated variable value:

 .. code-block::
    :caption: $A -> $C -> $A output

    In $A. a = 0
    Incrementing a to 1
    In $C
    Return to previous state
    In $A. a = 1

We then transition the system to state **$B** and do the same operations, demonstrating functional 
equivalency between the two state stack transitions.


.. code-block:: frame
    :caption: $B's transition to $C 

    gotoC() {
        // When we return, b == 1
        b = b + 1
        print("Incrementing b to " + str(b))
        $$[+]
        -> $C
        return
    }

.. code-block::
    :caption: $B -> $C -> $B output

    Transitioning to $B
    In $B. b = 0
    Incrementing b to 1
    In $C
    Return to previous state
    In $B. b = 1

Run the `program <https://onlinegdb.com/9wVD5_h4f>`_. 

The full output log for the demo:

.. code-block::
    :caption: History 105 Demo Output 

    In $A. a = 0
    Incrementing a to 1
    In $C
    Return to previous state
    In $A. a = 1
    Transitioning to $B
    In $B. b = 0
    Incrementing b to 1
    In $C
    Return to previous state
    In $B. b = 1



