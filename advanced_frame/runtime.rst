The Frame Runtime
============

Frame supports a highly specialized set of capabilities related to Frame's first class entitites 
- states and events. 
Frame syntax is enabled by the code generated Frame runtime code needed to implement the following capabilities:

#. System intitialization
#. Event creation
#. Event routing
#. Event forwarding
#. Transitions 
#. State history
#. Services

State Compartments 
------------

Most of Frame's advanced capabilities stem from langauge support for **State Compartments**. A compartment 
is a data structure containing the following data:

#. The name of the type of state the compartment relates to
#. The state argugments
#. The state local variables 
#. The enter event arguments 
#. The exit event arguments 
#. A reference to any forwarded event

.. code-block::
    :caption: Compartment Data 

    # ===================== Compartment =================== #

    class Runtime0Compartment:

        def __init__(self,state):
            self.state = state
            self.state_args = {}
            self.state_vars = {}
            self.enter_args = {}
            self.exit_args = {}
            self.forward_event = None

Let's explore each of these aspects, starting with how state compartments are used during system initialization. 

State Compartments and System Initialization
-------------------------------

To begin our exploration of the runtime we will begin with a trivial one state system that simply prints 
a message on startup.

.. code-block::
    :caption: todo 

    fn main {
        var runtime_demo:# = #Runtime0()
    }

    #Runtime0

        -machine-

        $S0 
            |>|
                print("Hello from the Runtime") ^

    ##

First, the program generates a **main()** function and calls it where our **Runtime0()** instance 
is instantiated. 
         
.. code-block::
    :caption: todo 


    def main():
        runtime_demo = Runtime0()

    ...

    if __name__ == '__main__':
        main()

The **__init__()** method for the system does the following:

#. Create and initialize the start state compartment 
#. Initalize all system domain variables 
#. Create an enter event and send to the system start state

 .. code-block::
    :caption: todo 

    # ==================== System Factory =================== #
    
    def __init__(self):
        
         # Create and intialize start state compartment.
        
        self.__compartment: 'Runtime0Compartment' = Runtime0Compartment('__runtime0_state_S0')
        self.__next_compartment: 'Runtime0Compartment' = None
        
        # Initialize domain
        
        self.msg  = "Hello from the Runtime!"
        
        # Send system start event
        frame_event = FrameEvent(">", None)
        self.__kernel(frame_event)
    

The last step leads us into the heart of the system runtime - the **kernel**. 

The Kernel 
++++++++++

Despite looking complex, at a high level the kernel performs only two main tasks:

#. Route events to the current state 
#. Execute a transition if one was prepared while handling the event

For step one, the kernel sends the event to the **__router()** method, which is simply a 
block of tests to determine the current state and foward event to it. In this demo 
there is only one state ($S0):
         
.. code-block::
    :caption: todo 

    # ==================== System Runtime =================== #
    
    def __kernel(self, e):
        
        # send event to current state
        self.__router(e)

        ...

    
    def __router(self, e):
        if self.__compartment.state == '__runtime0_state_S0':
            self.__runtime0_state_S0(e)

The state is trivial and simply prints the message:

.. code-block::
    :caption: Frame code 

    -machine-

    $S0 
        |>|
            print(msg) ^

This Frame code results in the following code generated for the **$S0** state: 

.. code-block::
    :caption: Generated Python code for a State

    # ----------------------------------------
    # $S0
    
    def __runtime0_state_S0(self, e):
        if e._message == ">":
            print(self.msg)
            return

Each state method contains zero or more event handlers. In this demo, only one event handler exists for the 
enter message. 

We have quickly explored the simplest path through the runtime architecture with one state and one event handler. 
Next we will explore the complexity introduced by Frame's support of transitions. 

Runtime Transition Support 
--------------------------
        
Full support of Frame transition semantics requires a complex runtime infrastructure. The full set of possible
activity for a single transition is: 

#. Create a compartment for the next state 
#. On the compartment, set any parameter values for the transition (transition exit and enter parameters)
#. On the compartment, set any state parameters
#. On the compartment, initialize any state variables
#. Call the **transition(next_compartment)** method, which simply saves a reference to the new compartment for later use
#. Return from the event handler to the kernel routine
#. The kernel detects if a compartment was set to transition to and loops until no more transitions happen
#. Send an exit event to the current transition
#. Change state by setting the new compartment as the current state 
#. Send an enter event to the new state or forward any forwarded event

That is a lot of steps for a transition! The complexity is required to support the following language requirements:

#. Sending enter and exit events 
#. Initalizing exit and enter handler parameters 
#. Intializing state parameters 
#. Event forwarding  
#. Enabling services (long running autonomous programs)

Let's take a look at the code for each of these steps.

Basic Transition Runtime Support 
----------------

Let's start with the simplest transition example possible:

.. code-block::
    :caption: todo 

    fn main {
        var runtime_demo:# = #Runtime1()
        runtime_demo.next()
    }

    #Runtime1

        -interface-

        next

        -machine-

        $S0 
            |next| -> $S1 ^

        $S1 

    ##

In the demo above, there is one transition from **$S0** to **$S1**. Below we see the code for **$S0** 
which instantiates a new state compartment, initializes it with the name of the target state and 
then starts a transition. 

Calling the **next** interface method executes a transition with the folliwng call stack configuration:

#. The next method 
#. The kernel method
#. The router method
#. The state $S0 method
#. Transition method

Let's take a look at the state and transition for the details of how the transition is effected. Below we 
see a new compartment is created and initialized for **$S1** and then passed to **self.__transition(compartment)**:

.. code-block::
    :caption: todo 

    # ----------------------------------------
    # $S0
    
    def __runtime1_state_S0(self, e):
        if e._message == "next":
            compartment = Runtime1Compartment('__runtime1_state_S1')
            self.__transition(compartment)
            return

    ...

    def __transition(self, compartment: 'Runtime1Compartment'):
        self.__next_compartment = compartment


Notice that rather than 
immediately updating the  **self.__compartment** variable (which references the current state compartment), Frame 
instead caches off the new compartment and returns. This approach *defers* the transition execution 
for the kernel to handle. This approach, though complex, enbles Frame to support long running services
that continually transition upon entry to a new state. If this approach was not taken (as was the case in 
previous runtime implementations) then the stack would quickly blow up with repeated transitions.

When **$S0** returns to the kernel from the **self.__router(e)** call, it then enters a loop testing 
if there is a **self__next_compartment** to transition to:

.. code-block::
    :caption: todo 

    def __kernel(self, e):
        
        # send event to current state
        self.__router(e)
        
        # loop until no transitions occur
        while self.__next_compartment != None:
            next_compartment = self.__next_compartment
            self.__next_compartment = None

If it does transition, then it gets a local reference to the cached compartment and clears the cached reference.
The next step is to send an exit event to the current state and update the current state to the new one:

.. code-block::
    :caption: todo 

    # exit current state
    self.__router(FrameEvent( "<", self.__compartment.exit_args))
    # change state
    self.__compartment = next_compartment

Finally, the kernel takes care of handling a forwarded event. As we aren't forwarding 
one, only this section applies to our demo: 

.. code-block::
    :caption: todo 

    if next_compartment.forward_event is None:
        # send normal enter event
        self.__router(FrameEvent(">", self.__compartment.enter_args))


The code above simply creates and sends an enter event to the new state, passing any enter event 
args stored on the compartment. As we didn't pass any enter arguments on our transition, that value will
be None for this demo. 

Here is the full runtime code listing for this system:


.. code-block::
    :caption: todo 

     class FrameEvent:
        def __init__(self, message, parameters):
            self._message = message
            self._parameters = parameters
            self._return = None

    def main():
        runtime_demo = Runtime1()
        runtime_demo.next()

    class Runtime1:
        
        
        # ==================== System Factory =================== #
        
        def __init__(self):
            
            # Create and intialize start state compartment.
            
            self.__state = '__runtime1_state_S0'
            self.__compartment: 'Runtime1Compartment' = Runtime1Compartment(self.__state)
            self.__next_compartment: 'Runtime1Compartment' = None
            
            # Initialize domain
            
            # Send system start event
            frame_event = FrameEvent(">", None)
            self.__kernel(frame_event)
        
        # ==================== Interface Block ================== #
        
        def next(self,):
            e = FrameEvent("next",None)
            self.__kernel(e)
        
        # ===================== Machine Block =================== #
        
        # ----------------------------------------
        # $S0
        
        def __runtime1_state_S0(self, e):
            if e._message == "next":
                compartment = Runtime1Compartment('__runtime1_state_S1')
                self.__transition(compartment)
                return
        
        # ----------------------------------------
        # $S1
        
        def __runtime1_state_S1(self, e):
            pass
                   
        # ==================== System Runtime =================== #
        
        def __kernel(self, e):
            
            # send event to current state
            self.__router(e)
            
            # loop until no transitions occur
            while self.__next_compartment != None:
                next_compartment = self.__next_compartment
                self.__next_compartment = None
                
                # exit current state
                self.__router(FrameEvent( "<", self.__compartment.exit_args))
                # change state
                self.__compartment = next_compartment
                
                if next_compartment.forward_event is None:
                    # send normal enter event
                    self.__router(FrameEvent(">", self.__compartment.enter_args))
                else: # there is a forwarded event
                    if next_compartment.forward_event._message == ">":
                        # forwarded event is enter event
                        self.__router(next_compartment.forward_event)
                    else:
                        # forwarded event is not enter event
                        # send normal enter event
                        self.__router(FrameEvent(">", self.__compartment.enter_args))
                        # and now forward event to new, intialized state
                        self.__router(next_compartment.forward_event)
                    next_compartment.forward_event = None
                    
        
        def __router(self, e):
            if self.__compartment.state == '__runtime1_state_S0':
                self.__runtime1_state_S0(e)
            elif self.__compartment.state == '__runtime1_state_S1':
                self.__runtime1_state_S1(e)
            
        def __transition(self, compartment: 'Runtime1Compartment'):
            self.__next_compartment = compartment
        

    # ===================== Compartment =================== #

    class Runtime1Compartment:

        def __init__(self,state):
            self.state = state
            self.state_args = {}
            self.state_vars = {}
            self.enter_args = {}
            self.exit_args = {}
            self.forward_event = None
        
    if __name__ == '__main__':
        main()


        

Event Forwarding
-----------

Transitions are effected by a two step process:

History State Stack
-----------




    