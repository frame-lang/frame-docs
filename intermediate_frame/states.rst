==================
States and Transitions
==================

Machine Block 
-------------

States are defined inside the machine block. The machine block is optional by must be after the 
interface block (if it exists) and before the actions block (if it exists). 

.. code-block::
    :caption: Empty Machine Block 

    #StatesSystem

        -interface-
        -machine-    // machine block must go here
        -actions-
        -domain-

    ##

States 
------

The machine block can contain zero or more states. The first state in the machine block is 
called the **start state**.

.. code-block::
    :caption: Empty States 

    #StatesSystem

        -machine-

        $Begin  // start state

        $Working

        $End

    ##

Event Handlers
--------------

States by themselves do nothing. State behavior exists in **event handlers**. Event handlers have three 
clauses:

#. Message selector
#. Statements (zero or more) 
#. Return or Continue token

.. admonition: Event Handler Syntax

       '|' message '|' statement* return_or_continue
 

Message Selector
----------------

The message selector is indicated by two pipe characters which match an event message. Event messages
are set to the name of interface method that generated it.

.. code-block::
    :caption: Empty States 

    #MessageSending

        -interface-

        foo 

        -machine- 

        $Working
            |foo| print("handled foo") ^

    ##

Frame supports two special messages each with a special message token - enter (**>**) and exit (**<**). 

.. code-block::
    :caption: Enter and Exit Messages

    #StatesSystem

        -machine-

        $Begin
            |>| print("entering $Begin") ^
            |<| print("exiting $Begin") ^

        $Working

        $End
    ##


The enter message is sent to a state under two conditions: 

#. to the **start state** when the system is initalized (1 time event)
#. when transitioning into the state 

The exit message is sent only  when transtioning out of a state. 

Transitions
-----------

Transitions between states are affected by the use of the **->** operator.

.. code-block::
    :caption: Enter and Exit Messages

    fn main {
        var ss:# = #StatesSystem() 
        ss.next()
        ss.next()
    }

    #StatesSystem

        -interface-

        next 
        
        -machine-

        $Begin
            |>| print("entering $Begin") ^
            |<| print("exiting $Begin") ^

            |next| 
                -> $Working ^

        $Working
            |>| print("entering $Working") ^
            |<| print("exiting $Working") ^

            |next| 
                -> $Working ^

        $End
            |>| print("entering $End") ^

    ##


Run the `program <https://onlinegdb.com/GDIh90nx5>`_. 

Variables
-----------

Event Handler Variables
~~~~~~~

Variables can be created in the scope of an event handler. They only remain valid during the invocation
of the event handler and are invalidated upon return.

.. code-block::
    :caption: Event Handler Scoped Variables

    fn main {
        #EventHandlerVariablesDemo() 
    }

    #EventHandlerVariablesDemo

        -machine-

        $Begin
            |>| 
                var x = 21 * 2
                print("Meaning of life = " + str(x))
            ^
    ##

State Variables
~~~~~~~

.. code-block::
    :caption: State Variables

    fn main {
        var svd:# = #StateVariablesDemo() 
        svd.inc()
        svd.inc()
        svd.inc()
        svd.inc()
    }

    #StateVariablesDemo

        -interface-

        inc

        -machine-

        $Begin

            var counter = 0  // state variable initialized to 0

            |inc| 
                counter = counter + 1 
                print("counter = " + str(counter))
            ^
    ##

Above we see that the counter variable is declared in the $Begin state. This counter 
does not go out of scope until the system leaves the $Begin state. Each time the **inc** interface 
method is called counter is incremented by 1 and printed. This demonstrates counter is 
scoped to the state itself. 

Run the `program <https://onlinegdb.com/w1R57VTEo>`_. 


State Parameters
~~~~~~~

Frame enables the transfer of data from one state to another in state scope using **state parameters**. 
State parameters are like state varibles but are intialized during the transition itself and 
not upon entering the state. 

.. code-block::
    :caption: Fibonacci Demo using State Parameters

    fn main {
        var spd:# = #FibonacciDemo() 
        loop var x = 0; x < 10; x = x + 1 {
            spd.next()
        }
    }

    #FibonacciDemo

        -interface-

        next

        -machine-

        $Setup
            |>| 
                var a = 0
                var b = 1
                print(a)
                print(b)
                -> $PrintNextFibonacciNumber(a,b) ^ // initalize $PrintNextFibonacciNumber parameters
            
        $PrintNextFibonacciNumber [c,d] // params [c,d] = (0,1)
            |next| 
                var sum = c + d
                print(sum) 
                c = d
                d = sum
                ^
    ##


Run the `program <https://onlinegdb.com/r11_RhnY5>`_. 
