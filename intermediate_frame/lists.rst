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

Lists can be iterated over using loops. Frame supports both index-based iteration and the more convenient ``for in`` syntax:

.. code-block::

    fn main() {
        var l = [0,1,2]
        var fruits = ["apple", "banana", "cherry"]

        print("l = " + str(l)) 

        // Index-based iteration
        print("Iterating over list using index iteration:")
        for var i = 0; i < len(l); i = i + 1 {
            print("l[" + str(i) + "] = " + str(l[i]))
        }

        // Element iteration with for in
        print("Iterating over fruits:")
        for fruit in fruits {
            print("Fruit: " + fruit)
        }
    }

The program generates the following output:

.. code-block::
    :caption: List iteration examples

    l = [0, 1, 2]
    Iterating over list using index iteration:
    l[0] = 0
    l[1] = 1
    l[2] = 2
    Iterating over fruits:
    Fruit: apple
    Fruit: banana
    Fruit: cherry