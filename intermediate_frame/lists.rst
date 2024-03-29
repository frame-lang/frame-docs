==================
Lists
==================

Frame supports a basic list notation similar to Python. 

.. code-block::

    // empty list 

    var empty_list = []

    // initialized list 

    var initialized_list = [1,"foo", true]

Populated list elements can be updated in assignments:

 .. code-block::

    var l = [false]

    l[0] = true

Frame does not support any builtin operations on lists but instead relies on Python (and other languages
in the future) to do more sophisticated list operations. 

 .. code-block::
   
    // use Python functions and methods on lists

    my_list.append("foo")
    print(my_list)

Lists can be iterated over using loops.

.. code-block::


    fn main {
        var l = [0,1,2]

        print("l = " + str(l)) 

        loop var i = 0; i < len(l); i = i + 1 {
            print("l[" + str(i) + "] = " + str(l[i]))
        }

        loop var i = 0; i < len(l); i = i + 1 {
            l[i] = i + 10
            print("l[" + str(i) + "] = " + str(l[i]))
        }
    }

The program generates the following output:

.. code-block::
    :caption: Looping over lists

    l = [0, 1, 2]
    l[0] = 0
    l[1] = 1
    l[2] = 2
    l[0] = 10
    l[1] = 11
    l[2] = 12