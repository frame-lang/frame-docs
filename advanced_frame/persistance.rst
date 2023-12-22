Persistance
==========

An important capability of many types of software is supporting **workflows**. 
A workflow is an asynchronously executed sequence of event driven 
steps . Most commonly
the asychronous aspect of a workflow means that the it must be able to be persisted 
between each step in the process. 

Frame for Python supports persistence using the `**jsonpickle** library <https://jsonpickle.github.io/>`_ 
combined with Frame operations. 

To perform a deep copy of a system, create an operation (ours is called **marshal**) 
that uses **jsonpickle.encode(self)** to get a JSON data structure of the state 
of the system.


.. code-block::
    :caption: Deep Copy of System State

        -operations-

        marshal : JSON {
            ^(jsonpickle.encode(self))
        }


.. code-block::
    :caption: System Reconstitution 

        -operations-

        #[static]
        unmarshal [data] {
            ^(jsonpickle.decode(data)) 
        } 

.. code-block::
    :caption: Persistence Mechanisms

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
        unmarshal [data] {
            ^(jsonpickle.decode(data)) 
        } 

        marshal {
            ^(jsonpickle.encode(self))
        }
        
    ##

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

        loop var i = 0; i < 10; i = i + 1 {
        
            // Restore system using static operation
            demo = #PersistDemo.unmarshal(data)

            // increment revived count
            demo.revived()

            // get deep copy
            data = demo.marshal()

            // remove reference to system
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
        unmarshal [data] {
            ^(jsonpickle.decode(data)) 
        } 

        marshal : JSON {
            ^(jsonpickle.encode(self))
        }
        
    ##

.. code-block::
    :caption: Workflow Demo

    `import sys`
    `import time`
    `import jsonpickle`

    fn main {

        var flow:# = #Workflow()
        flow.next()

        // --------------------------
        // Persist workflow
        var data = flow.marshal()
        flow = nil
        // Restore workflow
        flow = #Workflow.unmarshal(data)
        // --------------------------

        flow.next()

        // --------------------------
        // Persist workflow
        data = flow.marshal()
        flow = nil
        // Restore workflow
        flow = #Workflow.unmarshal(data)
        // --------------------------

        flow.next()

        // --------------------------
        // Persist workflow
        data = flow.marshal()
        flow = nil
        sleep(0.25)
        // Restore workflow
        flow = #Workflow.unmarshal(data)
        // --------------------------
    
        flow.next()

        // --------------------------
        // Persist workflow
        data = flow.marshal()
        flow = nil
        // Restore workflow
        flow = #Workflow.unmarshal(data)
        // --------------------------
    
        flow.next()
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
                print("") ^

        -operations-

        #[static]
        unmarshal [data] {
            ^(jsonpickle.decode(data)) 
        } 

        marshal {
            ^(jsonpickle.encode(self))
        }
        
    ##


.. code-block::
    :caption: Persisted Traffic Light

    `import sys`
    `import time`
    `import jsonpickle`

    fn main {

        var m:# = #TrafficLight()
        var data = m.marshal()
        m = None

        loop var x = 0; x < 9; x = x + 1 {
            m = #TrafficLight.unmarshal(data)
            m.tick()
            time.sleep(1)
            data = m.marshal()
            m = nil
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

