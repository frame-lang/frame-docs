The Frame Runtime
============

Frame is a highly opinionated language focused on the semantics of its first class entities - 
systems, states and events. These entities have special runtime code related to the following 
capabilities they support: 

#. System initialization
#. Event creation
#. Event routing
#. Event forwarding
#. Transitions 
#. State history
#. Services

This article will discuss these capabilities in depth and explore their implementation in Python. 

Frame Runtime Architecture 
--------------------------

At the heart of each Frame system is a state machine comprised of one or more states. This fact makes
the architecture of Frame states a defining aspect to the runtime implementation. For object-oriented languages 
Frame's code generator implements Frame systems, not surprisingly, as object-oriented classes. 

Frame makes a deliberate choice regarding how to implement states, as there are many possible approaches. 
In the current implementation, Frame states possess two defining aspects. 

#. state *functionality* is defined in a class method that contains the code for that *type* of state
#. state *data* is contained in compartments which contain all the data for a particular *instance* of a state

Let's explore the details of the compartment data next. 

State Compartments 
------------

Most of Frame's advanced capabilities stem from language support for **State Compartments**. A compartment 
is a data structure containing the following data:

#. The name of the state method the compartment relates to
#. The state arguments
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


Frame maintains two core references to compartments to make the architecture work:

#. A reference to the current state (self.__compartment) 
#. A reference to the next state to transition to (self.__next_compartment)

The **__next_compartment** variable is only set while the system is in the process of executing a transition. 

.. code-block::
    :caption: System Runtime Compartment References 

    self.__compartment: 'Runtime0Compartment' = Runtime0Compartment('__runtime0_state_S0')
    self.__next_compartment: 'Runtime0Compartment' = None


Let's explore each of these aspects, starting with how state compartments are used during system initialization. 

State Compartments and System Initialization
-------------------------------

To begin our exploration of the runtime we will examine a trivial one state system that simply prints 
a message on startup.

.. code-block::
    :caption: Runtime0 Listing 

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
    :caption: Runtime0 Demo Main Code 


    def main():
        runtime_demo = Runtime0()

    ...

    if __name__ == '__main__':
        main()

The **__init__()** method for the **Runtime0** system does the following:

#. Create and initialize the start state compartment 
#. Initialize all system domain variables 
#. Create an enter event and send to the system start state

 .. code-block::
    :caption: Runtime0 Demo System Factory Code 

    class Runtime0:
        
        # ==================== System Factory =================== #
        
        def __init__(self):
            
            # Create and initialize start state compartment.
            
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

Despite it's apparent complexity, the kernel performs only two main high level tasks:

#. Route events to the current state 
#. Execute a transition if one was prepared while handling the event

For step one, the kernel sends the event to the **__router()** method, which is simply a 
block of tests to determine the current state and pass the event to it. In this demo 
there is only one state ($S0) so this code is trivial:
         
.. code-block::
    :caption: Kernel Router 

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
    :caption: Generated Python code for State $S0

    # ----------------------------------------
    # $S0
    
    def __runtime0_state_S0(self, e):
        if e._message == ">":
            print(self.msg)
            return

Each state method contains zero or more event handlers. In this demo, only one event handler exists to handle the 
enter message. The event handler prints a message declared in the domain and returns.

We have quickly explored the simplest path through the runtime architecture with one state and one event handler. 
Next we will explore the complexity introduced by Frame's support of transitions. 

Runtime Transition Support 
--------------------------
        
Frame transition semantics require a complex runtime infrastructure. The full set of possible
activities during a single transition include: 

#. Create a compartment for the next state 
#. On the next state compartment, set any parameter values for the transition (transition exit and enter parameters)
#. On the next state  compartment, set any state parameters
#. On the next state  compartment, initialize any state variables
#. Call the **transition(next_compartment)** method, which simply saves a reference to the new compartment for later use
#. Return from the event handler to the kernel routine
#. The kernel detects if a next compartment exists and loops until no more transitions happen
#. Send an exit event to the current state
#. Change state by setting the next state compartment to be the current state compartment 
#. Send an enter event to the new state and forward any forwarded event

That is a lot of steps for a transition! The complexity is required in order to support the following 
language requirements:

#. Sending enter and exit events 
#. Initializing exit and enter handler parameters 
#. Initializing state parameters 
#. Event forwarding  
#. Enabling services (long running autonomous programs)

Let's take a look at the code for each of these steps.

Basic Transition Runtime Support 
----------------

Let's start with the simplest transition example possible:

.. code-block::
    :caption: Transition Runtime Support Demo 

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

Calling the **next** interface method triggers a series of calls resulting in the following call stack configuration:

#. The next interface method 
#. The kernel method
#. The router method
#. The state $S0 method

In **$S0** the **next** event handler executes the transition by creating and initializing
a new **$S1** compartment which is then passed to **self.__transition(compartment)**:

.. code-block::
    :caption: Runtime1 Demo $S0 Transition Code 

    # ----------------------------------------
    # $S0
    
    def __runtime1_state_S0(self, __e):
        if __e._message == "next":
            next_compartment = Runtime1Compartment('__runtime1_state_S1')
            self.__transition(next_compartment)
            return

    ...

    def __transition(self, next_compartment: 'Runtime1Compartment'):
        self.__next_compartment = next_compartment


Notice that rather than 
immediately updating the  **self.__compartment** variable (which references the current state compartment), Frame 
caches off the new compartment in a **self.__next_compartment** runtime managed variable and returns. 
This code *defers* the actual transition execution 
so the kernel can handle it rather than the event handler. 

Although complex, this technique is needed to support long running services
that continually transition upon entry to a new state. If this approach was not used the stack would 
eventually blow up with transition calls that did not 
fully pop the stack by returning to the caller. This functionality enables Frame support for long running 
services that continually transition from state to state in their enter event handlers and never 
return to the calling client. 

When **$S0** returns to the kernel from the **self.__router(e)** call, the kernel enters a loop that tests 
for a **self__next_compartment** to transition to:

.. code-block::
    :caption: Kernel Transition Loop  

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
    :caption: Kernel Exit Event and State Change Code

    # exit current state
    self.__router(FrameEvent( "<", self.__compartment.exit_args))
    # change state
    self.__compartment = next_compartment

Finally, the kernel takes care of handling a forwarded event. As we aren't forwarding 
one, only the following code applies to our demo: 

.. code-block::
    :caption: Kernel Enter Event Code 

    if next_compartment.forward_event is None:
        # send normal enter event
        self.__router(FrameEvent(">", self.__compartment.enter_args))


The code above simply creates and sends an enter event to the new state, passing any enter event 
args stored on the compartment. As we didn't pass any enter arguments on our transition, that value will
be None for this demo. 

Here is the full runtime code listing for this system:


.. code-block::
    :caption: Runtime1 System Demo 

        # Emitted from framec_v0.11.0


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
        
         # Create and initialize start state compartment.
        
        self.__compartment: 'Runtime1Compartment' = Runtime1Compartment('__runtime1_state_S0')
        self.__next_compartment: 'Runtime1Compartment' = None
        
        # Initialize domain
        
        # Send system start event
        frame_event = FrameEvent(">", None)
        self.__kernel(frame_event)
    
    # ==================== Interface Block ================== #
    
    def next(self,):
        __e = FrameEvent("next",None)
        self.__kernel(__e)
    
    # ===================== Machine Block =================== #
    
    # ----------------------------------------
    # $S0
    
    def __runtime1_state_S0(self, __e):
        if __e._message == "next":
            next_compartment = Runtime1Compartment('__runtime1_state_S1')
            self.__transition(next_compartment)
            return
    
    # ----------------------------------------
    # $S1
    
    def __runtime1_state_S1(self, __e):
        pass
        
    
    
    # ==================== System Runtime =================== #
    
    def __kernel(self, __e):
        
        # send event to current state
        self.__router(__e)
        
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
                    # and now forward event to new, initialized state
                    self.__router(next_compartment.forward_event)
                next_compartment.forward_event = None
                
    
    def __router(self, __e):
        if self.__compartment.state == '__runtime1_state_S0':
            self.__runtime1_state_S0(__e)
        elif self.__compartment.state == '__runtime1_state_S1':
            self.__runtime1_state_S1(__e)
        
    def __transition(self, next_compartment: 'Runtime1Compartment'):
        self.__next_compartment = next_compartment
    

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
    :caption: Runtime2 Listing

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

The **next()** interface method receives three arguments which are added to a FrameEvent as parameters
and passed to the kernel.

.. code-block::
    :caption: Next Interface Method Code 

    def next(self,a,b,c):
        parameters = {}
        parameters["a"] = a
        parameters["b"] = b
        parameters["c"] = c
        e = FrameEvent("next",parameters)
        self.__kernel(e)

The **next** event handler is then executed where the a,b,c parameters are distributed to 
the exit parameters for the current state and the enter parameters and state parameters 
for the next state. 

.. code-block::
    :caption: $S0 Transition Parameters 

    |next| [a,b,c]
        (a) -> (b) $S1(c) ^

As we can see below, a,b,c are used to set the various transition parameters and
the deferred transition is then created.   

.. code-block::
    :caption: Runtime2 Demo Transition Parameters Code 

    # ----------------------------------------
    # $S0
    
    def __runtime2_state_S0(self, __e):
        if __e._message == "<":
            print("a=" + str(__e._parameters["a"]),end = "")
            return
        elif __e._message == "next":
            self.__compartment.exit_args["a"] = __e._parameters["a"]
            next_compartment = Runtime2Compartment('__runtime2_state_S1')
            next_compartment.enter_args["b"] = __e._parameters["b"]
            next_compartment.state_args["c"] = __e._parameters["c"]
            self.__transition(next_compartment)
            return

    ...

    def __transition(self, next_compartment: 'Runtime2Compartment'):
        self.__next_compartment = next_compartment

What we see above is the first stage of the Frame runtime code for executing a transition. This code 
initializes the runtime 
variables which will be used by the kernel to use to actually perform the transition. After the return statement is called 
control passes back to the router which then returns to the kernel.

The kernel then performs the following steps: 

#. Start a loop testing for the existence of a **self.__next_compartment** that will continue until no transitions occur during the loop. 
#. Cache the **self.__next_compartment** into a local variable and then unset it. This is to simplify other kernel code.
#. Send exit event to current state
#. Change state to the new state compartment

.. code-block::
    :caption: Kernel Exit Event Handler Call 

    
    # ==================== System Runtime =================== #
    
    def __kernel(self, __e):
        
        # send event to current state
        self.__router(__e)
        
        # loop until no transitions occur
        while self.__next_compartment != None:
            next_compartment = self.__next_compartment
            self.__next_compartment = None
            
            # exit current state
            self.__router(FrameEvent( "<", self.__compartment.exit_args))
            # change state
            self.__compartment = next_compartment

The exit event handler prints out the first part of the output of the program: 

.. code-block::
    :caption: $S0 Exit Event Code

    # ----------------------------------------
    # $S0
    
    def __runtime2_state_S0(self, __e):
        if __e._message == "<":
            print("a=" + str(__e._parameters["a"]),end = "")
            return
        elif __e._message == "next":

            ...

Now that the **self.__compartment** has been updated to the new compartment the kernel can send the enter event to it.

.. code-block::
    :caption: Kernel Enter Event Code (with no Event Forwarding)

    if next_compartment.forward_event is None:
        # send normal enter event
        self.__router(FrameEvent(">", self.__compartment.enter_args))

                
.. code-block::
    :caption: $S1 Frame Code 

        $S1 [c]
            |>| [b]
                print("; b=" + str(b) + "; c=" + str(c)) ^

.. code-block::
    :caption: $S1 Python Code 

    # ----------------------------------------
    # $S1
    
    def __runtime2_state_S1(self, __e):
        if __e._message == ">":
            print("; b=" + str(__e._parameters["b"]) 
                         + "; c=" + str((self.__compartment.state_args["c"])))
            return

The enter event print code completes the output of the a,b and c parameters. 

.. code-block::
    :caption: Runtime2 Complete Output 

    a=1; b=2; c=3

Next we will take a look at another key feature of the runtime kernel - event forwarding. 

Event Forwarding Runtime Support
-----------

The Frame event forwarding mechanism provides the ability to receive an event in one state and 
then pass it to another state to handle. Below we see a simple example where state **$S0** receives 
the **next** event and simply forwards it to state **$S1** to handle and print the parameters.

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
##

Frame enables this capability by utilizing a special **forward_event** attribute on compartments 
to store a reference to the event that should be forwarded:

.. code-block::
    :caption: Event Forwarding Code in Originating State

    # ----------------------------------------
    # $S0
    
    def __runtime3_state_S0(self, __e):
        if __e._message == "next":
            next_compartment = Runtime3Compartment('__runtime3_state_S1')
            next_compartment.forward_event = __e
            self.__transition(next_compartment)
            return

In the kernel,  a test is performed for the existence of a forwarded event. 
If there isn't one then the kernel sends an enter event along with the enter parameters. 

If there was a forwarded event then the kernel takes two different paths depending on if 
the forwarded event was an enter event or not. If it is it then it is simply passed to the router. If 
it is some other event type then the kernel logic sends a new enter event to the router first and then 
follows it with the forwarded event. The important aspect to the logic is that in all code paths the kernel 
makes sure the new state receives an enter event, whether forwarded or newly created.

.. code-block::
    :caption: Event Forwarding Code in Kernel

    def __kernel(self, __e):
        
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
and how system parameters are initialized.  


System Initialization
-----------

There are three aspects of system startup that are parameterized and can be initialized upon system instantiation:

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

Above we see that each aspect of the system is initialized with one argument. The system factory (__init__([...])) 
method handles all of 
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
        
        def __runtime4_state_S0(self, __e):
            if __e._message == ">":
                print("a=" + str((self.__compartment.state_args["a"])) + "; b=" + str(__e._parameters["b"]) + "; c=" + str(self.c))
                return
    
    ...

We can see above how the start state can access all of the initialized parameters on the compartment (**a** and **b**) as 
well as the domain variable **c**.

History State Stack
-----------

Frame's history mechanism is an array used as a stack. For systems that use this feature, Frame 
generates code for the stack and its management operations. The first code generated
is the stack initialization in the System Factory. 
            
.. code-block::
    :caption: State Stack Initialization 

        # ==================== System Factory =================== #
        
        def __init__(self):
            
            # Create state stack.
            
            self.__state_stack = []

Frame also generates methods in the runtime for managing the stack. 

.. code-block::
    :caption: State Stack Runtime Mechanisms 

        # ==================== System Runtime =================== #
        
        ...

        def __state_stack_push(self, compartment: 'StateStackCompartment'):
            self.__state_stack.append(compartment)
        
        def __state_stack_pop(self):
            return self.__state_stack.pop()

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
                |next| $$[+] -> $B ^

            $B
                |>| print("$B") ^
                |next| $$[+] -> $C ^
                |ret| -> $$[-] ^

            $C
                |>| print("$C") ^
                |ret| -> $$[-] ^

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

Here we can see how Frame code is translated into Python to push a state: 

.. code-block::
    :caption: Frame Code for State Push and Transition  

    |next| $$[+] -> $C ^

.. code-block::
    :caption: Python Code for State Push and Transition

    elif __e._message == "next":
        self.__state_stack_push(self.__compartment)
        next_compartment = StateStackCompartment('__statestack_state_C')
        self.__transition(next_compartment)


And here we can see how Frame code is translated into Python to pop a state and transition to it: 

.. code-block::
    :caption: Frame Code for State Pop and Transition  

    |ret| -> $$[-] ^

.. code-block::
    :caption: Python Code for State Pop and Transition

    elif __e._message == "ret":
        next_compartment = self.__state_stack_pop()
        self.__transition(next_compartment)
        return


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
                next_compartment = StateStackCompartment('__statestack_state_C')
                self.__transition(next_compartment)
                return
            elif __e._message == "ret":
                next_compartment = self.__state_stack_pop()
                self.__transition(next_compartment)
                return
        
        ...

        # ==================== System Runtime =================== #
        
        ...

        def __state_stack_push(self, compartment: 'StateStackCompartment'):
            self.__state_stack.append(compartment)
        
        def __state_stack_pop(self):
            return self.__state_stack.pop()
        
Conclusion
----------

Frame is a Domain Specific Language for digital system design. As such it promotes systems, states and events as
first class entities in the language. Frame's runtime provides the mechanisms to recast 
object-oriented language features to meet this need. In the future, non-object oriented languages will also be 
supported by the Frame transpiler with appropriate adjustments to the runtime code. 



        
    