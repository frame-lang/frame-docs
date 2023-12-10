==================
Systems
==================

Frame's focus is on helping softwre architects and developers design and deploy systems.
Behind the scenes, Frame is utilizing "object-oriented" classes (or equivalent) to 
implement a system design pattern and injecting a supporing runtime kernel. This 
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
            |>| print ("#NoParameters started") ^
    ##

Run the `program <https://onlinegdb.com/Q6sB6hmvQ>`_. 

.. code-block::
    :caption: System Instantiation with no Parameters Demo Output 
    
    #NoParameters started

Above we can see **#NoParameters** is instantiated in **main**. Upon launch, the system is sent 
a **>** message which is handled in the start state and prints "NoParameters started".

Start State Parameters 
+++++++++++

.. code-block::
    :caption: Start State Parameters Demo

    fn main {
        // System Start State Arguments 
        #StartStateParameters($("#StartStateParameters started"))
    }

    #StartStateParameters [$[msg]] // Start Start State Parameters Declared

        -machine-

        $Start [msg] // Start State Parameters
            |>| print(msg) ^
    ##

Run the `program <https://onlinegdb.com/u4XJm3uxC>`_. 

.. code-block::
    :caption: Start State Parameters Demo Output 

    #StartStateParameters started

Start State Enter Parameters 
+++++++++++

.. code-block::
    :caption: Start State Enter Parameters Demo

    fn main {
        // System Start State Enter Arguments 
        #StartStateEnterParameters(>("#StartStateEnterParameters started"))
    }

    #StartStateEnterParameters [>[msg]] // // System Start State Enter Parameters 

        -machine-

        $Start 
            // Start State Enter Parameters
            |>| [msg] print(msg) ^
    ##

Run the `program <https://onlinegdb.com/SIaUcreM2o>`_. 

.. code-block::
    :caption: Start State Enter Parameters Demo Output 

    #StartStateEnterParameters started

System Domain Parameters 
+++++++++++

.. code-block::
    :caption: System Domain Parameters Demo 

    fn main {
        // System Domain Arguments
        #SystemDomainParameters(#("SystemDomainParameters started"))
    }

    #SystemDomainParameters [#[msg]] // System Domain Parameters

        -machine-

        $Start 
            |>| print(msg) ^

        -domain-

        // System Domain Argument initialization overridden 
        var msg = nil 

    ##

Run the `program <https://onlinegdb.com/6W0B4Mgap>`_. 

.. code-block::
    :caption: System Domain Parameters Demo Output 

    SystemDomainParameters started


System Factory 
+++++++++++

Systems are intatiated and initialized by a runtime **system factory**. The implementation 
of the system factory is explained in the advanced section. The system factory does the 
following steps when launching a system: 

#. Initialize the start state parameters 
#. Initialize the state state event parameters 
#. Initialize any specficed domain variables 
#. Sends the enter event to the start state 

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