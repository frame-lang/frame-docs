Operations
==========

Frame's mission is the design and implementation of systems 
using state machines. To that end Frame's core syntax restricts access to the system through
the system intialization mechanisms (system parameters) and the interface methods.

However it can be desirable to have direct access to the inner state of 
the system. To facilitate this use case, Frame supports **Operations**. Operations 
are publically accessible access calls that do not create FrameEvents or interact 
with the system state machine. 

Operations are declared in the **-operations-** block which must be declared, if it 
exists, in the following block order:


.. code-block::
    :caption: Operations Block Position

    #OperationsBlock

        -operations- 
        -interface-
        -machine-
        -actions-
        -domain-

    ##

Operations follow the same syntax as actions:

.. code-block::
    :caption: Operations Syntax

    #Operations

        -operations- 

        add [p1:T,p2:T] : T {
            ^(p1 + p2)
        }

    ##


One of the important use cases for operations is to support testing scenarios 
by providing a means of inspecting the raw state without interacting with the state machine.

.. code-block::
    :caption: Inspecting Domain Data with Operations

    fn main {

        var t:# = #Thermometer()
        print(t.getTemp())
    }

    #Thermometer

        -operations- 

        getTemp  {
            ^(temp)
        }

        -domain-

        var temp : float = 1234.5
        
    ##

Static Operations 
--------

Frame supports declaring operations to be static using the **#[static]** attribute. 

.. code-block::
    :caption: Static Operations

    fn main {

        var lib:# = #Library()
        print(lib.getGreeting("Bob"))
    }

    #Library

        -operations- 

        #[static]
        getGreeting [name] : string { 
            ^("Hello " + name + "!")
        }
        
    ##


Static operations cannot access data of any system instance. Additionally, Frame 
does not currently support any concept of static data as is common in some languages. 
Therefore static operations are currently limited to serving as a library of functions
related to the system type. While this is (currently) a very limited use case, 
this does have utility implementing a *persistence* mechansim for Frame systems. 
System persistance will be explored in a later article.

Below we can see a simple use case for creating static operations for a calculator system: 

.. code-block::
    :caption: Static Operations

    fn main {
        print(#Calc.add(1,1))
        print(#Calc.sub(1,1))
    }

    #Calc

        -operations- 

        #[static]
        add [a,b] { 
            ^(a+b)
        }
               
        #[static]
        sub [a,b] { 
            ^(a-b)
        }
        
    ##


