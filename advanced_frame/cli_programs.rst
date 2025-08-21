
Command Line Interactive Programs 
=================================

Command Line Interactive Programs make up a broad category of software applications.
Here we will explore some simple programs that repeatedly poll
users for input. In the example below, the locus of control is in the infinite loop 
inside the enter event handler of the **$GetInput** state (as opposed to the loop in an external function).

Frame v0.20 uses conventional syntax for loops and conditionals, making CLI programs more readable and familiar to developers from mainstream languages. 

.. code-block::
    :caption: Get Input Loop

    $GetInput {
        $>() {
            while true {
                print("Next state? (a|b|quit)")
                var next_state = input()
                if next_state == "a": -> $A
                elif next_state == "b": -> $B
                elif next_state == "quit": -> $Done
                else: print("huh?")
            }
        }
    }
            
The while loop is needed to deal with input that doesn't match any of the valid 
commands by printing "huh?" and 
trying again to get valid input. Valid commands trigger transitions to different states.

States **$A** and **$B** increment a state specific counter for how many times they have
been visited, print it out and then return to **$GetInput** to get the next command. In this 
way control stays inside the system and does not return to the **main** function. 

.. code-block::
    :caption: $A and $B Aggregator States

    machine:

    ...

    $A {
        $>() {
            a_count = a_count + 1
            print("$A visit #" + str(a_count))
            -> $GetInput
        }
    }

    $B {
        $>() {
            b_count = b_count + 1
            print("$B visit #" + str(b_count))
            -> $GetInput
        }
    }
    ...

    domain:

    var a_count: int = 0
    var b_count: int = 0

In contrast, the **$Done** state simply prints "$Done", but does not pass control to 
another state or block waiting for user input. This results in control passing back 
to **main** and terminating the program. Here is the full program: 

.. code-block::
    :caption: $Done State

    $Done {
        $>() {
            print("Done")
        }
    }

.. code-block::
    :caption: CliProgram System Listing

    `import signal`
    `import sys`

    fn main() {
        var cli = CliProgram()
    }

    system CliProgram {

        machine:

        $GetInput {
            $>() {
                while true {
                    print("Next state? (a|b|quit)")
                    var next_state = input()
                    if next_state == "a": -> $A
                    elif next_state == "b": -> $B
                    elif next_state == "quit": -> $Done
                    else: print("huh?")
                }
            }
        }
        
        $A {
            $>() {
                a_count = a_count + 1
                print("$A visit #" + str(a_count))
                -> $GetInput
            }
        }

        $B {
            $>() {
                b_count = b_count + 1
                print("$B visit #" + str(b_count))
                -> $GetInput
            }
        }

        $Done {
            $>() {
                print("$Done")
            }
        }

        domain:

        var a_count: int = 0
        var b_count: int = 0

    }


.. code-block::
    :caption: CliProgram Listing Output

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