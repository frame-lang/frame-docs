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
    :caption: Generated Python code 

    # ----------------------------------------
    # $S0
    
    def __runtime0_state_S0(self, e):
        if e._message == ">":
            print(self.msg)
            return



Runtime Transition Support 
--------------------------
        
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

Transitions
-----------

Transitions are effected by a two step process:

#. Create a compartment for the new state 
#. Initialize 



    