============
Frame Events
============

Frame is an event driven architecture. While developers are used to events as part 
of frameworks or operating systems, it is uncommon to use events internally to an object.

Frame "systems" are (for now) implemented as object-oriented classes known as "system controllers". 
Two of the key structural aspects of system controllers are the public interface and a state machine comprised of 
one or more states. To enable communication between the interface and the state machine, Frame 
uses FrameEvents.

FrameEvents provide three necessary functions:

#. Encode what message was sent to the system. By default this is the name of the interface method called.
#. Store the parameters sent in the call.
#. Return a value to the caller, if required.

To support these requirements, Frame defines three fields for a Frame Event:

#. A message 
#. A dictionary of zero or more parameters
#. A return object


Here is a basic implementation of the FrameEvent class for Python:

.. code-block::
    :caption: FrameEvent in Python

    class FrameEvent:
      def __init__(self, message, parameters):
          self._message = message
          self._parameters = parameters
          self._return = None

To be precise about terminology, an "event" is an instance of a **FrameEvent** class type while the "message" is the 
data field on the event. However events will often be referred to as a type, but what we really 
are referring to is the message value. For instance the **foo** interface method will not send 
a **FooEvent** but will, instead, send a **FrameEvent** with "foo" as the message. 

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
    * - @^
      - frameEvent._return
    * - ^(value)
      - frameEvent._return = value; return;

Later articles will provide more in depth discussion on how to access and 
manipulate FrameEvents.