==================
Actions Block
==================

To enable our `#HelloWorldSystem` to actually print "Hello World!" we need to be able to call a 
function to do that. Actions are the private methods of systems and a good place to do that. 

Let's see how to create one. 

Declaring Actions
-----------------

Actions are declared in the `-actions-` block and observe all of the method
declaration syntax discussed in the :ref:`methods` section. 

We will start by creating a utility action `actionWrite()` that will be reused by other actions to do 
the actual printing. This action will accept two parameters, **msg** and **separator**. The first parameter will be the string to 
write and the second will add any separator strings.

.. code-block::
    :caption: Actions in Python
 
    #HelloWorldSystem
        ...

        -actions- 

        ... 

        actionWrite [msg,separator] {
            // This is a call to the Python native 
            // print function.
            print(msg, end=separator) 
        }

    ##



Unlike Interface Methods, Actions can contain code, both Frame code as well as code from target languages. 
As this program is being transpiled into Python, we can use the built-in Python **print()** function
to do the actual printing.

.. code-block::
    :caption: Actions in Python
 
    #HelloWorldSystem
        ...

        -actions- 

        actionWriteHello {
            actionWrite("Hello", " ")
        }

        actionWriteWorld {
            actionWrite("World!", "")
        }  
        
        actionWrite [msg,separator] {
            // This is a call to the Python native 
            // print function.
            print(msg, end=separator) 
        }

    ##

Next we add the two specialized actions **actionWriteHello()** and **actionWriteWorld()**. As these 
actions take no parameters they do not have a parameter list (it would actually be an error to have 
an empty list). They in turn call **actionWrite()** and pass the appropriate message and separator values.

Finally we update our event handlers to call these actions:  

.. code-block::
    :caption: Hello World! in Frame

  fn main {
      var hws:# = #HelloWorldSystem()
      hws.sayHello()
      hws.sayWorld()
  }

  #HelloWorldSystem

      -interface-
      
      sayHello 
      sayWorld

      -machine-

      $Hello
          |sayHello|  
              actionWriteHello()
              -> $World 
              ^       
      $World    
          |sayWorld|  
              actionWriteWorld()
              -> $Done 
              ^     

      $Done 

      -actions- 

      actionWriteHello {
          actionWrite("Hello", " ")
      }

      actionWriteWorld {
          actionWrite("World!", "")
      }    

      actionWrite [msg,separator] {
          print(msg, end=separator)
      }

You can try running the `program here`_.

.. _program here: https://onlinegdb.com/eQntTfaiT

