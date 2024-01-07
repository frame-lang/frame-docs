Services
==========


Services are programs that run autonomously in the background and typically do not exit 
until terminated by the OS or framework. Services can be created using Frame 
by never returning from intialization which requires designing the system to have 
all functionality in enter events.  

The first example we will examine, Looper, is not a true service, but visibly demonstrates important 
aspects to the state machine runtime implementation useful for designing services. 

Looper is a program that does a speed test of how long it takes to transition from state **$A** to state **$B** and back one million 
times. One of the most important aspects to Looper is the demonstration that the runtime architecture actually supports transitioning 
1E^6 times without blowing up the stack as previous Frame runtime implementations were not able to support 
this need. Secondarily, Looper passes data from one 
state to another using the enter event handler parameters rather than persisting to 
domain variables.

Looper instantiates a **#Looper** system in **main** and passes the number of loops 
to perform as an argument to the system: 

.. code-block::
    :caption: Looper Instantiation

    fn main {
        #Looper(>(1000000))
    }

    #Looper [>[loops]]
    ...

Looper begins in the **$Start** state, prints "Starting" and then transitions to **$A** 
while passing in the number of loops twice (we'll see why next) as well as the start time. 

.. code-block::
    :caption: Looper Start State

    -machine-

    $Start
        |>| [loops]
            print("Starting")
            -> (loops, loops, time.time()) $A ^

    $A 
        |>| [total_loops, loops_left, start]
    ...


.. code-block::
    :caption: Looper Looped States

    $A 
        |>| [total_loops, loops_left, start]
            loops_left == 0  ? -> $Done(total_loops, start) ^ :|
            -> (total_loops, loops_left, start) $B ^
    
    $B
        |>| [total_loops, loops_left, start]
            loops_left = loops_left - 1
            -> (total_loops, loops_left, start) $A ^ 

Both **$A** and **$B** accept the same parameters and cycle transitioning between each other 
while counting down the loops_left. State **$B** decrements **loops_left** and 
state **$A** tests if **loops_left** is 0. If **loops_left == 0**, the machine transitions 
to **$Done** while passing the total loops and start time as transition arguments. 

.. code-block::
    :caption: $Done State

    $Done [total_loops, start]
        |>| 
            print("Done. Looped " + str(total_loops) + " times in ", end = " ") 
            print(str(time.time() - start) + " seconds.") ^

The arguments passed to **$Done** are used to print out a report. Here is the full 
program: 

.. code-block::
    :caption: Looper Speed Test Demo 

    `import time`

    fn main {
        #Looper(>(1000000))
    }

    #Looper [>[loops]]

    -machine-

    $Start
        |>| [loops]
            print("Starting")
            -> (loops, loops, time.time()) $A ^

    $A 
        |>| [total_loops, loops_left, start]
            loops_left == 0  ? -> $Done(total_loops, start) ^ :|
            -> (total_loops, loops_left, start) $B ^
    
    $B
        |>| [total_loops, loops_left, start]
            loops_left = loops_left - 1
            -> (total_loops, loops_left, start) $A ^  

    $Done [total_loops, start]
        |>| 
            print("Done. Looped " + str(total_loops) + " times in ", end = " ") 
            print(str(time.time() - start) + " seconds.") ^

    ##


.. code-block::
    :caption: Looper Speed Test Demo Output

    Starting
    Done. Looped 1000000 times in  5.543075799942017 seconds.

Services 
--------

True services, in general, do not have inate termination criteria. Instead some outside signal source "kills" the program. The next example shows 
a program similar to Looper but with no termination logic. Instead, the user must send 
an interupt signal by pressing CTRL-C. 

.. code-block::
    :caption: Service Machine Loop Demo
        
    `import time`

    fn main {
        #BasicService()
    }

    #BasicService

    -machine-

    $A 
        |>| 
            print("$A")
            time.sleep(.2)
            -> $B ^
    
    $B
        |>| 
            print("$B")
            time.sleep(.2)
            -> $A ^

    ##

The service machine simply loops between states **$A** and **$B**, printing out the current state
and then transitioning after a brief sleep. 

.. code-block::
    :caption: Service Machine Loop Demo Output

    $A
    $B
    $A
    $B
    $A
    $B

When the excitement from watching an endless stream of **$As** and **$Bs** wears off, the 
program can be interrupted by pressing CTRL-C, which produces some ugly spew:

.. code-block::
    :caption: CTRL-C Stack Spew

    ^CTraceback (most recent call last):
    File "/home/main.py", line 114, in <module>
        main()
    File "/home/main.py", line 12, in main
        BasicService()
    File "/home/main.py", line 31, in __init__
        self.__kernel(frame_event)
    File "/home/main.py", line 77, in __kernel
        self.__router(FrameEvent(">", self.__compartment.enter_args))
    File "/home/main.py", line 93, in __router
        self.__basicservice_state_A(e)
    File "/home/main.py", line 41, in __basicservice_state_A
        time.sleep(.2)
    KeyboardInterrupt

Let's make this a bit cleaner of an exit with a couple of modifications. First we will 
add an operation to catch the CTRL-C signal and exit the process:

.. code-block::
    :caption: CTRL-C Signal Handler Operation

    -operations-

    signal_handler[sig, frame] {
        sys.exit(0)
    }

Next we will add an **$Init** state to register the handler and start the loop: 

.. code-block::
    :caption: Register CTRL-C Signal Handler

    $Init 
        |>| 
            signal.signal(signal.SIGINT, #.signal_handler)
            -> $A ^

Here is the complete demo: 

.. code-block::
    :caption: Full Signal Handler Demo

    `import time`
    `import signal`
    `import sys`

    fn main {
        #CleanExitService()
    }

    #CleanExitService

        -operations-

        signal_handler[sig, frame] {
            sys.exit(0)
        }

        -machine-

        $Init 
            |>| 
                signal.signal(signal.SIGINT, #.signal_handler)
                -> $A ^

        $A 
            |>| 
                print("$A")
                time.sleep(.2)
                -> $B ^
        
        $B
            |>| 
                print("$B")
                time.sleep(.2)
                -> $A ^

        ##

.. code-block::
    :caption: Full Signal Handler Demo Output

    $A
    $B
    $A
    $B
    $A
    ^C


Though effective in more elegantly stopping the service, the example above doesn't give the system an 
opportunity to clean itself up. Let's restructure the program to send the system 
a **quit** event and take care of exiting the process itself only after it gets 
to say goodbye. 

To start we will modify the **signal_handler** to call a new **quit** interface method 
rather than make the **sys.exit(0)** call itself.

.. code-block::
    :caption: Signal Handler Calling Interface

        -operations-

        signal_handler[sig, frame] {
            quit()
        }

        -interface-

        quit 

Next we will create a state just for handling the **quit** event: 

 .. code-block::
    :caption: $Done State

        $Done 
            |quit|
                print("Goodbye!")
                sys.exit(0) ^

To enable receiving this event, we will modify **$A** and **$B** to inherit behavior from 
**Done**: 

 .. code-block::
    :caption: Hierarchical State Machine System

        $A => $Done
            |>| 
                print("$A")
                time.sleep(.2)
                -> $B ^
        
        $B => $Done
            |>| 
                print("$B")
                time.sleep(.2)
                -> $A ^

Here is the full program: 

.. code-block::
    :caption: #SignalMachineService 

    `import time`
    `import signal`
    `import sys`

    fn main {
        #SignalMachineService()
    }

    #SignalMachineService

        -operations-

        signal_handler[sig, frame] {
            quit()
        }

        -interface-

        quit 

        -machine-

        $Init 
            |>| 
                signal.signal(signal.SIGINT, #.signal_handler)
                -> $A ^

        $A => $Done
            |>| 
                print("$A")
                time.sleep(.2)
                -> $B ^
        
        $B => $Done
            |>| 
                print("$B")
                time.sleep(.2)
                -> $A ^
        
        $Done 
            |quit|
                print("Goodbye!")
                sys.exit(0) ^

        ##

This system is also a good example of Hierarchical State Machines (HSMs) ability to factor out 
common behavior using the dispatch operator **=>**.
