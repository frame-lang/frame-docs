==================
Functions
==================

In the v0.11 version of the Framepiler, Frame only supports a single function which must 
be the *main* function. 

.. note:: In the next release (v0.12) Frame will provide general support for any number of functions as well 
          and any number of system specifications.  

.. code-block::
    :caption: Basic Main Function

  fn main {
  }

.. code-block::
    :caption: Default Main Function

    fn main {
    }

Frame allows system arguments to be passed to main in a simplistic way. By specifying 
parameters in main, Frame will map the number of system arguments to them. Frame 
does not check if the arguments exist. 

.. note:: 
    
    In future releases, Frame will provide more standardized support for system arguments.  

.. code-block::
    :caption: Main with System Arguments

    `import sys`

    fn main [sys_arg1, sys_arg2, sys_arg3] {
    }


Notice also that it is necessary to use a superstring to import **`import sys`** to have 
access to the system arguments in Python. 

In addition to accepting parameters, Frame also supports returning a value from main.

.. code-block::
    :caption: Returning a Value from Main

    fn main : int {
        ^(0)
    }

The following program is a trivial Frame program with a **main()** that accepts system arguments. 
For this demo the argments are "Hello" and "5".

.. code-block::
    :caption: Main with System Arguments

    `import sys`

    fn main [msg, count] : int {
        loop var x = 1; x <= int(count); x = x + 1 {
            x == 3 ? print("Its the 3rd message") :
                    print(str(x) + ") " + msg)   :|       
        }

        ^(0)
    }

Run the `program <https://onlinegdb.com/zFJ9uoGYB>`_. 

.. code-block::
    :caption: Main with System Arguments Output

    1) Hello
    2) Hello
    Its the 3rd message
    1) Hello
    2) Hello

