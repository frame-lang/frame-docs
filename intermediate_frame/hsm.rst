===========================
Hierarchical State Machines
===========================

Frame supports the notion of states inheriting behavior from other states. In doing so, 
a system develops a hierarchy of parent-child relationships between states. A state machine 
that supports hierarchy is known as a **Hierarchical State Machine (HSM)**.

Hierarchy is useful for factoring common behavior between states into a parent, thus normalizing
the implemenation of behavior and eliminating redundancy in the system. In an HSM, when  
changes are made to the shared behavior there is a single place to make the modification. 

.. code-block::
    :caption: Flat State Machine

    #FlatStateMachine

        -interface-

        a 
        b
        
        -machine-

        $S1 
            |a| -> "a" $S2 ^
            |b| -> "b" $S3 ^

        $S2 
            |a| -> "a" $S1 ^
            |b| -> "b" $S3 ^
            
        $S3

    ##

.. image:: images/no_parent.png

Above we see a simple system with three states. States **$S1** and **$S2** share the common behavior 
of **|b| -> "b" $S3 ^**. To eliminate the redundancy, we will 
create a new parent state and refactor the common behavior into it. 

.. code-block::
    :caption: Hierarchical State Machine

    #HSM1

        -interface-

        a 
        b

        -machine-

        $S0 
            |b| -> "b" $S3 ^

        $S1 => $S0
            |a| -> "a" $S2 ^

        $S2 => $S0
            |a| -> "a" $S1 ^
            
        $S3
    ##

.. image:: images/hsm_with_parent.png

Event Handler Continue Terminator
+++++++++++

As previously mentioned, event handlers are also able to be terminated with a continue operator **:>**. In later 
articles we will discuss **Hierarchical State Machines (HSMs)** in depth. HSMs enable states to inherit behavior 
from other states and are created using the Frame *Dispatch Operator* **=>**. 
While unhandled events are automatically passed to parent states, the continue operator enables 
handled event to be passed to a parent state as well:

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


.. code-block::
    :caption: Event Handler Continue Terminator Output

    handled in $Parent
    handled in $Child
    handled in $Parent