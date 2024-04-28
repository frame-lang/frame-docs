============
Frame Events
============

Frame is an event driven architecture. While developers are used to events as part 
of frameworks or operating systems, it is uncommon to use events internally to an object.

Frame "systems" are (for now) implemented as object-oriented classes known as "system controllers". 
Two of the key structural aspects of system controllers are the public interface and a state machine comprised of 
one or more states. To enable communication between the interface and the state machine, Frame 
uses **FrameEvents**.

FrameEvents perform three necessary functions:

#. Encode what message was sent to the system. By default this is the name of the interface method called.
#. Store any parameters passed in the call.

To support these requirements, Frame defines three fields for a Frame Event:

#. A message 
#. A dictionary of zero or more parameters

Here is a basic implementation of the FrameEvent class for Python:

.. code-block::
    :caption: FrameEvent in Python

    class FrameEvent:
      def __init__(self, message, parameters):
          self._message = message
          self._parameters = parameters

To be precise about terminology, an "event" is an instance of a **FrameEvent** class type while the "message" is the 
data field on the event. However events will often be referred to as a type, but what we really 
are referring to is the message value. For instance the **foo** interface method will not send 
a **FooEvent** but will, instead, send a **FrameEvent** with "foo" as the message. 


