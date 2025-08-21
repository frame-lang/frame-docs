===========================
Hierarchical State Machines
===========================

Frame supports the notion of states inheriting behavior from other states. In doing so, 
a system develops a hierarchy of parent-child relationships between states. A state machine 
that supports hierarchy is known as a **Hierarchical State Machine (HSM)**.

Hierarchy is useful for factoring common behavior between states into a parent, thus normalizing
the implementation of behavior and eliminating redundancy in the system. In an HSM, when  
changes are made to the shared behavior there is a single place to make the modification. 

Parent-child relationships are established between states using the **dispatch operator =>**. We 
have seen this used elsewhere for forwarding events to other states during a transition. 


.. code-block::
    :caption: Defining Parent-Child States Using the Dispatch Operator

    $Child => $Parent

Multiple children can derive behavior from the same parent.

.. code-block::
    :caption: Defining Parent-Child States Using the Dispatch Operator

    $Child1 => $Parent
    $Child2 => $Parent 

State hierarchy can extend to any depth.

.. code-block::
    :caption: State Hierarchy Depth

    $S3 => $S2
    $S2 => $S1
    $S1 => $S0

The next example will show refactoring of a common behavior between two states to a parent state. 

.. code-block::
    :caption: Flat State Machine

    system FlatStateMachine {

        interface:
            a()
            b()
        
        machine:
            $S1 {
                a() {
                    -> "a" $S2
                    return
                }
                b() {
                    -> "b" $S3
                    return
                }
            }

            $S2 {
                a() {
                    -> "a" $S1
                    return
                }
                b() {
                    -> "b" $S3
                    return
                }
            }
            
            $S3 {}
    }

.. image:: images/no_parent.png

Above we see a simple system with three states. States **$S1** and **$S2** share the common behavior 
of **b() { -> "b" $S3 return }**. To eliminate the redundancy, we will 
create a new parent state and refactor the common behavior into it. 

.. code-block::
    :caption: Hierarchical State Machine

    system HSM1 {

        interface:
            a()
            b()

        machine:
            $S0 {
                b() {
                    -> "b" $S3
                    return
                }
            }

            $S1 => $S0 {
                a() {
                    -> "a" $S2
                    return
                }
            }

            $S2 => $S0 {
                a() {
                    -> "a" $S1
                    return
                }
            }
            
            $S3 {}
    }

.. image:: images/hsm_with_parent.png
    :height: 500


Supporting the HSM architecture is one of the primary reasons the Frame runtime is event based which 
makes the capability straightforward to implement. 

Event Handler Parent Dispatch (=> $^)
+++++++++++

By default and by design, unhandled events such as **b** in states **$S1** and **$S2** in the example above pass 
through to the parent state **$S0**. In some circumstances, however, it is desirable to execute 
behavior in both the child and the parent. To facilitate this capability, event handlers can use 
the parent dispatch statement **=> $^**. After executing all statements in the child event handler,
the parent dispatch statement passes the event to the parent for processing and then returns. 

.. code-block::
    :caption: Event Handler Parent Dispatch

    fn main() {
        var sys = ParentDispatchDemo()
        sys.passMe1()
        sys.passMe2()
    }

    system ParentDispatchDemo {

        interface:
            passMe1()
            passMe2()

        machine:
            // Dispatch operator (=>) defines state hierarchy

            $Child => $Parent {
                // Parent dispatch (=> $^) sends events to $Parent

                passMe1() {
                    => $^
                }
                passMe2() {
                    print("handled in $Child")
                    => $^
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

Above we see two scenarios in the **$Child** state. In the **passMe1()** event handler, the event 
is immediately dispatched to the **$Parent** state. In the **passMe2()** event handler 
a print statement is executed first and then the event is dispatched to the **$Parent** for 
further processing. 

Run the `program <https://onlinegdb.com/l7WBIHtd7>`_. 

.. code-block::
    :caption: Event Handler Parent Dispatch Output

    handled in $Parent
    handled in $Child
    handled in $Parent


A final example demonstrates that enter and exit messages obey the same rules as other events.

.. code-block::
    :caption: Parent Child Enter Exit Demo

    fn main() {
        var sys = ParentChildEnterExitDemo()
        sys.next()
        sys.next()   
    }

    system ParentChildEnterExitDemo {

        interface:
            next()

        machine:
            // Dispatch operator (=>) defines state hierarchy

            $Child1 => $Parent {
                $>() {
                    print("enter handled in $Child1")
                    => $^
                }
                <$() {
                    print("exit handled in $Child1")
                    => $^
                }

                next() {
                    -> $Child2
                    return
                }
            }

            $Child2 => $Parent {
                $>() {
                    print("enter handled in $Child2")
                    => $^
                }
                <$() {
                    print("exit handled in $Child2")
                    => $^
                }

                next() {
                    -> $Child1
                    return
                }   
            }

            $Parent {
                $>() {
                    print("enter handled in $Parent")
                    return
                }
                <$() {
                    print("exit handled in $Parent")
                    return
                }
            }
    }


Run the `program <https://onlinegdb.com/KFVFsIXav>`_. 

.. code-block::
    :caption: Parent Child Enter Exit Demo Output

    enter handled in $Child1
    enter handled in $Parent
    exit handled in $Child1
    exit handled in $Parent
    enter handled in $Child2
    enter handled in $Parent
    exit handled in $Child2
    exit handled in $Parent
    enter handled in $Child1
    enter handled in $Parent
