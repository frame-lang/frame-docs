==================
Loops
==================

Frame currently supports two types of loops.

#. While-like loops 
#. For-like loops 

 
Frame also supports the typical loop control flow keywords **break** and **continue**. 


.. note:: Frame will support for-in-like loops when array/list syntax is specified.

The following examples all do the same thing - loop from 0 to 4 and remove 3 from all output. 

While-Like Loops
-----------

The Frame syntax for while-like loops is very simple:


.. code-block::
    :caption: While-like loops 

    loop {
        <statements>
    }
 
.. code-block::
    :caption: While-like loop example

    fn main {

        var y:int = -1
        loop {
            y = y + 1
            y == 3 ? continue  :>
            y == 5 ? break     :|
            print(y)
        }
        print("done while-like loop")
    
    }


Run the `program <https://onlinegdb.com/BK4JURUeV>`_. 

.. code-block::
    :caption: While-like loop example output

    0
    1
    2
    4
    done while-like loop

For-Like Loops
-----------

.. code-block::
    :caption: For-Like Loop Example

    fn main {

        loop var x = 0; x < 5; x = x + 1 {
            x == 3 ? continue  :|
            print(x)
        }
        print("done for-like loop")
    
    }

Run the `program <https://onlinegdb.com/3u4yXwd9D>`_. 

.. code-block::
    :caption: While-like loop example output
        
    0
    1
    2
    4
    done for-like loop

Nested Loops 
------

Loops, of course, can be nested inside each other. The next example shows 
all permutations of nesting while and for like loops.


.. code-block::
    :caption: Nested Loops

    fn main {

        print("done while-like loop")

        // for-like loop (a) outside 
        // for-like loop (b) inside

        loop var a = 0; a < 5; a = a + 1 {
            a == 3 ? continue  :|
            loop var b = 0; b < 5; b = b + 1 {
                b == 3 ? continue  :|
                print(str(a) + str(b))
            }
        }
        print("done ab loops")

        // for-like loop (c) outside 
        // while-like loop (d) inside

        loop var c = 0; c < 5; c = c + 1 {
            c == 3 ? continue  :|
            var d :int = -1
            loop {
                d = d + 1
                d == 3 ? continue  :>
                d == 5 ? break     :|
                print(str(c) + str(d))
            }
        }   

        print("done cd loops")

        // while-like loop (e) outside 
        // for-like loop (f) inside

        var e:int = -1
        loop {
            e = e + 1
            e == 3 ? continue :>
            e == 5 ? break    :|
            loop var f:int = 0; f < 5; f = f + 1 {
                f == 3 ? continue  :|
                print(str(e) + str(f))
            }
        }

        print("done ef loops")

        // while-like loop (g) outside 
        // while-like loop (h) inside

        var g:int = -1
        loop {
            g = g + 1
            g == 3 ? continue :>
            g == 5 ? break    :|
            var h:int = -1
            loop  {
                h = h + 1
                h == 3 ? continue :>
                h == 5 ? break    :|
                print(str(g) + str(h))
            }
        }

        print("done gh loops")
    }


Run the `program <https://onlinegdb.com/L49OFgaCWm>`_. 

.. code-block::
    :caption: Nested Loops output
        
    00
    01
    02
    04
    10
    11
    12
    14
    20
    21
    22
    24
    40
    41
    42
    44
    done ab loops
    00
    01
    02
    04
    10
    11
    12
    14
    20
    21
    22
    24
    40
    41
    42
    44
    done cd loops
    00
    01
    02
    04
    10
    11
    12
    14
    20
    21
    22
    24
    40
    41
    42
    44
    done ef loops
    00
    01
    02
    04
    10
    11
    12
    14
    20
    21
    22
    24
    40
    41
    42
    44
    done gh loops
