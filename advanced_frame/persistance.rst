Persistance
==========

An important capability of many types of software is supporting **workflows**. 
A workflow is an asynchronously executed sequence of event driven 
steps . Most commonly
the asychronous aspect of a workflow means that the it must be able to be persisted 
between each step in the process. 

Frame for Python supports a pattern for persistence using the `**jsonpickle** library <https://jsonpickle.github.io/>`_ 
combined with Frame operations. 

To perform a deep copy of a system, create an operation (ours is called **marshal**) 
that uses **jsonpickle.encode(self)** to get a JSON object containing the state 
of the system:

.. code-block::
    :caption: Operation to Deep Copy the System State

        -operations-

        marshal : JSON {
            ^(jsonpickle.encode(self))
        }

Persisting the system is as simple as calling the operation and then saving the data 
on disk, in a database or other in some other durable way. In our case we will simply keep
the data in memory.

.. code-block::
    :caption: Use of marshal functionality

        var ds:# = #DurableSystem()
    
        // get deep copy
        var data = ds.marshal()

        // remove reference to the system
        ds = nil

To reconstitute a system, we will use 
a *static* operation **unmarshal [data]**  and return the output 
of **jsonpickle.decode(data)**: 

.. code-block::
    :caption: System Reconstitution 

        -operations-

        #[static]
        unmarshal [data] : #DurableSystem {
            ^(jsonpickle.decode(data)) 
        } 

To access this static operation we call **unmarshal** through the system type specifier
itself rather than an instance of the system (as there isn't one): 

.. code-block::
    :caption: Persistence Mechanisms

        // Restore system using static operation
        ds = #DurableSystem.unmarshal(data)

The ds variable now references the **#DurableSystem** instance in the state it 
was previously in.

Persistance Demo 
----------------

Let's create a persitable system that tracks how many times its been 
saved and restored. Our **#PersistDemo** system 
has a single state **$Started** which has a state variable **revived_count** which will be used to 
track how many times the state (and by proxy the system in this case) has been revived. 

.. code-block::
    :caption: State with Counter for Revival Count

        -machine-

        $Start 
            var revived_count = 0

            |>| 
                print("Started") ^

            |revived| 
                revived_count = revived_count + 1
                print("Revived = " + str(revived_count) + " times") 
                ^

The first time the **$Start** is entered is during instantiation, which only happens when 
the system is initially created. It does not happen with each reinstantiation. To keep 
count of the number of revivals, we have a state variable **revived_count** which will 
be incremented and printed when the **revived** event is received. To do so, we will call the
**revived** interface method before returning the system to the caller: 

.. code-block::
    :caption: Persistence Demo

        -operations-

        #[static]
        unmarshal [data] : #PersistDemo  {
            var demo:# = jsonpickle.decode(data)
            demo.revived()
            ^(demo) 
        } 

We will do a simple test on the system by creating it and then immeditely persisting it:


.. code-block::
    :caption: Persistence Demo

        var demo:# = #PersistDemo()
    
        // get deep copy
        var data = demo.marshal()

        // remove reference to system
        demo = nil

Upon creating the demo we will see the following output from the **$Start** state enter 
event handler: 

.. code-block::
    :caption: todo

    Started

Next we will loop 3 times and revive and persist the system with each loop: 

.. code-block::
    :caption: todo

    loop var i = 0; i < 3; i = i + 1 {

        // Restore system using static operation
        demo = #PersistDemo.unmarshal(data)

        // get deep copy
        data = demo.marshal()

        // remove reference to the system
        demo = nil
    }

Each loop will increment **revival_count** and print it: 

.. code-block::
    :caption: Perisitance Demo Output 

    Revived = 1 times
    Revived = 2 times
    Revived = 3 times

Here is the full program: 

.. code-block::
    :caption: Persistence Demo

    `import sys`
    `import time`
    `import jsonpickle`

    fn main {

        var demo:# = #PersistDemo()
    
        // get deep copy
        var data = demo.marshal()

        // remove reference to system
        demo = nil

        loop var i = 0; i < 3; i = i + 1 {

            // Restore system using static operation
            demo = #PersistDemo.unmarshal(data)

            // get deep copy
            data = demo.marshal()

            // remove reference to the system
            demo = nil
        }

    }

    #PersistDemo

        -interface-

        revived 

        -machine-

        $Start 
            var revived_count = 0

            |>| 
                print("Started") ^

            |revived| 
                revived_count = revived_count + 1
                print("Revived = " + str(revived_count) + " times") 
                ^

        -operations-

        #[static]
        unmarshal [data] : #PersistDemo  {
            var demo:# = jsonpickle.decode(data)
            demo.revived()
            ^(demo) 
        } 

        marshal : JSON {
            ^(jsonpickle.encode(self))
        }
        
    ##


Persisted Traffic Light 
-----------------------

As an incremental step towards a workflow example, the Traffic Light system in the next 
demo implements a cycle of persisted state transitions.

.. code-block::
    :caption: Persisted Traffic Light

    `import sys`
    `import time`
    `import jsonpickle`

    fn main {

        var tl:# = #TrafficLight()
        var data = tl.marshal()
        tl = None
        time.sleep(.5)

        loop var x = 0; x < 9; x = x + 1 {
            tl = #TrafficLight.unmarshal(data)
            tl.tick()
            time.sleep(.5)
            data = tl.marshal()
            tl = nil
        }
    }

    #TrafficLight

        -interface-

        tick

        -machine-

        $Green
            |>|
                print("Green") ^

            |tick|
                -> $Yellow ^

        $Yellow
            |>|
                print("Yellow") ^

            |tick|
                -> $Red ^

        $Red
            |>|
                print("Red") ^

            |tick|
                -> $Green ^

        -operations-

        #[static]
        unmarshal [data] {
            ^(jsonpickle.decode(data)) 
        } 

        marshal {
            ^(jsonpickle.encode(self))
        }
        
    ##


Workflows
----------

Our final demo is a true workflow. It is basically the same functionality as the Traffic 
Light demo but results in an end state that ties together many of the capabilities 
shown in the previous demos. The flow progresses from a **$Ready** state through a couple 
of "work" steps and completes in an end state of **$Done**. If further events are sent 
to progress, the state detects that and notifies the caller that the workflow is complete.

.. code-block::
    :caption: Workflow Demo

    `import sys`
    `import time`
    `import jsonpickle`

    fn main {

        var flow:# = #Workflow()

        // delay
        time.sleep(1)
        
        loop var i = 0; i < 4; i = i + 1 {
            flow.next()

            // Persist workflow
            var data = flow.marshal()

            // dereference system
            flow = nil

            // delay
            time.sleep(1)

            // Revive workflow
            flow = #Workflow.unmarshal(data)
        }

        flow.next()
        flow = nil
    }

    #Workflow

        -interface-

        next

        -machine-

        $Ready
            |>|
                print("Ready") ^

            |next|
                -> $Step1 ^

        $Step1
            |>|
                print("Doing Step1") ^

            |next|
                -> $Step2 ^

        $Step2
            |>|
                print("Doing Step2") ^

            |next|
                -> $Done ^

        $Done
            var exclamation_count = 1

            |>|
                print("Done.") ^

            |next|
                print("I told you I was done", end="") 
                loop var i = 0; i < exclamation_count; i = i + 1 {
                    print("!",end="")
                }
                exclamation_count = exclamation_count + 1
                print("")
                
                ^

        -operations-

        #[static]
        unmarshal [data] {
            ^(jsonpickle.decode(data)) 
        } 

        marshal {
            ^(jsonpickle.encode(self))
        }
        
    ##
