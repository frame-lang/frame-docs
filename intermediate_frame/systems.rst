==================
Systems
==================

Frame's focus is on helping softwre architects and developers design systems.
Frame uses the **#** token special type token to identify a system.  

.. code-block::
    :caption: System Declaration 

    #MySystem // System declaration

    ##        // System terminator 

The token **##** indicates the end of the system definition.


.. code-block::
    :caption: System Instance Launch  

    fn main {

        // No Parameters Demo 

        #NoParameters()
    }

    #NoParameters

        -machine-

        $Start
            |>| print ("#NoParameters started") ^
    ##

Run the `program <https://onlinegdb.com/Q6sB6hmvQ>`_. 

.. code-block::
    :caption: System Instance Launch Output 
    
    #NoParameters started

Above we can see **#SystemParams1** is instantiated in **main**. Upon launch, the system is sent 
a **>** message which is handled in the start state and prints "System1 started".

System Parameters 
-----------

Frame provides a way to pass initialization arguments to systems. There are three 
kinds of system data that can be initialized:

#. Start state parameters
#. Start state enter event parameters
#. Domain data

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