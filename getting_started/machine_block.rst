=============
Machine Block
=============

The Machine Block is the heart of the system and contains the system's state
machine. A state machine is simply a set of logical states the system can be in 
and the behavior each state has in response to events.  

States
------

States can only be defined inside the Machine Block and are indicated by a `$` prefix in front of an
identifier. Let's add three states to our machine to give structure to our "Hello World!" program. 

.. code-block::
    :caption: A Three State Hello World System 

    #HelloWorldSystem

        -interface-
        
        sayHello 
        sayWorld

        -machine-

        $Hello

        $World

        $Done

    ##


We now have three states, but no way to actually generate "Hello World!" yet. We need to learn a few 
key concepts about states before we can do that. 

Start State
^^^^^^^^^^^

We now have three states, but which state is the machine in when it is instantiated? Not surprisingly 
 there is always a designated
**start state** for a machine. Frame defines the very first state in the spec as the **start state**, 
which in
this case is `$Hello`. 

So now we know the machine has a whole state dedicated to the job of saying "Hello". But how in the world 
will we ever say "World"? 

Event Handlers
--------------

To make a state do something, it needs to be sent an event. States do not usually handle every event 
that the interface sends so they need a way to be selective. 

In the **$Hello** state, we are only interested in the event **sayHello**. The Frame syntax for 
selecting messages is to match the string inside of the pipe tokens like `|msg|`.

The message selector is the first part of an **event handler**. Event handlers contain the 
code for the behavior that should be executed in response to an event. The simplest event handlers 
simply select the event and then return:

.. code-block::
    :caption: An Event Handler
    ...

    -machine-

    $Hello
        |sayHello|  // select "sayHello" event
            ^       // return

    ...

    ##

This is useful in some advanced situations, but not in this case. The first problem 
is that we will never handled the "sayWorld" message. To deal with that we need 
a mechanism to **transition** between states. Let's look at how to do that next.

Transitions
-----------

The most defining aspect of a state machine is that it doesn't stay in just one state. 
In order to go to a different state we will use a transition to get to `$World`. 

.. code-block::
    :caption: A Transition
    ...

    -machine-

    $Hello
        |sayHello|  
            -> $World // Transition to $World state
            ^       
    $World    

    ...

The `->` token is used to transition from the current state to the target state, in this case `$World`. 
`$World` still doesn't do anything but we will fix that next. 


.. code-block::
    :caption: A Transition
    ...

    -machine-

    $Hello
        |sayHello|  
            -> $World // Transition to $World state
            ^       
    $World    
        |sayWorld|  
            -> $Done // Transition to $Done state
            ^     

    $Done 
    ...

So now our machine will transition to all the required states but won't actually print anything. 
To accomplish that we need actions which we will introduce in the next article.

