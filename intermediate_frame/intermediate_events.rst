
Enter and Exit Events 
---------------------

As we have seen, one way events are created in a system controller is by the interface. In addition to 
the interface, the system controller runtime sends it's own special events when transitioning between states. 

When entering a state, the controller runtime sends the state an **enter event**. Likewise, when 
leaving a state, the runtime sends an **exit event**. To support this behavior, Frame has two 
special reserved message tokens for enter and exit events:

.. _system_events:

============== ===========
Message Symbol Meaning
============== ===========
>              Enter state event
<              Exit state event 
============== ===========

Here is a state supporting handling enter and exit events:


.. code-block:: Enter and Exit events 

    $S0 
        |>| print("Entered state $S0.") ^
        |<| print("Exited state $S0") ^


Frame Notation for Accessing a Frame Event and Its Members
---------------------

Frame notation enables access to all parts of a Frame Event. We will not go into detail about 
its use here but later articles will provide more in depth discussion on how to access and 
manipulate FrameEvents.

Frame notation uses the `@` symbol to identify a FrameEvent. Each of the three
FrameEvent attributes has its own accessor symbol as well:

.. list-table:: Frame Event Syntax
    :widths: 25 25
    :header-rows: 1

    * - Symbol
      - Meaning/Usage
    * - @
      - frameEvent
    * - @||
      - frameEvent._message
    * - @[]
      - frameEvent._parameters
    * - @[“foo”]
      - frameEvent._parameters[“foo”]
    * - ^(value)
      - frameEvent._return = value; return;
