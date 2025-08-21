States and Transitions
==================

This documentation covers Frame v0.20 syntax with conventional parameter syntax, return statements, and modern block structure. All examples use the updated syntax patterns.

Machine Block 
-------------

States are defined inside the machine block. The machine block is optional but must follow the 
interface block (if it exists) and precede the actions and domain blocks (if they exist). 

.. code-block:: frame
    :caption: Empty Machine Block 

    system StatesSystem {
        interface:
        machine:    // machine block must go here
        actions:
        domain:
    }

States 
------

The machine block can contain zero or more states. The first state in the machine block is 
called the **start state**.

.. code-block:: frame
    :caption: Start State 

    system StatesSystem {
        machine:
            $Begin {  // start state
            }

            $Working {
            }

            $End {
            }
    }

Event Handlers
--------------

States, by themselves, do nothing. State behavior exists in **event handlers**. Event handlers have three 
clauses:

#. Message selector
#. Statements (zero or more) 
#. Return or Continue token

.. admonition:: Event Handler Syntax

       message '(' parameter_list? ')' type? '{' statement* terminator '}'
 

Message Selector
~~~~~~~~

The message selector is indicated by two pipe characters which match an event message. Event messages
are set to the name of interface method that generated it.

.. code-block:: frame
    :caption: Sending Messages 

    system MessageSending {
        interface:
            // The "foo" interface method sends the "foo" event message
            foo()

        machine:
            $Working {
                // This event handler is triggered when the state
                // receives a "foo" message. 
                foo() {
                    print("handled foo")
                    return
                }
            }
    }


Event Handler Parameters
~~~~~~~~

Event handler signatures must align with the signature of interface method 
that sends the event message it responds to. Here we can see that 
the init interface method parameters are identical with the **|init|** event handler 
signature:

.. code-block:: frame
    :caption: Event Handler Parameters Demo

    fn main() {
        var ehpd = EventHandlerParametersDemo()
        ehpd.init("Boris", 1959)
    }

    system EventHandlerParametersDemo {
        interface:
            init(name, birth_year)

        machine:
            $Start {
                init(name, birth_year) {
                    print("My name is " + name + " and I was born in " + str(birth_year))
                    return
                }
            }
    }


Run the `program <https://onlinegdb.com/yKZKs6pR6>`_. 

.. code-block::
    :caption: Event Handler Parameters Demo Output

    My name is Boris and I was born in 1959

Event Handler Terminators
~~~~~~~~

Event handlers in Frame v0.20 are terminated by either a **return** statement, the continue operator **@:>**, or the dispatch operator **=>**. 

Event Handler Return Terminator
+++++++++++

The **return** statement can return nothing or return a value to the interface. Frame v0.20 now supports return statements as regular statements, enabling conventional control flow patterns:

.. code-block:: frame
    :caption: Event Handler Return Value

    $Oracle {
        getName(): string {
            return name
        }
        getMeaning(): number {
            return 21 * 2
        }
        getWeather(): string {
            return weatherReport()
        }
    }

Event handlers that return values must be declared identically to the interface methods 
that they correspond to.

.. code-block:: frame
    :caption: Event Handler Return Demo

    fn main() {
        var ehrd = EventHandlerReturnDemo()
        var ret = ehrd.init("Boris", 1959)
        print("Succeeded = " + str(ret))
    }

    system EventHandlerReturnDemo {
        interface:
            // interface signature matches event handler signature
            init(name, birth_year): bool

        machine:
            $Start {
                // event handler signature matches interface signature
                init(name, birth_year): bool {
                    print("My name is " + name + " and I was born in " + str(birth_year))
                    return true
                }
            }
    }

Notice the **return true** statement which sets the FrameEvent's return object which the 
interface then passes back to the caller. 

Run the `program <https://onlinegdb.com/Ad87kwvpz>`_. 

.. code-block::
    :caption: Event Handler Return Demo Output 

    My name is Boris and I was born in 1959
    Succeeded = True


Event Handler Continue Terminator
+++++++++++

As previously mentioned, event handlers are also able to be terminated with a continue operator **@:>**. In later 
articles we will discuss **Hierarchical State Machines (HSMs)** in depth. HSMs enable states to inherit behavior 
from other states and are created using the Frame *Dispatch Operator* **=>**. 
While unhandled events are automatically passed to parent states, the continue operator enables the 
handled event to be passed to a parent state as well:   

.. code-block:: frame
    :caption: Event Handler Continue Terminator

    fn main() {
        var sys = ContinueTerminatorDemo()
        sys.passMe1()
        sys.passMe2()
    }

    system ContinueTerminatorDemo {
        interface:
            passMe1()
            passMe2()

        machine:
            // Dispatch operator (=>) defines the state hierarchy
            $Child => $Parent {
                // Continue operator sends events to $Parent
                passMe1() {
                    @:>
                }
                passMe2() {
                    print("handled in $Child")
                    @:>
                }
            }

            $Parent {
                passMe1() {
                    print("handled in $Parent")
                    return
                }
                passMe2() {
                    print("handled in $Parent")
                    return
                }
            }
    }

Run the `program <https://onlinegdb.com/l7WBIHtd7>`_. 


.. code-block::
    :caption: Event Handler Continue Terminator Output

    handled in $Parent
    handled in $Child
    handled in $Parent

Enter and Exit Events
---------

One of the most important features of the Frame language is the support of two special 
messages - enter (**>**) and exit (**<**). Not surprisingly, these messages are generated 
by the Frame runtime in circumstances when the the state is being entered or exited. 

.. code-block:: frame
    :caption: Enter and Exit Messages

    system StatesSystem {
        machine:
            $Begin {
                $>() {
                    print("entering $Begin")
                    return
                }
                <$() {
                    print("exiting $Begin")
                    return
                }
            }

            $Working {
            }

            $End {
            }
    }


The enter message is sent to a state under two conditions: 

#. to the **start state** when the system is initialized (1 time event)
#. when transitioning into the state 

The exit message is sent only  when transitioning out of a state.
We will explore the means by which states are entered and exited next. 

Transitions
-----------

Transitions between states are affected by the use of the **->** operator.

.. code-block:: frame
    :caption: Transitions

    system S0 {
        machine:
            $S0 {
                $>() {
                    -> $S1
                    return
                }
            }
            $S1 {
            }
    }

Transitions are fully explored in another article. For the purposes of this article 
they are important in order to understand state behavior. 
To see  them in action we will examine a simple system with three states that handle enter and exit events. 
The main function instantiates the system and drives it to the **$End** state:

.. code-block:: frame
    :caption: Enter and Exit Messages Demo

    fn main() {
        var eemd = EnterExitMessagesDemo()
        eemd.next()
        eemd.next()
    }

    system EnterExitMessagesDemo {
        interface:
            next()

        machine:
            $Begin {
                $>() {
                    print("entering $Begin")
                    return
                }
                <$() {
                    print("exiting $Begin")
                    return
                }

                next() {
                    -> $Working
                    return
                }
            }

            $Working {
                $>() {
                    print("entering $Working")
                    return
                }
                <$() {
                    print("exiting $Working")
                    return
                }

                next() {
                    -> $End
                    return
                }
            }

            $End {
                $>() {
                    print("entering $End")
                    return
                }
            }
    }

Run the `program <https://onlinegdb.com/2XE6J5jzW>`_. 

The program generates the following output:

.. code-block::
    :caption: Enter and Exit Messages Demo Output

    entering $Begin
    exiting $Begin
    entering $Working
    exiting $Working
    entering $End

Lining up this output with the system spec, we see that the start state **$Begin** 
generates "**entering $Begin**"" when the system is created and initialized. The 
system is then sent the **next** message which results in a transition to the 
**$Working** state. The **$Begin** exit event handler generates "**exiting $Begin**""
followed by the "**entering $Working**"" printed upon entry to **$Working**. 

The system finally to the **$End** state where it stops. 

Enter and exit events are key to enabling fine grained initialization and cleanup of  system resources
as it transitions from one state to another. 
This powerful capability unlocks many improvements to code structure and readability of Frame generated software. 


Variables
-----------

States have four special scopes where variables are declared in:

#. Event Handler Variables
#. Event Handler Parameters
#. State Variables
#. State Parameters

We will explore each of these scopes next. 

Event Handler Variables
~~~~~~~

Variables can be defined in the scope of an event handler and are valid during the invocation
of the event handler and are dropped when exiting it.

.. code-block:: frame
    :caption: Event Handler Scoped Variables

    fn main() {
        EventHandlerVariablesDemo()
    }

    system EventHandlerVariablesDemo {
        machine:
            $Begin {
                $>() {
                    var x = 21 * 2
                    print("Meaning of life = " + str(x))
                    return
                }
            }
    }


Event Handler Parameters
~~~~~~~

Event handlers for an event need to have the same signature (parameters and return types) as the interface method that generated 
the message. 

.. code-block:: frame
    :caption: Event Handle Parameters Demo

    fn main() {
        var ehpd = EventHandlerParametersDemo()
        var ret = ehpd.init("Boris", 1959)
        print("Succeeded = " + str(ret))
    }

    system EventHandlerParametersDemo {
        interface:
            init(name, birth_year): bool  // init method

        machine:
            $Start {
                init(name, birth_year): bool {
                    print("My name is " + name + " and I was born in " + str(birth_year))
                    return true
                }
            }
    }

Run the `program <https://onlinegdb.com/Bhs0wGQ_P>`_. 


.. code-block::
    :caption: Event Handle Parameters Demo Output 

    My name is Boris and I was born in 1959
    Succeeded = True    

State Variables
~~~~~~~

In addition to variables in event handlers, states can have their own variables. 
State variables are declared in the state scope before the event handlers. 

.. code-block:: frame
    :caption: State Variables

    system StateVariablesExample {
        machine:
            $S0 {
                // State variables are defined before event handlers
                var name = "Natasha"
                var age = "not saying"

                a() {
                    print("My name is " + name + " and I am " + age + " years old.")
                    return
                }
            }

            $S1 {
                // no state variables
                b() {
                    return
                }
            }
    }


State Variables are initialized upon entry to the state 
and dropped upon exit. Below we see that the counter variable is declared in 
the **$Begin** state. This counter 
does not go out of scope until the system leaves the **$Begin** state. Each time the **inc** interface 
method is called the counter variable is incremented by 1 and printed. When the system is transitioned
to the current **$Begin** state we can see that the counter has been reset to 0. This demonstrates that the 
**counter** variable is a state local variable scoped to the *instance* of the state. 


.. code-block:: frame
    :caption: State Variables Demo

    fn main() {
        var svd = StateVariablesDemo()
        svd.inc()
        svd.inc()
        svd.cycle()
        svd.inc()
        svd.inc()
    }

    system StateVariablesDemo {
        interface:
            inc()
            cycle()

        machine:
            $Begin {
                // state variable initialized to 0
                var counter = 0

                $>() {
                    print("Entering $Begin, counter = " + str(counter))
                    return
                }
                <$() {
                    print("Exiting $Begin, counter = " + str(counter))
                    return
                }

                inc() {
                    counter = counter + 1
                    print("Handling inc(), counter = " + str(counter))
                    return
                }
                cycle() {
                    print("Cycling")
                    -> $Begin
                    return
                }
            }
    }


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
State parameters are declared by adding a parameter list after the definition of the state name.

.. code-block:: frame
    :caption: State Parameters
        
    $S0(x, y) { 

During a transition, state parameters are set by arguments passed to the target state.

.. code-block:: frame
    :caption: State Parameters

    $S0 {
        $>() {
            -> $S1(0, 1)
            return
        }
    }
        
    $S1(zero, one) {  // zero = 0, one = 1
    }

The transition to state **$S1** is "called" with two arguments (0,1) which are mapped respectively to the 
**zero** and **one** parameters in state **$S1**.

Transitions are one way to enter a state. However, start states are also "entered" during system 
initialization and need to be provided arguments from this avenue as well. 

To meet this requirement, Frame allows for a **system parameters list** which permits callers a 
mechanism for passing in initialization data directly to the system. There are three scopes of system 
data that can be initialized using the system parameter list:

#. Start state parameters
#. Start state enter event handler parameters
#. Domain variables

The first two parameter types are specific to initializing the start state and are the only ones 
we will discuss in depth in this article. 

System parameters have an unusual syntax, as the parameters need to be grouped based on 
their target scope. To make it very clear which scope a parameter is for, Frame 
specifies different grouping syntax for each scope:

=========================================== ======================
Scope                                       System Parameter Group 
------------------------------------------- ----------------------

Start State Parameters                      $(...)
Start state enter event handler parameters  $>(...)
Domain variables                            name (no special syntax)
=========================================== ======================

System parameter groups are optional, but must be in the specific order shown:

.. code-block:: frame
    :caption: System Parameter Group Ordering

    system SystemParameters ($(arg1, arg2), $>(arg3, arg4), arg5, arg6) {
    }

If no system parameters are declared, the enclosing list should not be present - it is 
an error to declare an empty parameter list.

In the next example we see how the start state is initialized with two parameters, one as a 
state parameter and one as an enter event parameter.

.. code-block:: frame
    :caption: System Initialized Start State Parameters

    system StartStateInitDemo ($(zero), $>(one)) {
        machine:
            $StartState(zero) {
                $>(one) {
                    print(zero)  // use state param scope syntax
                    print(one)   // resolves to state param scope
                    return
                }
            }
    }


.. note::

    The names of the *system* start state parameters 
    need to match the names of the start state's parameters. In v0.20, system instantiation uses flattened argument lists.

The final step is to initialize the system parameters with arguments upon 
instantiation. 

.. code-block:: frame
    :caption: System Instantiation

    StartStateInitDemo(0, 1)

System instantiation in v0.20 uses flattened argument lists where all arguments are passed in order without special grouping syntax. 

Here is a demo with all of these aspects together:

.. code-block:: frame
    :caption: System Initialized Start State Parameters Complete Example
        
    fn main() {
        StartStateInitDemo(0, 1)
    }

    system StartStateInitDemo ($(zero), $>(one)) {
        machine:
            $StartState(zero) {
                $>(one) {
                    print(zero)  // use state param scope syntax
                    print(one)   // resolves to state param scope
                    return
                }
            }
    }

Run the `program <https://onlinegdb.com/IajrHD80s8>`_. 


.. code-block::
    :caption: System Initalized Start State Parameters Output
   
    0
    1


A final example will tie together all of these concepts neatly together and demo a practical
application of these capabilities.

.. code-block:: frame
    :caption: Fibonacci Demo Using System Parameters

    fn main() {
        var fib = FibonacciSystemParamsDemo(0, 1)
        loop var x = 0; x < 10; x = x + 1 {
            fib.next()
        }
    }

    system FibonacciSystemParamsDemo ($(zero), $>(one)) {
        interface:
            next()

        machine:
            $Setup(zero) {
                $>(one) {
                    print(zero)
                    print(one)

                    // initialize $PrintNextFibonacciNumber state parameters
                    -> $PrintNextFibonacciNumber(zero, one)
                    return
                }
            }
            
            // params (a,b) = (0,1)
            $PrintNextFibonacciNumber(a, b) {
                next() {
                    var sum = a + b
                    print(sum)
                    a = b
                    b = sum
                    return
                }
            }
    }

Run the `program <https://onlinegdb.com/mCqbyq__p>`_. 

.. code-block::
    :caption: Fibonacci Demo using System Parameters Output

    0
    1
    1
    2
    3
    5
    8
    13
    21
    34
    55
    89    

Notice that **$PrintNextFibonacciNumber** state parameters **a** and **b** are mutable and persist 
their values between
invocations of the **|next|** event handler. State parameter values, like state variables,
persist until the state is exited, at which point they will be dropped. 
