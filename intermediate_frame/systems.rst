==================
Systems
==================

Frame's focus is on helping softwre architects and developers design and deploy *systems*.
Behind the scenes, Frame is utilizing "object-oriented" classes (or equivalent) to 
implement a system design pattern by injecting a supporing runtime kernel. This 
pattern will be explored in more depth in advanced articles on Frame's implementation.

System Syntax 
---------

Frame uses the **#** token special type token to identify a system.  

.. code-block::
    :caption: System Declaration 

    #MySystem // System declaration

    ##        // System terminator 

The token **##** indicates the end of the system definition.


System Parameters 
-----------

Frame provides a way to pass initialization arguments to systems. There are three 
kinds of system data that can be initialized:

#. Start state parameters
#. Start state enter event parameters
#. Domain variables 

Frame system parameters are declared just after the name of the system.

.. code-block::
    :caption: System Parameters

    #SystemWithParameters [<system_params>]

As mentioned there are three types of system parameters, each with a particular 
aspect of the system to intialize. To differentiate these categories, Frame 
groups the parameter types with special parameter lists.


.. list-table:: System Parameter Types
    :widths: 25 25 25
    :header-rows: 1

    * - Parameter Type
      - Parameter List Syntax
      - Argument List Syntax
    * - Start state parameters
      - $[<params>]
      - $(<args>)
    * - Start state enter event parameters
      - >[<params>]
      - >(args)
    * - Domain Variables
      - #[<params>]
      - #(args)

.. code-block::
    :caption: System Parameter Groups

    #SystemWithParameters [$[<start_state_params>], >[<start_state_enter_params>], #[domain_params]]
    ##

    #SystemWithParametersExample [$[prefix,loopCount], >[age,favoriteColor], #[startMessage,endMessage]]
    ##

System With No Parameters
------------

Systems taking no parameters have an empty system list and take no arguments when instantiated.

.. code-block::
    :caption: System Instantiation with no Parameters Demo

    fn main {

        #NoParameters() // no arguments passed 
    }

    #NoParameters // no system parameters declared 

        -machine-

        $Start
            |>| print("#NoParameters started") ^
    ##

Run the `program <https://onlinegdb.com/Q6sB6hmvQ>`_. 

.. code-block::
    :caption: System Instantiation with no Parameters Demo Output 
    
    #NoParameters started

Above we can see **#NoParameters** is instantiated in **main**. Upon launch, the system is sent 
a **>** message which is handled in the start state and prints "NoParameters started".

Start State Parameters 
+++++++++++

Start state parameters are declared using the special start state parameter declaration list syntax 
**$[<start state params>]**. Likewise, start state initialization arguments are passed in the system initialization 
expression list using the special start state argument expression list syntax **$(<start state args>)**. 

.. code-block::
    :caption: Start State Parameters Demo

    fn main {
        // System Start State Arguments 
        #StartStateParameters($("$StartStateParameters started"))
    }

    // Start State Parameters Declared
    #StartStateParameters [$[msg]] 

        -machine-

        // Start State Parameters
        $Start [msg] 
            |>| print(msg) ^
    ##

Run the `program <https://onlinegdb.com/jFnS879e_>`_. 

.. code-block::
    :caption: Start State Parameters Demo Output 

    #StartStateParameters started

Start State Enter Parameters 
+++++++++++

Start state parameters are declared using the special start state enter parameter declaration list syntax 
**>[<start state enter params>]**. Likewise, start state enter initialization arguments are passed in the system initialization 
expression list using the special start state enter argument expression list syntax **>(<start state enter args>)**. 

.. code-block::
    :caption: Start State Enter Parameters Demo

    fn main {
        // System Start State Enter Arguments 
        #StartStateEnterParameters(>(">StartStateEnterParameters started"))
    }

    // System Start State Enter Parameters
    #StartStateEnterParameters [>[msg]]  

        -machine-

        $Start 
            // Start State Enter Parameters
            |>| [msg] print(msg) ^
    ##

Run the `program <https://onlinegdb.com/wmjdnXNEx>`_. 

.. code-block::
    :caption: Start State Enter Parameters Demo Output 

    >StartStateEnterParameters started

System Domain Parameters 
+++++++++++

Lastly, the system domain can be initialized during instantiation as well. System domain parameters are 
declared using the special system domain parameter declaration list syntax 
**#[<domain initalization params>]**. Likewise, domain initialization arguments are passed in the system initialization 
expression list using the special domain initialization argument expression list syntax **#(<domain initalization args>)**. 

The domain initialization parameters are mapped by name to matching domain variables and override the default 
variable initalization values. 

.. code-block::
    :caption: System Domain Parameters Demo 

    fn main {
        // System Domain Arguments
        #SystemDomainParameters(#("#SystemDomainParameters started"))
    }

    // System Domain Parameters
    #SystemDomainParameters [#[msg]] 

        -machine-

        $Start 
            |>| print(msg) ^

        -domain-

        // System Domain Argument initialization overridden 
        var msg = nil 

    ##

Run the `program <https://onlinegdb.com/QKigQog6F>`_. 

.. code-block::
    :caption: System Domain Parameters Demo Output 

    #SystemDomainParameters started


System Factory 
+++++++++++

Systems are intatiated and initialized by a runtime **system factory**. The implementation 
of the system factory is explained in the advanced section. The system factory does the 
following steps when launching a system: 

#. Initialize the start state parameters 
#. Initialize the state state event parameters 
#. Initialize any specified domain variables 
#. Send the enter event to the start state 

.. code-block::
    :caption: System Initialization Demo  

    fn main {
        #SystemInitializationDemo($("a","b"),>("c","d"),#("e","f"))
    }

    #SystemInitializationDemo [$[A,B], >[C,D], #[E,F]]

        -machine-

        $Start [A,B]
            |>| [C,D] print(A + B + C + D + E + F) ^

    
        -domain-

        var E = nil
        var F = nil 
    ## 

Above we see that the lower case letters a..f are mapped to the equivalent system 
parameters or domain variables.


Run the `program <https://onlinegdb.com/exFLCwgAl>`_. 

.. code-block::
    :caption: System Initialization Demo Output 

    abcdef