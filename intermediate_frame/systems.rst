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
      - Example
    * - Start state parameters
      - $[<params>]
      - $[prefix,loopCount]
    * - Start state enter event parameters
      - >[<params>]
      - >[age,favoriteColor]
    * - Domain Variables
      - #[<params>]
      - #[startMessage,endMessage]

.. code-block::
    :caption: System Parameter Groups

    #SystemWithParameters [$[<start_state_params>], >[<start_state_enter_params>], #[domain_params]]
    ##

    #SystemWithParametersExample [$[name,dateOfBirth], $[prefix,loopCount], #[startMessage,endMessage]]
    ##

System With No Parameters
------------


Frame's syntax for instantiating a system that takes no parameters is 
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
a **>** message which is handled in the start state and prints "System1 started".

Start State Parameters 
+++++++++++

.. code-block::
    :caption: Start State Parameters Demo

    fn main {
        #StartStateParameters($("#StartStateParameters started"))
    }

    #StartStateParameters [$[msg]]

        -machine-

        $Start [msg]
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
        #StartStateEnterParameters(>("#StartStateEnterParameters started"))
    }

    #StartStateEnterParameters [>[msg]]

        -machine-

        $Start 
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
        #SystemDomainParameters(#("SystemDomainParameters started"))
    }

    #SystemDomainParameters [#[msg]]

        -machine-

        $Start 
            |>| print(msg) ^

        -domain-

        var msg = nil 

    ##

Run the `program <https://onlinegdb.com/6W0B4Mgap>`_. 

.. code-block::
    :caption: System Domain Parameters Demo Output 

    SystemDomainParameters started