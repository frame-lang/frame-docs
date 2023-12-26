Services
==========



.. code-block::
    :caption: Basic Service Infinite Loop
        
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

.. code-block::
    :caption: todo

    `import signal`
    `import sys`

    fn main {
        #InputService()
    }

    #InputService

    -operations-

    signal_handler[sig, frame] {
        quit()
    }

    -interface-

    quit

    -machine-

    $Input
        |>| 
            signal.signal(signal.SIGINT, #.signal_handler)
            loop {
                print("Next state? (a|b)")
                var next_state = input()
                next_state ?~
                    ~/a/ -> $A :>
                    ~/b/ -> $B :>
                    : print("huh?") :|
            } ^

        |quit| -> $Done ^ 
    
    $A
        |>| 
        a_count = a_count + 1
        print("$A visit #" + str(a_count))
        -> $Input ^

    $B
        |>| 
        b_count = b_count + 1
        print("$B visit #" + str(b_count))
        -> $Input ^

    $Done 
        |>| 
        print("$Done")
        sys.exit(0) ^

    -domain-

    var a_count = 0
    var b_count = 0

    ##

