The Frame Runtime
============

Frame supports a highly specialized set of capabilities related to Frame's first class entitites - states and events. 


Frame syntax is enabled by the code generated Frame runtime code needed to implement the following capabilities:

#. System intitialization
#. Event creation
#. Event routing
#. Event forwarding
#. Transitions 
#. State history
#. Services


Frame Runtime Architecture 
--------------------------

Frame states have two aspects - 

#. the state method that contains the code for the state
#. state compartments which contain all the data for a particular instance of a state

Let's explore the details of the compartment data next. 

State Compartments 
------------

Most of Frame's advanced capabilities stem from langauge support for **State Compartments**. A compartment 
is a data structure containing the following data:

#. The name of the state method the compartment relates to
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


Frame maintains two core references to compartents to make the architecture work:

#. A reference to the current state (self.__compartment) 
#. A reference to the next state to transition to (self.__next_compartment)

The **__next_compartment** variable is only set while executing a transition and is otherwise unset. 

.. code-block::
    :caption: Compartment References 

        self.__compartment: 'Runtime2Compartment' = Runtime2Compartment(self.__state)
        self.__next_compartment: 'Runtime2Compartment' = None

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
previous runtime implementations) then the stack would quickly blow up with repeated transitions that did not 
fully pop the stack by returning to the caller.

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

Transition Parameters 
---------------------

The demo below shows how enter, exit and state parameters are implemented using the same basic pattern 
as before. A **Runtime2** system is instantiated and then its next interface method is called. 

.. code-block::
    :caption: todo 

    fn main {
        var runtime_demo:# = #Runtime2()
        runtime_demo.next(1,2,3)
    }

    #Runtime2

        -interface-

        next [a,b,c]

        -machine-

        $S0 
            |<| [a] 
                print("a=" + str(a), end="") ^

            |next| [a,b,c]
                (a) -> (b) $S1(c) ^

        $S1 [c]
            |>| [b]
                print("; b=" + str(b) + "; c=" + str(c)) ^

    ##  

The **next()** interface method recieves three arguments which are added to a FrameEvent as parameters
and passed to the kernel.

.. code-block::
    :caption: todo 

    def next(self,a,b,c):
        parameters = {}
        parameters["a"] = a
        parameters["b"] = b
        parameters["c"] = c
        e = FrameEvent("next",parameters)
        self.__kernel(e)

The **next** event handler is then executed and the a,b,c parameters are distributed respectively to 
the exit parameters to the current state compartment and the enter arguments and the state arguments 
to the next state compartment. The deferred transition is then set and subsequently control is passed back to 
the router and then the kernel methods.   

.. code-block::
    :caption: todo 

    # ----------------------------------------
    # $S0
    
    def __runtime2_state_S0(self, e):
        if e._message == "<":
            print("a=" + str(e._parameters["a"]),end = "")
            return
        elif e._message == "next":
            self.__compartment.exit_args["a"] = e._parameters["a"]
            compartment = Runtime2Compartment('__runtime2_state_S1')
            compartment.enter_args["b"] = e._parameters["b"]
            compartment.state_args["c"] = e._parameters["c"]
            self.__transition(compartment)
            return   

As we can see, the event handlers contain the code initializing the compartment and transition that will actually execute in 
the kernel. The event handlers also contain the exit event handler code triggered from the kernel:

.. code-block::
    :caption: Kernel Exit Event Handler Call 

    
    # ==================== System Runtime =================== #
    
    def __kernel(self, e):

        ...

        # exit current state
        self.__router(FrameEvent( "<", self.__compartment.exit_args))
        # change state
        self.__compartment = next_compartment

                
.. code-block::
    :caption: $S1 Frame Code 

        $S1 [c]
            |>| [b]
                print("; b=" + str(b) + "; c=" + str(c)) ^

.. code-block::
    :caption: $S1 Python Code 

    # ----------------------------------------
    # $S1
    
    def __runtime2_state_S1(self, e):
        if e._message == ">":
            print("; b=" + str(e._parameters["b"]) + "; c=" + str((self.__compartment.state_args["c"])))
            return

Event Forwarding Runtime Support
-----------

The Frame event forwarding mechanism provides the ability to recieve an event in one state and 
then pass it to another state to handle. Below we see a simple example where state **$S0** recieves 
the **next** event and simply forwards it to state **$S1** to handle and print.

.. code-block::
    :caption: Event Forwarding Demo

    fn main {
        var runtime_demo:# = #Runtime3()
        runtime_demo.next(1,2,3)
    }

    #Runtime3

        -interface-

        next [a,b,c]

        -machine-

        $S0 
            |next| [a,b,c]
                -> => $S1 ^

        $S1
            |next| [a,b,c]
                print("a=" + str(a) + "; b=" + str(b) + "; c=" + str(c)) ^


Frame enables this capability by utilizing a special **forward_event** attribute on compartments 
to store a reference to the event that should be forwarded:

.. code-block::
    :caption: Event Forwarding Code in Originating State

    # ----------------------------------------
    # $S0
    
    def __runtime3_state_S0(self, e):
        if e._message == "next":
            compartment = Runtime3Compartment('__runtime3_state_S1')
            compartment.forward_event = e
            self.__transition(compartment)
            return

In the kernel logic for a transition a test is performed for the existence of a forwarded event. 
If there isn't one then the kernel sends an enter event along with the enter parameters. 

If there was a forwarded event then the kernel takes two different paths depending on if 
the forwarded event was an enter event or not. If it is it then it is simply passed to the router. If 
it is some other event type then the kernel logic sends a new enter event to the router first and then 
follows it with the forwarded event. The important aspect to the logic is that in all code paths the kernel 
makes sure the new state receives an enter event, whether forwarded or newly created.

.. code-block::
    :caption: Event Forwarding Code in Kernel

    def __kernel(self, e):
        
        ...

        # loop until no transitions occur
        while self.__next_compartment != None:

        ...

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

This completes our exploration of the kernel aspect to the runtime. Next we will take a look at system instantiation 
and how system parameters are intialized.  


System Initalization
-----------

There are three aspects of system startup that are parameterized and can be externally initalizaed:

#. Start state parameters
#. Start state enter event parameters 
#. Domain variables

.. code-block::
    :caption: System Initalization Parameters

    fn main {
        #Runtime4($(1), >(2), #(3))
    }

    #Runtime4 [$[a], >[b], #[c]]

        -machine-

        $S0 [a] 
            |>| [b]
                print("a=" + str(a) + "; b=" + str(b) + "; c=" + str(c)) ^

        -domain-

        var c = nil
    ##

Above we see that each aspect of the system is intialized with one argument. The system factory (__init__([...])) handles all of 
the logic for setting the start state parameters and domain variables:


.. code-block::
    :caption: System Initalization Parameters

    def main():
        Runtime4(1,2,3)

    class Runtime4:
        
        
        # ==================== System Factory =================== #
        
        def __init__(self,start_state_state_param_a,start_state_enter_param_b,domain_param_c):
            
            # Create and intialize start state compartment.
            
            self.__compartment: 'Runtime4Compartment' = Runtime4Compartment('__runtime4_state_S0')
            self.__next_compartment: 'Runtime4Compartment' = None
            self.__compartment.state_args["a"] = start_state_state_param_a
            self.__compartment.enter_args["b"] = start_state_enter_param_b
            
            # Initialize domain
            
            self.c  = domain_param_c
            
            # Send system start event
            frame_event = FrameEvent(">", self.__compartment.enter_args)
            self.__kernel(frame_event)
        
        # ===================== Machine Block =================== #
        
        # ----------------------------------------
        # $S0
        
        def __runtime4_state_S0(self, e):
            if e._message == ">":
                print("a=" + str((self.__compartment.state_args["a"])) + "; b=" + str(e._parameters["b"]) + "; c=" + str(self.c))
                return
    
    ...

We can see above how the start state can access all of the initialized parameters on the compartment as well as the domain.

History State Stack
-----------

.. code-block::
    :caption: State Stack Demo

    fn main {
        var ss:# = #StateStack()
        ss.next()
        ss.next()
        ss.ret()
        ss.ret()
    }
    
    #StateStack

        -interface-

        next
        ret

        -machine-

            $A
                |>| print("$A") ^
                |next| $$[+] -> "$$[+]" $B ^

            $B
                |>| print("$B") ^
                |next| $$[+] -> "$$[+]" $C ^
                |ret| -> "$$[-]" $$[-] ^

            $C
                |>| print("$C") ^
                |ret| -> "$$[-]" $$[-] ^

    ##


.. code-block::
    :caption: State Stack Demo Output 

    $A
    $B
    $C
    $B
    $A

The system mechanisms for accomplishing this capability are first to create a **self.__state_stack** array during 
system initialization. Then, when transitioning from a state that will be returned to later, push the 
current compartment on the state stack before the transition: 

.. code-block::
    :caption: State Stack Push and Transition

    self.__state_stack_push(self.__compartment)
    compartment = StateStackCompartment('__statestack_state_C')
    self.__transition(compartment)


.. code-block::
    :caption: State Stack Pop and Return

    compartment = self.__state_stack_pop()
    self.__transition(compartment)

Focusing on state **$B** here is what these mechanics looks like in context: 

.. code-block::
    :caption: State Stack Demo Listing

    ...

    class StateStack:
        
        
        # ==================== System Factory =================== #
        
        def __init__(self):
            
            # Create state stack.
            
            self.__state_stack = []
            
        ...
      
        # ===================== Machine Block =================== #
      
        ...

        # ----------------------------------------
        # $B
        
        def __statestack_state_B(self, __e):
            if __e._message == ">":
                print("$B")
                return
            elif __e._message == "next":
                self.__state_stack_push(self.__compartment)
                # $$[+]
                compartment = StateStackCompartment('__statestack_state_C')
                self.__transition(compartment)
                return
            elif __e._message == "ret":
                # $$[-]
                compartment = self.__state_stack_pop()
                self.__transition(compartment)
                return
        
        ...

        # ==================== System Runtime =================== #
        
        ...

        def __state_stack_push(self, compartment: 'StateStackCompartment'):
            self.__state_stack.append(compartment)
        
        def __state_stack_pop(self):
            return self.__state_stack.pop()
        


        
    