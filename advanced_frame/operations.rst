Operations
==========

Frame's syntax is focused on the modeling, design and implementation of systems 
using state machines. Frame's basic syntax  restricts access to the system through
the system intialization parameters and interface.

However it is in some cases desirable to have direct access to the inner workings of 
the system. To facilitate this use case, Frame supports **Operations**. Operations 
are publically accessible access calls that do not create FrameEvents or interact 
with the state machine. 

Operations are declared in the **-operations-** block which must be declared, if it 
exists, in the following block order:


.. code-block::
    :caption: Operations Block Position

    #OperationsBlock

        -interface-
        -machine-
        -actions-
        -operations- 
        -domain-

    ##


.. code-block::
    :caption: Operations Block Position

    #OperationsBlock

        -interface-
        -machine-
        -actions-
        -operations- 
        -domain-

    ##

Operations follow the same syntax as inteface calls and actions:

.. code-block::
    :caption: Operations Block Position

    #Operations

        -operations- 

        basic
        deluxe [p1:T,p2:T] : T {
            ^(p1 + p2)
        }

    ##


One of the important use cases for operations is to support testing scenarios 
by providing a means of inspecting the raw state without engaging the state machine.

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

Operations can be associated with the system type rather than an instance of a system.
These kinds of operations are called **static** operations which are oranized as a library 
of routines accessible by the system type. 

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

As seen above, 

Static operations can not access data of any system instance. Additionally, Frame 
does not currently support any concept of static data related to the type of a system
so does not have special access to that kind of data either. 


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


