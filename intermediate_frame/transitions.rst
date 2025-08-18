==================
Transitions and States
==================

The ability to switch between states a fundamental attribute 
of a state machine. Frame supports two mechanisms for doing so:

#. Transitions 
#. State Changes 

Transitions are powerful and potentially expensive operations that drive much of the 
Frame runtime machinery. 
State Changes are an optimization of transitions which are 
useful for both their speed of operation as well as some special case system design scenarios. 

Transitions
------------

Transitions are performed by using the **->** operator to go to another state. 


.. code-block::
    :caption: Basic Transition Demo

    system BasicTransitionDemo {

        interface:

            next()

        machine:

            $Start {
                next() {
                    -> $End
                    return
                }
            }

            $End
    }

Above we see a system initialized in the **$Start** start state that will transition to 
to the **$End** state upon receiving the **next** event. 

This example does not, however, highlight what is happening behind the scenes in the Frame runtime. 
We will take a look at that behavior next. 

Enter and Exit Events
++++++++++++++++

As discussed elsewhere, one of Frame's most powerful features is the ability to initialize 
and cleanup states upon entry and exit respectively. 
This powerful capability unlocks many improvements to code structure and readability of 
Frame generated software. 

Upon transitioning, Frame first sends a system reserved "exit" message **<** to the current state.  
Below we see an exit handler added to the **$Start** state that prints a message upon exit.

.. code-block::
    :caption: Exit State Transition Demo

        $Start {
            <$() {
                print("exiting $Start state")
                return
            }
            next() {
                print("transitioning to $End state")
                -> $End
                return
            }
        }
        
        $End
 
 After sending the exit message to the current state, the Transition runtime mechanism updates
 the current state to the Transition target state (in this case **$End**) and then sends 
 an "enter" message **>** to the new current state.

.. code-block::
    :caption: Enter State Transition Demo

        $Start {
            <$() {
                print("exiting $Start state")
                return
            }
            next() {
                print("transitioning to $End state")
                -> $End
                return
            }
        }
        
        $End {
            $>() {
                print("entering $End state")
                return
            }
        }

.. code-block::
    :caption: Basic Transition Behavior Demo

    fn main() {
        var btmd = BasicTransitionBehaviorDemo()
        btmd.next()
    }

    system BasicTransitionBehaviorDemo {

        interface:

            next()

        machine:

            $Start {
                <$() {
                    print("exiting $Start state")
                    return
                }
                next() {
                    print("transitioning to $End state")
                    -> $End
                    return
                }
            }
        
            $End {
                $>() {
                    print("entering $End state")
                    return
                }
            }
    }

Run the `program <https://onlinegdb.com/pi4GXit3Y>`_. 

The program generates the following output:

.. code-block::
    :caption: Basic Transition Behavior Demo Output

    transitioning to $End state
    exiting $Start state
    entering $End state


Enter Event Parameters
++++++++++++++++

In the  :ref:`States and Transitions`
article we saw one way to send data directly from 
one state to another by using **state parameters**. 
Another way to accomplish state-to-state direct data transfer is using **enter event parameters**. 


.. code-block::
    :caption: Enter Event Parameters Demo

    -> ("Hello next state!") $NextState 

The Frame transition operator accepts an expression group as arguments to the new state. 

.. code-block::
    :caption: Enter Event Parameters Demo 1

    fn main() {
        var sys = EnterEventParametersDemo1()
        sys.next()
    }

    system EnterEventParametersDemo1 {

        interface:

            next()

        machine:

            $Start {
                next() {
                    -> ("Hello") $End
                    return
                }
            }
        
            $End {
                $>(msg) {
                    print(msg)
                    return
                }
            }
    }

Above we see that the transition passes a message to the **$End** state which is received
as a parameter to the event handler which is then printed. 

Run the `program <https://onlinegdb.com/EbQkoWXmq>`_. 

The program generates the following output:

.. code-block::
    :caption: Enter Event Parameters Demo 1 Output

    Hello

The next examples demonstrates the use of both state-to-state direct data transfer mechanisms together. 

.. code-block::
    :caption: Enter Event Parameters Demo 2

    fn main() {
        var sys = EnterEventParametersDemo2()
        sys.next()
    }

    system EnterEventParametersDemo2 {

        interface:

            next()

        machine:

            $Start {
                next() {
                    -> ("$Start", "Hello") $End("$End")
                    return
                }
            }
        
            $End(to) {
                $>(from, greeting) {
                    print(greeting + " " + to + ". Love, " + from)
                    return
                }
            }
    }

Above we see that the transition sends two strings **("$Start", "Hello")** as arguments that 
match the enter event parameters **$>(from, greeting)** for **$End**. In addition, 
the transition also passes an argument **$End("$End")** to the **End** state parameter 
**$End(to)**.

This fully demonstrates the mechanisms for passing data to the next state without needing to persist 
it in some way before transitioning. 

Run the `program <https://onlinegdb.com/j9tQw2DVr>`_. 

The program generates the following output:

.. code-block::
    :caption: Enter Event Parameters Demo 2 Output

    Hello $End. Love, $Start

Exit Event Parameters
++++++++++++++++

In addition to passing data to the enter handler of the next state, Frame also provides a means 
to pass data to the exit handler of the current state during a transition. 


.. code-block::
    :caption: Exit Event Goodbye Demo

    fn main() {
        var sys = ExitEventGoodbyeDemo()
        sys.next()
        
    }

    system ExitEventGoodbyeDemo {

        interface:

            next()

        machine:

            $Start {
                <$(msg, state) {
                    print(msg + " " + state + "!")
                    return
                }

                next() {
                    ("goodbye", "$Start") -> $End
                    return
                }
            }

            $End

    }

Above we see that, similar to the enter args group specified for the next state, transitions also 
accept an exit args group to be specified for the exit handler. 

Run the `program <https://onlinegdb.com/95DSxesC->`_. 

The program generates the following output:

.. code-block::
    :caption: Exit Event Goodbye Demo Output

    goodbye $Start!

Recalling that Frame enables access to the various parts of the event, another example will 
show how to use the event message token (**$@||**) to parameterize the exit behavior of the 
start state. 

.. code-block::
    :caption: Exit Event Parameters Demo

    fn main() {
        var sys = ExitEventParametersDemo()
        sys.one()
        sys.two()
    }

    system ExitEventParametersDemo {

        interface:

            one()
            two()

        machine:

            $Start {
                <$(event_msg) {
                    event_msg == "one" ? print(event_msg + " is a great number!") :>
                    event_msg == "two" ? print(event_msg + " is a greater number!") :|
                    return
                }

                one() {
                    ($@||) -> $Start
                    return
                }
                two() {
                    ($@||) -> $Start
                    return
                }
            }

    }

This system simply loops back to the start state and passes the message that triggered 
the transition to the exit handler to print a customized message. This capability enables 
factoring out common cleanup behavior with a way to customize it based on the way 
that the system is being exited. 

Run the `program <https://onlinegdb.com/axQHAdQPE>`_. 

The program generates the following output:

.. code-block::
    :caption: Enter Event Parameters Demo 2 Output

    one is a great number!
    two is a greater number!


Transition Labels
++++++++++++++++

In addition to code, the Framepiler can generate UML documentation for the system. 

.. code-block::
    :caption: Transition Labels 

    system TransitionLabels {

        interface:

            click()

        machine:

            $Start {
                click() {
                    -> $One
                    return
                }
            }

            $One {
                click() {
                    -> "Second Click" $Two
                    return
                }
            }

            $Two {
                click() {
                    -> ("three") "Third\nClick" $Done
                    return
                }
            }

            $Done {
                $>(click_count) {
                    print("Done in " + click_count + " clicks.")
                    return
                }
            }
    }

The system above generates the following UML diagram:

.. image:: images/transition_label.png
    :height: 300

The first transition in the example above has the default label which is the message selector for 
the state. 
The second label shows 
a default overridden label. Sometimes labels can be undesirably long. The third transition shows
how to embed a '\n' escape character in the label to create a new line in the label. In addition, 
the third transition shows the correct ordering of the enter arguments group and the label with the 
arguments group before the label.

Forwarding Events
++++++++++++++++

Frame syntax enables events to be forwarded from one state to another using the **dispatch operator =>**
within a transition.  


.. code-block::
    :caption: Forward Event Using Dispatch Operator 

    // Forward event with dispatch operator
     -> => $TargetState

The following example shows how to utilize this feature and a context it might 
be useful.

.. code-block::
    :caption: Forward Event Demo 

    fn main() {
        var sys = ForwardEventDemo()
        sys.payment("$100")
        sys.payment("$200")
        sys.payment("$300")
    }

    system ForwardEventDemo {

        interface:

            payment(paymentData)

        machine:

            $Waiting {
                payment(paymentData) {
                    // Forward event using the dispatch operator =>
                    -> => $ProcessPayment
                    return
                }
            }

            $ProcessPayment {
                payment(paymentData) {
                    print("Payment received: " + paymentData)
                    -> $Waiting
                    return
                }
            }

    }

Above we can see the system waits in the **$Waiting** state until a **payment()** event arrives.
However the **$Waiting** state is not designed to process the payment so it forwards the **payment()** event to 
the **$ProcessPayment** state for processing. After processing the system cycles back to the 
**$Waiting** state to take the next payment. 

Run the `program <https://onlinegdb.com/PQ5EyxXqA>`_. 

The program generates the following output:

.. code-block::
    :caption: Forward Event Demo Output

    Payment received: $100
    Payment received: $200
    Payment received: $300


Grouping Syntax
++++++++++++++++

Frame notation related to transitions is complex and leads to one ambiguous situation.  Consider this 
transition:

.. code-block::

    $Start {
        $>() {
            (foo()) -> $Bar
            return
        }
    }   

This transition will actually cause a transpiler error:

.. code-block::

    [line 15] Error at '$' : Transition exit args length not equal to exit handler parameter length for state $Start

The reason is simple - there is no exit handler for state **$Start** to send the value that **foo()** returns to. 
Although it is unlikely that an expression would need to be grouped like this, the syntax supports it so 
it is ideal for Frame syntax to provide a way to be unambiguous that the **(foo())** expression is not 
intended to be a clause of the transition. To make this code parse, Frame allows for a transition 
to be enclosed in a group:

.. code-block::
    :caption: Transition Clause Grouping 

    $Start {
        $>() {
            (foo()) (-> $Bar)
            return
        }
    }  

With this final bit of syntax we have covered all clauses that comprise the two transition options: 

.. admonition:: Transition Grammar Options
    
    transition: ('(' exit_args ')')? '->' ('(' enter_args ')')? label? '$' state_identifier ('(' state_params ')')?
    transition: '(' '->' ('(' enter_args ')')? label? '$' state_identifier ('(' state_params ')')? ')'

