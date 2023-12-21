Persistance
==========

An important capability of many types of software is supporting **workflows**. 
In general a workflow is an asynchronously executed flow of 
steps that may result in different outcomes or actions being executed. Most commonly
the asychronous aspect of a workflow means that the it must be able to be persisted 
until a new event or condition occurs to drive the next step in the process. 



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

