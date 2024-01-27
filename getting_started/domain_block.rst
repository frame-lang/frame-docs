============
Domain Block
============

Declaring Domain Data
-----------------

System data is declared in the `-domain-` block.

.. code-block::
    :caption: Sample Domain Syntax

    -domain-

    var item_id = newId()           // untyped variable with expression intitializer
    var name:string = "Boris"       // typed variable
    var s:`[]int` = `[6]int{2, 3, 5, 7, 11, 13}[1:4]` // custom type and initalization expr

Domain variables follow the 
general declaration syntax discussed in the
:ref:`variable_declarations` section.

All actions and event handlers can access the domain data by referencing the variable identifier.
Below we can see references from both contexts to the domain variable *name*: 

.. code-block::
    :caption: Sample Domain Syntax

    -machine-

    $Ready
        |displayName|  
            print("My name is " + name) ^  

    -actions-

    printName {
        print("My name is " + name) 
    }

    -domain-

    ...
    
    var name:string = "Boris"       // typed variable

With this in mind, we can conclude our Hello World saga by utilizing domain variables  
to provide the required data for the famous greeting.

.. code-block::
    :caption: Hello World! Again!

    fn main {
        var hws:# = #HelloWorldWithDomainSystem()
        hws.sayHello()
        hws.sayWorld()
    }

    #HelloWorldWithDomainSystem

        -interface-
        
        sayHello 
        sayWorld

        -machine-

        $Hello
            |sayHello|  
                actionWriteHello() // call action
                -> $World 
                ^       
        $World    
            |sayWorld|  
                actionWriteWorld() // call action
                -> $Done 
                ^     

        $Done 

        -actions- 

        actionWriteHello {
            actionWrite(hello_txt, " ") // use domain variable
        }

        actionWriteWorld {
            actionWrite(world_txt, "") // use domain variable
        }    

        actionWrite [msg,separator] {
            print(msg, end=separator)
        }

        -domain-

        var hello_txt = "Hello"
        var world_txt = "World!"

    ##

Admittedly this is a lot of Frame code to replace a single line of C code. However it does serve to both
introduce a good swath of Frame syntax as well as fulfill the obligation to provide a 
"Hello World!" program for a new language. 

You can try running the most complex Hello World `program ever here`_.

.. _program ever here: https://onlinegdb.com/5aVZatJOA