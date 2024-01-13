==================
Interface Block
==================

As implied by its name, the **Interface Block** contains the means by which the outside world
interacts with the system. 

The detailed syntax for interface methods and other callable routines is covered in the `methods`_ section.
The most basic interface method has no parameters and no return values:

.. code-block::

    #HelloWorldSystem

    -interface-

    sayHello
    sayWorld

    ##

Above we see our system now can be called to **sayHello** and **sayWorld**. However,  
unlike other languages, Frame decisvely separates interface from behavior. Therefore these 
inteface methods can't be programmed to actually execute those instructions. 

Instead, interface methods are designed to interact with the rest of the system by 
creating messages and sending them to the internal state machine. It is the job of the 
state machine (or for simplicity just "the machine") to route these interface events 
to the behavior they are intended to drive. 

We will take a look at these events in detail next. 

