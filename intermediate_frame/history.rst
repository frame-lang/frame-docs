=============
State History
=============

It is sometimes useful to be able to be able to generically transition to a previous state.
An example of this situation is state that
manages a dialog box that can be shown in many different situations. Once it has
been dismissed, however, the system needs to go back to whatever the prior context which 
might have been any number of possible previous states.

To address this kind of scenario Frame supports a “history” mechanism.

History 101
-----------

The following spec illustrates the limitation of state machines with regards
to history. Below we see states `$B` and `$C` both transition into state `$D`.
However, without using some kind of record keeping, there is no natural way for 
the state machine to know whether to return to **$B** or **$C**.

.. code-block::

    #History101

      -machine-

        $A
            |gotoB| -> "B" $B ^
            |gotoC| -> "C" $C ^

        $B
            |gotoD| -> "D" $D ^

        $C
            |gotoD| -> "D" $D ^

        $D

    ##

.. image:: images/history1.png

The machine itself so far has no mechanism to remember where it came from.
To return to the previous state it would need to save that information and 
use it to decide between the two return transition paths. 

.. code-block::
    :caption: History 102 - Return to State Using a State Name

    #History102

      -machine-

        $A
            |gotoB| -> "B" $B ^
            |gotoC| -> "C" $C ^

        $B
            |gotoD| -> "D" $D("B") ^

        $C
            |gotoD| -> "D" $D("C") ^

        $D [previous_state]
            |return| 
                previous_state == "B" ? -> $B ^ :>
                previous_state == "D" ? -> $C ^ :| ^

    ##

.. image:: images/history2.png

This approach enables us to return to our previous state, but not in a generic way. 
Additionally, it does not allow us to return to the previous state *in the same 
condition we left it*. Consider this update: 

.. code-block::
    :caption: History 102-1 - Return to State Using a State Name

    fn main {
        var sys:# = #History102_1()
        sys.gotoB()
        sys.gotoD()
        sys.ret()
    }

    #History102_1

    -interface-
    
    gotoB
    gotoC
    gotoD
    ret 

    -machine-

    $A
        |gotoB| -> "B" $B ^
        |gotoC| -> "C" $C ^

    $B
        var b = 0

        |>| 
            print("Entering B. b = " + str(b)) ^

        |gotoD| 
            b = 1
            print("Going to D. b = " + str(b))
            -> "D" $D("B") ^

    $C
        |gotoD| -> "D" $D("C") ^

    $D [previous_state]
        |ret| 
            previous_state == "B" ? -> "return to $B" $B ^ :>
            previous_state == "D" ? -> "return to $C" $C ^ :| ^

    ##

.. image:: images/history102_1.png

Run the `program <https://onlinegdb.com/bcCp8EByJ9>`_. 

The program generates the following output:

.. code-block::
    :caption: History 102-1 Output

    Hello World
    Entering B. b = 0
    Going to D. b = 1
    Entering B. b = 0

As we can see var b is reset to 0 again after transitioning from $D -> $B.

This is behavior is fine. However, if we want to return to a state *in 
the condition it was prior to the transition* this approach does not work. 
In order to support this capability, Frame provides a **history** feature which 
enables preservation of the previous state's data (low level state).

Let's explore the 

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

.. code-block::

    #History103

      -machine-

        $A
            |gotoC| $$[+] -> "$$[+]" $C ^

        $B
            |gotoC| $$[+] -> "$$[+]" $C ^

        $C
            |return| -> "$$[-]" $$[-] ^

    ##

.. image:: images/history103.png

What we see above is that the state stack push token precedes a transition to a
new state:

.. code-block::

    $$[+] -> $NewState

while the state stack pop operator produces the state to be transitioned into:

.. code-block::

    -> $$[-]

In the next exmple we can see the state stack enable a way to generically return 
to either state **$B** or **$C** from **$D**. No 

.. image:: images/history201.png


.. code-block::
    :caption: History 104 Demo 

    fn main {
        var sys:# = #History104()
        sys.gotoB()
        sys.gotoD()
        sys.ret()
        sys.gotoC()
        sys.gotoD()
        sys.ret()
    }

    #History104

        -interface-
    
        gotoB
        gotoC
        gotoD
        ret 
 

        -machine-

        $A
            |>| print("In $A") ^
            |gotoB| -> "B" $B ^
            |gotoC| -> "C" $C ^

        $B
            |>| print("In $B") ^
            |gotoC| -> "C" $C ^
            |gotoD| $$[+] -> "D" $D ^

        $C
            |>| print("In $C") ^
            |gotoB| -> "B" $B ^
            |gotoD| $$[+] -> "D" $D ^

        $D 
            |>| print("In $D") ^
            |ret| 
                print("returning to ...") 
                -> $$[-] ^

    ##


Run the `program <https://onlinegdb.com/uqUx2C2tlI>`_. 

The program generates the following output:

.. code-block::
    :caption: History 104 Demo Output

    In $A
    In $B
    In $D
    returning to ...
    In $B
    In $C
    In $D
    returning to ...
    In $C

History 202
-----------

In our next example we will combine HSMs for refactoring behavior out of two
states and show how it can work together with the state history mechansism.

The History202 spec below starts in a `$Waiting` state and then transitions
to `$A` or `$B` depending on how the client drives it.

From there both states have an identical handler to transition to `$C`.

.. code-block::

    #History202

     -interface-

     gotoA
     gotoB
     gotoC
     goBack

     -machine-

       $Waiting
           |>| print("In $Waiting") ^
           |gotoA| print("|gotoA|") -> $A ^
           |gotoB| print("|gotoB|") -> $B ^

       $A
           |>| print("In $A") ^
           |gotoB| print("|gotoB|") -> $B ^
           |gotoC| print("|gotoC|") $$[+] -> "$$[+]" $C ^

       $B
           |>| print("In $B") ^
           |gotoA| print("|gotoA|") -> $A ^
           |gotoC| print("|gotoC|") $$[+] -> "$$[+]" $C ^

       $C
           |>| print("In $C") ^
           |goBack| print("|goBack|") -> "$$[-]" $$[-] ^

       -actions-

       print [msg:string]

   ##

.. image:: ../images/intermediate_frame/history202.png

.. raw:: html

    <iframe width="100%" height="475" src="https://dotnetfiddle.net/Widget/aofLnO" frameborder="0"></iframe>

Refactoring Common Behavior
---------------------------
Now lets refactor the common event handler into a new base state.

.. code-block::
    :caption: History 3 Demo 

    #History203

       -interface-

       gotoA
       gotoB
       gotoC
       goBack

       -machine-

       $Waiting
           |>| print("In $Waiting") ^
           |gotoA| print("|gotoA|") -> $A ^
           |gotoB| print("|gotoB|") -> $B ^

       $A => $AB
           |>| print("In $A") ^
           |gotoB| print("|gotoB|") -> $B ^

       $B => $AB
           |>| print("In $B") ^
           |gotoA| print("|gotoA|") -> $A ^

       $AB
           |gotoC| print("|gotoC| in $AB") $$[+] -> "$$[+]" $C ^

       $C
           |>| print("In $C") ^
           |goBack| print("|goBack|") -> "$$[-]" $$[-] ^

       -actions-

       print [msg:string]

    ##

We can see that the duplicated |gotoC| event handler is now moved into $AB and
both $A and $B inherit behavior from it.

.. image:: ../images/intermediate_frame/history203.png


.. raw:: html

    <iframe width="100%" height="475" src="https://dotnetfiddle.net/Widget/U1axyV" frameborder="0"></iframe>

.. note::
    History203 demonstrates the recommended best practice of using a Frame
    specification to define a base class (in this case _History203_) and then
    derive a subclass to provide the implemented actions for behavior.

Conclusion
----------

The History mechanism is one of the most valuable contributions of Statecharts
to the evolution of the state machine.

This article introduced the base concept and use case for state history and
showed its implementation in Frame. In addition, it showed how it works in
conjunction with Hierarchical State Machines. The combination of these two
capabilities makes Statecharts and Frame a powerful and efficient way to both
model and create complex software systems.


Frame State Compartments
------------

So far we have not delved deeply into the architecture of the Frame generated code for 
the system controllers. To understand how Frame's state history feature works, we have to look a little 
under the covers and discuss State Compartments, or simply **Compartments**. This will 
be covered in depth in the advanced section later. 

Frame manages data for state instances using special Compartment objects. Here is the 
Python code Frame generates for the example above: 

.. code-block::
    :caption: Frame Compartment 

    # ===================== Compartment =================== #

class History102_1Compartment:

    def __init__(self,state):
        self.state = state
        self.state_args = {}
        self.state_vars = {}
        self.enter_args = {}
        self.exit_args = {}
        self.forward_event = None

These objects are created and initalized during system intialization of the start state as well
as for each transition to a new state. Therefore, when simply transitioning back to 
**$B** Frame is creating a completely new instance of state **B**. 

In many situations this is the desired behavior. In our situation, it is not. We 
want to return to the very same state we left with the variable **b** equal to 1, not 0.
