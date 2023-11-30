=============
State History
=============

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

To return to the previous state there needs to be a way to save that information and 
use it to decide between the two return transition paths. There are a few 
ways we could do this but for this example we will simply choose to pass a state argument containing 
the name of the state that we transitioned from. This value will be used 
in **$D** to determine which state to return to.

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
            |ret| 
                previous_state == "B" ? -> "ret" $B ^ :>
                previous_state == "D" ? -> "ret" $C ^ :| ^

    ##

.. image:: images/history2.png

This approach enables us to return to our previous state, but not in a generic way. 
Every time we add another state that transtions to **$D** we will need to add 
another contitional to make a test to determine if the machine should return 
to that new state. Functional, but not elegant or scalable. 

In addtion this approach does not allow us to return to the previous state *in the same 
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
        // b is set to 0 when $B is initalized
        var b = 0

        |>| 
            print("Entering B. b = " + str(b)) ^

        |gotoD| 
            // b set to 1 when leaving $B
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

The first time the system entered **$B** it initialized **b** to 0. 
When transitioning from $B -> $D this variable was set to 1, but 
when transitioning $D -> $B we can see it is reset to 0 again.

This is behavior is fine, and in many cases desireable. 
However, if we want to return to a state *in 
the condition it was prior to the transition* this approach does not work. 
In order to support returning to the *same* state we left, Frame provides a **history** feature which 
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
to either state **$B** or **$C** from **$D**.  

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
            var b = 0

            |>| print("Entering $B. b = " + str(b)) ^

            |gotoC| -> "C" $C ^
            |gotoD|
                b = 1
                print("Going to $D. b = " + str(b))
                $$[+]  -> "D" $D ^

        $C
            var c = 0

            |>| print("Entering $C. c = " + str(c)) ^

            |gotoB| -> "B" $B ^
            |gotoD|
                c = 1
                print("Going to $D. c = " + str(c))
                $$[+]  -> "D" $D ^

        $D
            |>| print("In $D") ^
            |ret|
                print("returning to ...")
                -> "ret" $$[-] ^

    ##

.. image:: images/history104.png

Run the `program <https://onlinegdb.com/kUIdya0s3>`_. 

The program generates the following output:

.. code-block::
    :caption: History 104 Demo Output

    In $A
    Entering $B. b = 0
    Going to $D. b = 1
    In $D
    returning to ...
    Entering $B. b = 1
    Entering $C. c = 0
    Going to $D. c = 1
    In $D
    returning to ...
    Entering $C. c = 1

Notice these lines in particular:

.. code-block::

    In $D
    returning to ...
    Entering $B. b = 1

    In $D
    returning to ...
    Entering $C. c = 1

This is evidence that the states **B** and **C** were not reinitalized using the history 
operators. This behavior is possible due to how Frame implements states as first-class objects called
**State Compartments** or simply **Compartments**. **Compartments** will 
be covered in depth in the advanced section later. 

