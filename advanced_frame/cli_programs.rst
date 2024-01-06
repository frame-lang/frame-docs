
Command Line Interactive Programs 
=================================

Command Line Interactive Programs make up a broad category of software applications.
Here we will explore some simple programs that repeatedly poll
users for input. In the example below, the locus of control is in the infinite loop 
inside the enter event handler of the **$GetInput** state: 

.. code-block::
    :caption: todo

    $GetInput
        |>| 
            loop {
                print("Next state? (a|b|quit)")
                var next_state = input()
                next_state ?~
                    ~/a/ -> $A :>
                    ~/b/ -> $B :>
                    ~/quit/ -> $Done :>
                    : print("huh?") :|
            } ^
            
The loop is needed to deal with input that doesn't match any of the valid 
commands by printing "huh?" and 
trying again to get valid input. Valid commands trigger transitions to different states.

States **$A** and **$B** increment a state specific counter for how many times they have
been visited, print it out and then return to **$GetInput** to get the next command. In this 
way control stays inside the system and does not return to the **main** function. 

.. code-block::
    :caption: todo

    -machine-

    ...

    $A
        |>| 
            a_count = a_count + 1
            print("$A visit #" + str(a_count))
            -> $GetInput ^

    $B
        |>| 
            b_count = b_count + 1
            print("$B visit #" + str(b_count))
            -> $GetInput ^
    ...

    -domain-

    var a_count = 0
    var b_count = 0

In contrast, the **$Done** state simply prints "$Done", but does not pass control to 
another state or block waiting for user input. This results in control passing back 
to **main** and terminating the program. Here is the full program: 

.. code-block::
    :caption: todo

    $Done 
        |>| 
            print("Done") ^

.. code-block::
    :caption: todo

    `import signal`
    `import sys`

    fn main {
        #CliProgram()
    }

    #CliProgram

        -machine-

        $GetInput
            |>| 
                loop {
                    print("Next state? (a|b|quit)")
                    var next_state = input()
                    next_state ?~
                        ~/a/ -> $A :>
                        ~/b/ -> $B :>
                        ~/quit/ -> $Done :>
                        : print("huh?") :|
                } ^
        
        $A
            |>| 
                a_count = a_count + 1
                print("$A visit #" + str(a_count))
                -> $GetInput ^

        $B
            |>| 
                b_count = b_count + 1
                print("$B visit #" + str(b_count))
                -> $GetInput ^

        $Done 
            |>| 
                print("$Done") ^

        -domain-

        var a_count = 0
        var b_count = 0

    ##


.. code-block::
    :caption: todo

    Next state? (a|b|quit)
    a
    $A visit #1
    Next state? (a|b|quit)
    a
    $A visit #2
    Next state? (a|b|quit)
    b
    $B visit #1
    Next state? (a|b|quit)
    q
    huh?
    Next state? (a|b|quit)
    quit
    $Done