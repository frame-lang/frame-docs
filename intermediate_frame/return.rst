==================
Returning Values
==================

.. code-block::
    :caption: Default Return Value for Interface Method

    fn main {
        var sys:# = #InterfaceReturnYes()
        print(sys.getDecision())
    }

    #InterfaceReturnYes

        -interface-

        getDecision ^("yes") 

    ##


Run the `program <https://onlinegdb.com/S5sG-PXIc>`_. 

.. code-block::
    :caption: Output

    yes

.. code-block::
    :caption: Override Return Value for Interface Method

    fn main {
        var sys:# = #InterfaceReturnNo()
        print(sys.getDecision())
    }

    #InterfaceReturnNo

        -interface-

        getDecision ^("yes") 

        -machine-

        $No 
            |getDecision| 
                ^("no") 

    ##

Run the `program <https://onlinegdb.com/hIsyGz2Mh`_. 

.. code-block::
    :caption: Output

    no

.. code-block::
    :caption: Overriding an Override    

    fn main {

        var sys:# = #InterfaceReturnMaybe()
        print(sys.getDecision())
    }

    #InterfaceReturnMaybe

        -interface-

        getDecision ^("yes") 

        -machine-

        $No 
            |getDecision| 
                -> $Maybe ^("no") 
        
        $Maybe
            |>| 
                ^("maybe")

    ##


Run the `program <https://onlinegdb.com/dq0JN5HbB>`_. 

.. code-block::
    :caption: Output

    maybe

.. code-block::
    :caption: ^= Operator to Set Return Value 

    fn main {

        var sys:# = #InterfaceReturnMaybeAnotherWay()
        print(sys.getDecision())
    }

    #InterfaceReturnMaybeAnotherWay

        -interface-

        getDecision ^("yes") 

        -machine-

        $No 
            |getDecision| 
                -> $Maybe ^("no") 
        
        $Maybe
            |>| 
                ^= "maybe another way" 
                ^

    ##

Run the `program <https://onlinegdb.com/d4zJ-s_Vr>`_. 

.. code-block::
    :caption: Output

    maybe another way


.. code-block::
    :caption: System Init Return Behavior 

    fn main {

        var sys:# = #InterfaceReturnSurprise()
        print(sys.getDecision())
    }

    #InterfaceReturnSurprise

        -interface-

        getDecision ^("yes - surprised?") 

        -machine-

        $No 
            |>| 
                -> $Maybe ^("no") 
        
        $Maybe
            |>| 
                ^= "maybe another way" 
                ^
    ##    

Run the `program <https://onlinegdb.com/tGAmJI8U0L>`_. 

.. code-block::
    :caption: Output

    yes - surprised?