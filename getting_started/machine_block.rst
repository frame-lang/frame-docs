=============
Machine Block
=============

The Machine Block is the heart of the system and contains the system's state
machine. A state machine is simply a set of logical states the system can be in 
and the behavior each state has in response to events.  

States
------

States can only be defined inside the Machine Block and are indicated by a **$** prefix in front of an
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


We now have three states - **$Hello**, **$World** and **$Done**, but how are they used to actually 
generate the classic "Hello World" message announcing a new programming language? Let's start 
at the beginning - the **start state**. 

Start State
^^^^^^^^^^^

By definition, state machines always have a single designated
**start state** the system is in upon creation (and before initalization).
Not surprsingly, Frame defines the 
start state as first state in a system spec. For our system that is **$Hello**. 

So our system has a start state dedicated to "Hello", which, despite possibly seeming excessive, at least 
has the virtue of making the intent very well defined. But how in the world will we ever get to "World"? 
Let's learn next about event handlers to find out. 

Event Handlers
--------------

System behavior is contained in Frame **event handlers**. Event handlers have three parts: 

#. a message selector 
#. an optional body of statements 
#. a return token

.. code-block::
    :caption: An Event Handler

    ...

    -machine-

    $Hello
        |sayHello|  // select "sayHello" event
            ^       // return

    ...

    ##

As we can see above, a message selector is a message name enclosed in pipe characters - **|sayHello|**. 
In this event handler there are no statements - it simply returns using the return token **^**. We will
address printing in the next article. 

Event handlers contain the 
code for the behavior that should be executed in response to an event. The simplest event handlers 
simply select the event and then return:
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

The **->** operator is used to transition from the current state to the target state, in this case **$World**. 
In turn the **$World** state transitions to the **$Done** state upon recieving the **|sayWorld|** event. 


.. code-block::
    :caption: Transitions
 
    #HelloWorldSystem

        -interface-
        
        sayHello 
        sayWorld

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

    ##

So now our machine will transition to all the required states but won't actually print anything. 
Although we *could* just print directly using Python's **print()** function, 
we will take the opportunity to introduce Frame **actions** which we will introduce in the next article.

