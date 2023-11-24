==================
States and Transitions
==================

Machine Block 
-------------

States are defined inside the machine block. The machine block is optional but must be after the 
interface block (if it exists) and before the actions and domain blocks (if they exist). 

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
~~~~~~~~

The message selector is indicated by two pipe characters which match an event message. Event messages
are set to the name of interface method that generated it.

.. code-block::
    :caption: Sending Messages 

    #MessageSending

        -interface-

        // The "foo" interface method sends the "foo" event message

        foo 

        -machine- 

        $Working

            // This event handler is triggered when the state
            // recieves a "foo" message. 

            |foo| print("handled foo") ^

    ##


Event Handler Parameters
~~~~~~~~

Event handler signatures must align with the signature of interface method 
that sends the event message it responds to. Here we can see that 
the init interface method parameters are identical with the **|init|** event handler 
signature:

.. code-block::
    :caption: Event Handler Parameters Demo

    fn main {
        var ehpd:# = #EventHandlerParametersDemo()
        ehpd.init("Boris", 1959)
    }

    #EventHandlerParametersDemo

        -interface-

        init [name, birth_year] 

        -machine-

        $Start 

            |init| [name,birth_year]
                print("My name is " + name + " and I was born in " + str(birth_year))
                ^

    ##


Run the `program <https://onlinegdb.com/yKZKs6pR6>`_. 


Event Handler Terminators
~~~~~~~~

Event handlers are terminated by either a return token **^** or an else-continue token **:>**. 

Event Handler Return Terminator
+++++++++++

In addition to the the standard return token we have seen which returns nothing from 
the event handler, it is also possible to return a value to the interface  as well. 
This is accomplished by adding an expression in parenthesis after the **^** token:

.. code-block::
    :caption: Event Handler Return Value

    $Oracle
        |getName| : string  ^(name)
        |getMeaning| : number  ^(21*2) 
        |getWeather| : string ^(weatherReport())

Event handlers that return values must be declared identidally to the interface methods 
that they correspond to:

.. code-block::
    :caption: Event Handler Return Demo

    fn main {
        var ehrd:# = #EventHandlerReturnDemo()
        var ret = ehrd.init("Boris", 1959)
        print("Succeeded = " + str(ret))
    }

    #EventHandlerReturnDemo

        -interface-

        // interface signature matches event handler signature
        init [name, birth_year] : bool 

        -machine-

        $Start 

            // event handler signature matches interface signature
            |init| [name, birth_year] : bool 
                print("My name is " + name + " and I was born in " + str(birth_year))
                ^(true)

    ##

Notice the **^(true)** statement which sets the FrameEvent's return object which the 
interface then passes back to the caller. 

Run the `program <https://onlinegdb.com/Ad87kwvpz>`_. 



Event Handler Continue Terminator
+++++++++++

As mentioned, event handlers are also able to be terminated with a continue operator **:>**. In later 
articles we will discuss **Hierarchical State Machines (HSMs)** in depth. HSMs enable states to inherit behavior 
from other states and are created using the Frame *Dispatch Operator* **=>**. 
While unhandled events are automatically passed to parent states, the continue operator enables 
the capability to pass a handled event to a parent state as well:   

.. code-block::
    :caption: Event Handler Continue Terminator

    fn main {
        var hsm:# = #HSM_Preview()
        hsm.passMe1()
        hsm.passMe2()
    }

    #HSM_Preview

        -interface-

        passMe1
        passMe2 

        -machine-

        // Dispatch operator (=>) defines state hierarchy
        $Child => $Parent 

            // Continue operator sends events to $Parent
            |passMe1|  :>
            |passMe2|  print("handled in $Child") :>

        $Parent

            |passMe1| print("handled in $Parent") ^
            |passMe2| print("handled in $Parent") ^

    ##

Run the `program <https://onlinegdb.com/nChYZ01BD>`_. 

Enter and Exit Events
---------

One of the most important features of the Frame language is the support of two special 
messages - enter (**>**) and exit (**<**). Not surprisingly these messages are generated 
by the Frame runtime in cirucmstances when the the state is being entered or exited. 

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

We will explore the means by which states are entered and exited next. 

Transitions
-----------

Transitions between states are affected by the use of the **->** operator.

.. code-block::
    :caption: Transitions

    #S0 
        |>|
            -> $S1 ^
    $S1

Transitions are fully explored in another article. For the purposes of this article 
they are important to understand state behavor. Here is a simple system machine with three 
states. The main function instantiates the system and drives it to the **$End** state:

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

The program generates the following output:

.. code-block::
    :caption: StateSystem Enter/Exit Output

    entering $Begin
    exiting $Begin
    entering $Working
    exiting $Working
    entering $End

Lining up this output with the system spec, we see that the start state **$Begin** 
generates **entering $Begin** when the system is created and initialized. The 
system is then sent the **next** message which results in a transition to the 
**Working** state. Upon exit of **$Begin**, the exit event handler generates **exiting $Begin**
followed by the **entering $Working** executed upon entry to **$Working**. 

This pattern repeats and drives the system finally to the **$End** state. 

Enter and exit events are key to enabling the initialization and cleanup of the system 
as it transitions from one state to another. This powerful capability unlocks many improvements
to code structure and readability of Frame generated software. 


Variables
-----------

States have three special scopes variables are declared in:

#. Event Handler Variables
#. Event Handler Parameters
#. State Variables
#. State Parameters


We will explore each of these scopes in this article. 

Event Handler Variables
~~~~~~~

Variables can be defined in the scope of an event handler. They are valid during the invocation
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


Event Handler Parameters
~~~~~~~

Event handlers for an event need to have the same signature (parameters and return types) as the interface method that generated 
the message. 

.. code-block::
    :caption: Event Handler Demo

    fn main {
        var ehv:# = #EventHandlerDemo()
        var ret = ehv.init("Boris", 1959)
        print("Succeeded = " + str(ret))
    }

    #EventHandlerDemo

        -interface-

        init [name, birth_year] : bool // init method 

        -machine-

        $Start 

            |init| [name,birth_year] : bool 
                print("My name is " + name + " and I was born in " + str(birth_year))
                ^(true)

    ##

Run the `program <https://onlinegdb.com/bW8x6no_B>`_. 


State Variables
~~~~~~~

In addition to variables in event handlers, states can have their own variables. 
State variables are declared in the state scope before the event handlers. 

.. code-block::
    :caption: State Variables

    -machine-

    $S0

        // State Variables are defined before event handlers

        var name = "Natasha"
        var age = "not saying"           
     
        |a| print("My name is " + name + " and I am " + age + " years old." ^

    $S1 
        // no state variables
        |b| ^


State Variables are initialized upon entry to the state 
and dropped upon exit. Below we see that the counter variable is declared in 
the **$Begin** state. This counter 
does not go out of scope until the system leaves the **$Begin** state. Each time the **inc** interface 
method is called counter is incremented by 1 and printed. When the system is cycled back to 
**$Begin** we can see that the counter has been reset to 0. This demonstrates that the 
**counter** variable is a state local variable scoped to the *instance* of the state. 


.. code-block::
    :caption: State Variables Demo

    fn main {
        var svd:# = #StateVariablesDemo() 
        svd.inc()
        svd.inc()
        svd.cycle()
        svd.inc()
        svd.inc()
    }

    #StateVariablesDemo

        -interface-

        inc
        cycle

        -machine-

        $Begin

            // state variable initialized to 0

            var counter = 0  

            |>| 
                print("Entering $Begin, counter = " + str(counter)) ^
            |<| print("Exiting $Begin, counter = " + str(counter)) ^

            |inc| 
                counter = counter + 1 
                print("Handling |inc|, counter = " + str(counter))
                ^
            |cycle| 
                print("Cycling")
                -> $Begin ^
    ##


Run the `program <https://onlinegdb.com/NBIKiLuH3>`_. 

.. code-block::
    :caption: State Variables Demo Output 

    Entering $Begin, counter = 0
    Handling |inc|, counter = 1
    Handling |inc|, counter = 2
    Cycling
    Exiting $Begin, counter = 2
    Entering $Begin, counter = 0
    Handling |inc|, counter = 1
    Handling |inc|, counter = 2

Above we can see that each reentry to $Begin reinitializes the counter state variable to 0.

State Parameters
~~~~~~~

States are compartmentalized environments 
One of the features Frame has to transfer data from one state to another is **state parameters**. 
State parameters are declared by adding a paremeter list after the definition of the state name.

.. code-block::
    :caption: State Parameters
        
    $S0 [x,y] 

During a transition, state parameters are set by arguments passed to the target state.

.. code-block::
    :caption: State Parameters

    $S0
        |>| 
            -> $S1(0,1) ^ 
        
    $S1 [zero,one] // zero == 0, one == 1

The transition to state **$S1** is "called" with two arguments (0,1) which are mapped respectively to the 
**zero** and **one** parameters in state **$S1**.

Transitions are one way to enter a state. However, start states are also "entered" during system 
initalization and need to be provided arguments from this avenue as well. 

To meet this requirement, Frame allows for a **system parameters list** which permits callers a 
mechanism for passing in initialization data directly to the system. There are three scopes of system 
data that can be initalized using the system parameter list:

#. Start state parameters
#. Start state enter event handler parameters
#. Domain variables

The first two parameter types are specific to initalizing the start state and are the only ones 
we will discuss in depth in this article. 

System parameters have an unusual syntax, as the parameters need to be grouped based on 
their target scope. To make it very clear which scope a parameter is for, Frame 
specifies different groupings for each scope:

=========================================== ======================
Scope                                       System Parameter Group 
------------------------------------------- ----------------------

Start State Parameters                      $[...]
Start state enter event handler parameters  >[...]
Domain variables                            #[...]
=========================================== ======================

System parameter groups are optional, but must be in the specific order shown:

.. code-block::
    :caption: System Parameter Group Ordering

    #SystemParameters [$[...],>(...),#(...)]

If no system parameters are declared, the enclosing list should not be present - it is 
an error to declare an empty parameter list.

In the next example we see how the start state is initialized with two parameters, one as a 
state parameter and one as an enter event parameter.

.. code-block::
    :caption: System Initalized Start State Parameters

    #StartStateInitDemo [$[zero],>[one]]

        -machine-

        $StartState [zero]
            |>| [one]
                print(zero)  // use state param scope syntax
                print(one)      // resolves to state param scope
                ^
    ##


.. note::

    The names of the *system* start state parameters 
    need to match the names of the start state's parameters.

The final step is to initialize the system parameters with arguments upon 
instantiation. 

.. code-block::
    :caption: Call groups

    #StartStateInitDemo($(0),>(1))

The system declaration passes parameters, all of which must be enclosed in the appropriate type of 
call list (using parenthesis) for arguments. 

Here is a demo with all of these aspects together:

.. code-block::
    :caption: System Initalized Start State Parameters
        
    fn main {
        #StartStateInitDemo($(0),>(1))
    }

    #StartStateInitDemo [$[zero],>[one]]

        -machine-

        $StartState [zero]
            |>| [one]
                print(zero)  // use state param scope syntax
                print(one)      // resolves to state param scope
                ^
    ##

Run the `program <https://onlinegdb.com/IajrHD80s8>`_. 

A final example will tie together all of these concepts neatly together and demo a practical
application of these capabilities.

.. code-block::
    :caption: Fibonacci Demo using System Parameters

    fn main {
        var fib:# = #FibonacciSystemParamsDemo($(0),>(1)) 
        loop var x = 0; x < 10; x = x + 1 {
            fib.next()
        }
    }

    #FibonacciSystemParamsDemo [$[zero],>[one]]

        -interface-

        next

        -machine-

        $Setup [zero]
            |>| [one]
                print(zero)  
                print(one)    

                // initalize $PrintNextFibonacciNumber state parameters
                -> $PrintNextFibonacciNumber(zero,one) ^ 
            
        // params [a,b] = (0,1)
        $PrintNextFibonacciNumber [a,b] 
            |next| 
                var sum = a + b
                print(sum) 
                a = b
                b = sum
                ^
    ##

Run the `program <https://onlinegdb.com/mCqbyq__p>`_. 

Notice that $PrintNextFibonacciNumber stte parameters **a** and **b** are mutable and persist 
their values between
invocations of the **|next|** event handler. State parameter values, like state varibles,
persist  until the state is exited, at which point they will be dropped. 
