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
    :caption: Empty States 

    #MessageSending

        -interface-

        foo 

        -machine- 

        $Working

            |foo| print("handled foo") ^

    ##


Event Handler Parameters
~~~~~~~~

.. code-block::
    :caption: Event Handler Parameters Demo

    fn main {
        var ehv:# = #EventHandlerDemo()
        ehv.init("Boris", 1959)
    }

    #EventHandlerDemo

        -interface-

        init [name, birth_year] 

        -machine-

        $Start 

            |init| [name,birth_year]
                print("My name is " + name + " and I was born in " + str(birth_year))
                ^

    ##


Run the `program <https://onlinegdb.com/GhepXQeo2>`_. 


Event Handler Terminators
~~~~~~~~

Event handlers are terminated by either a return token **^** or an else-continue token **:>**. See the 
else-continue_ (TODO) (not to be confused with the loop **continue** keyword) article for more details.

Event Handler Return Terminator
+++++++++++

In addition to the the standard return token we have seen, it is also possible to return a value 
with it as well by returning an expression in parenthesis:


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
        var ehv:# = #EventHandlerDemo()
        var ret = ehv.init("Boris", 1959)
        print("Succeeded = " + str(ret))
    }

    #EventHandlerDemo

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

Run the `program <https://onlinegdb.com/6GbktwNUW>`_. 



Event Handler Continue Terminator
+++++++++++

As mentioned, event handlers are also able to be terminated with a continue operator **:>**. In later 
articles we will discuss **Hierarchical State Machines (HSMs)** which enable states to inherit behavior 
from other states. HSMs are created using the *Dispatch Operator* **=>**. 
Unhandled events are automatcially passed to parent states and the continue operator enables 
passing a handled event on to a parent state as well:   

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


Frame supports two special messages each with a reserved message token - enter (**>**) and exit (**<**). 

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

        var age = nil           
        var name = "Natasha"

        |a| ^

    $S1 
        // no state variables
        |b| ^


State Variables are initialized upon entry to the state 
and droped upon exit. Below we see that the counter variable is declared in 
the **$Begin** state. This counter 
does not go out of scope until the system leaves the **$Begin** state. Each time the **inc** interface 
method is called counter is incremented by 1 and printed. This demonstrates that the 
**counter** variable  is scoped to the state itself. 


.. code-block::
    :caption: State Variables

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

            var counter = 0  // state variable initialized to 0

            |inc| 
                counter = counter + 1 
                print("counter = " + str(counter))
                ^
            |cycle| 
                -> $Begin ^
    ##


Run the `program <https://onlinegdb.com/mJtxz-7Lb>`_. 


State Parameters
~~~~~~~

One of the features Frame has to transfer data from one state to another is **state parameters**. 

State parameters are declared by adding a paremeter list after the definition of the state name:

.. code-block::
    :caption: State Parameters
        
    $S0 [a,b] 

During a transition, state parameters are set by arguments passed to the target state.

.. code-block::
    :caption: State Parameters

    $A
        |>| 
            -> $B(0,1) ^ 
        
    $B [zero,one] // zero == 0, one == 1

The transition to state **$B** is "called" with two arguments (0,1) which are mapped respectively to the 
**zero** and **one** parameters in state **$B**.

Transitions are one way to enter a state. However, start states are also "entered" during system 
initalization and start states that have parameters still need to be provided arguments somehow. 
However since during intializatin they are not actually "transitioned" into 
this needs to happen through a different mechanism.

To meet this requirement, Frame provides a special syntax for passing arguments 
during system creation/initalization.

.. code-block::
    :caption: System Initalized Start State Parameters

    fn main {
        #StartStateInitDemo($(0,1))
    }

In this example the **#StartStateInitDemo()** is passed a strange looking argument **$(0,1)**. 
We will see later that systems can have three types of data initalized during startup:

#. Start state parameters
#. Start state enter event handler parameters
#. Domain variables

We need to be able to distingush which scope is being initalized. To do so, Frame encloses
arguments in a specially typed group for each scope target. Here we are targeting the 
state state parameters which uses the group type **$(param1,param2,...)**.

Systems need to declare the parameters for these arguments with a similar syntax: 

.. code-block::
    :caption: System Initalized Start State Parameters
        
    fn main {
        #StartStateInitDemo($(0,1))
    }

    #StartStateInitDemo [$[zero,one]] 

    ##

Here we see the outer brackets 
of the system parameters (**#StartStateInitDemo [...]***) enclose the parameters 
specifically designated to be the start state parameters.

Finally, the state itself has a parameter list. 

.. note: 

    The names of the system start state parameters 
    need to match the names of the actual start state parameters.

.. code-block::
    :caption: System Initalized Start State Parameters
        
    fn main {
        #StartStateInitDemo($(0,1)) // pass the system state state args group
    }

    #StartStateInitDemo [$[zero,one]] // declare the system start state params list

        -machine-

        $StartState [zero,one] // system params list matches the system signature
    ##

.. code-block::
    :caption: System Initalized Start State Parameters
        
    fn main {
        #StartStateInitDemo($(0,1))
    }

    #StartStateInitDemo [$[zero,one]]

        -machine-

        $StartState [zero,one]
            |>|
                print($[zero])  // use state param scope syntax
                print(one)      // resolves to state param scope
                ^
        ##


Run the `program <https://onlinegdb.com/rh7fYLG3C>`_. 

.. code-block::
    :caption: Fibonacci Demo using State Parameters

    fn main {
        var fib:# = #FibonacciStateParamsDemo($(0,1)) 
        loop var x = 0; x < 10; x = x + 1 {
            fib.next()
        }
    }

    #FibonacciStateParamsDemo [$[zero,one]]

        -interface-

        next

        -machine-

        $Setup [zero,one]
            |>| 
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

Run the `program <https://onlinegdb.com/aSfnAzMQCm>`_. 

Notice that parameters **a** and **b** are mutable and persist their values between
invocations of the **|next|** event handler. State parameter values, like state varibles,
persist  until 
the state is exited, at which point they will be dropped. 
