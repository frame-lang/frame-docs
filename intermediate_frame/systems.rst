 

==================
Systems
==================

Frame's focus is on helping software architects and developers design and deploy *systems*.
Behind the scenes, Frame is utilizing "object-oriented" classes (or equivalent) to 
implement a system design pattern by injecting a supporting runtime kernel. This 
pattern will be explored in more depth in advanced articles on Frame's implementation.

System Syntax 
---------

Frame uses the **system** keyword to identify a system.  

.. code-block::
    :caption: System Declaration 

    system MySystem { // System declaration
    
    }                 // System terminator 

The closing brace **}** indicates the end of the system definition.


System Parameters 
-----------

.. note::
    The system parameter syntax has been simplified in v0.20 to use conventional parentheses 
    instead of special bracket notation. All examples below show the current v0.20 syntax.

Frame provides a way to pass initialization arguments to systems. There are three 
kinds of system data that can be initialized:

#. Start state parameters
#. Start state enter event parameters
#. Domain variables 

In v0.20, Frame system parameters are declared using conventional parentheses syntax:

.. code-block:: frame
    :caption: System Parameters (v0.20 syntax)

    system SystemWithParameters (<system_params>) {
        // System body
    }

As mentioned there are three types of system parameters, each with a particular 
aspect of the system to initialize. To differentiate these categories, Frame 
grouped the parameter types with special parameter lists.


.. list-table:: System Parameter Types - v0.11 vs v0.20 
    :widths: 20 25 25 30
    :header-rows: 1

    * - Parameter Type
      - v0.11 Parameter Syntax
      - v0.11 Argument Syntax  
      - v0.20 Parameter/Argument Syntax
    * - Start state parameters
      - $[<params>]
      - $(<args>)
      - $(<params>) / flattened args
    * - Start state enter event parameters
      - >[<params>]
      - >(<args>)
      - $>(<params>) / flattened args  
    * - Domain Variables
      - #[<params>]
      - #(<args>)
      - <params> / flattened args

.. code-block::
    :caption: System Parameter Groups (v0.20 syntax)

    system SystemWithParameters ($(start_state_params), $>(start_state_enter_params), domain_params) {
    }

    system SystemWithParametersExample ($(prefix,loopCount), $>(age,favoriteColor), startMessage,endMessage) {
    }

System With No Parameters
------------

Systems taking no parameters have an empty system list and take no arguments when instantiated.

.. code-block::
    :caption: System Instantiation with no Parameters Demo

    fn main() {

        var sys = NoParameters() // no arguments passed 
    }

    system NoParameters { // no system parameters declared 

        machine:

            $Start {
                $>() {
                    print("NoParameters started")
                    return
                }
            }
    }

Run the `program <https://onlinegdb.com/Q6sB6hmvQ>`_. 

.. code-block::
    :caption: System Instantiation with no Parameters Demo Output 
    
    NoParameters started

Above we can see **NoParameters** is instantiated in **main**. Upon launch, the system is sent 
a **$>** message which is handled in the start state and prints "NoParameters started".

Start State Parameters 
+++++++++++

.. note::
    Start state parameter syntax has changed in v0.20. The example below shows the updated v0.20 syntax.

In v0.20, start state parameters are declared using the syntax 
**$(param1, param2, ...)**. System initialization uses a flattened argument list 
without special wrapper syntax. 

.. code-block::
    :caption: Start State Parameters Demo (v0.20 syntax)

    fn main() {
        // System Start State Arguments - flattened list
        var sys = StartStateParameters("StartStateParameters started")
    }

    // Start State Parameters Declared with $() syntax
    system StartStateParameters ($(msg)) {

        machine:

            // Start State Parameters
            $Start(msg) {
                $>() {
                    print(msg)
                    return
                }
            }
    }

Run the `program <https://onlinegdb.com/jFnS879e_>`_. 

.. code-block::
    :caption: Start State Parameters Demo Output 

    StartStateParameters started

Start State Enter Parameters 
+++++++++++

.. note::
    Start state enter parameter syntax has changed in v0.20. The example below shows the updated v0.20 syntax.

In v0.20, start state enter parameters are declared using the syntax 
**$>(param1, param2, ...)**. System initialization uses a flattened argument list 
without special wrapper syntax. 

.. code-block::
    :caption: Start State Enter Parameters Demo (v0.20 syntax)

    fn main() {
        // System Start State Enter Arguments - flattened list 
        var sys = StartStateEnterParameters(">StartStateEnterParameters started")
    }

    // System Start State Enter Parameters with $>() syntax
    system StartStateEnterParameters ($>(msg)) {

        machine:

            $Start {
                // Start State Enter Parameters
                $>(msg) {
                    print(msg)
                    return
                }
            }
    }

Run the `program <https://onlinegdb.com/wmjdnXNEx>`_. 

.. code-block::
    :caption: Start State Enter Parameters Demo Output 

    StartStateEnterParameters started

System Domain Parameters 
+++++++++++

.. note::
    System domain parameter syntax has changed in v0.20. The example below shows the updated v0.20 syntax.

In v0.20, the system domain can be initialized during instantiation. Domain parameters are 
declared as plain parameters without special syntax. Domain initialization arguments are passed in the system initialization 
using a flattened argument list without wrapper syntax. 

The domain initialization parameters were mapped by name to matching domain variables and override the default 
variable initialization values. 

.. code-block::
    :caption: System Domain Parameters Demo (v0.20 syntax)

    fn main() {
        // System Domain Arguments - flattened list
        var sys = SystemDomainParameters("SystemDomainParameters started")
    }

    // System Domain Parameters - plain parameter syntax
    system SystemDomainParameters (msg) {

        machine:

            $Start {
                $>() {
                    print(msg)
                    return
                }
            }

        domain:

            // System Domain Argument initialization overridden 
            var msg = nil 

    }

Run the `program <https://onlinegdb.com/QKigQog6F>`_. 

.. code-block::
    :caption: System Domain Parameters Demo Output 

    SystemDomainParameters started


System Factory 
+++++++++++

Systems are initiated and initialized by a runtime **system factory**. The implementation 
of the system factory is explained in the advanced section. The system factory does the 
following steps when launching a system: 

#. Initialize the start state parameters 
#. Initialize the state state event parameters 
#. Initialize any specified domain variables 
#. Send the enter event to the start state 

.. code-block::
    :caption: System Initialization Demo (v0.20 syntax)

    fn main() {
        var sys = SystemInitializationDemo("a","b","c","d","e","f")
    }

    system SystemInitializationDemo ($(A,B), $>(C,D), E,F) {

        machine:

            $Start(A,B) {
                $>(C,D) {
                    print(A + B + C + D + E + F)
                    return
                }
            }

    
        domain:

            var E = nil
            var F = nil 
    } 

Above we see that the lower case letters a..f are mapped to the equivalent system 
parameters or domain variables.


Run the `program <https://onlinegdb.com/exFLCwgAl>`_. 

.. code-block::
    :caption: System Initialization Demo Output 

    abcdef