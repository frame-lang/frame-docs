==================
Enumerated Types
==================

Enumerated types in Frame are declared in the domain block for a system. 

.. note:: Frame v0.12 will support global enumerated types as well. 

Enums are C style simple enums declared in the Domain block of a spec. 
Enum names have no restriction on case but are case sensitive.

.. code-block::
    :caption: System Enums
        
    #CalendarSystem

        -domain-

        enum Days {
            SUNDAY
            monday
            Tuesday
            WEDNESDAY
            tHuRsDaY
            FRIDAY	
            SATURDAY
            SUNDAY
        }

    ##

Enums can be assigned specific integer values, which also can be repeated.


.. code-block::
    :caption: System Enum Values

    enum Days {
        SUNDAY
        monday
        Tuesday = 1000
        WENESDAY
        tHuRsDaY
        FRIDAY	
        SATURDAY = 1000
        SUNDAY = 2000
    }

The values assigned start at 0 and will increase by one until an assignment is reached, at which point the counter will be set to that value.

Enums can be used anywhere a literal numeric value can be used. 

.. code-block::
    :caption: System Enum Values

    #Grocery

        -domain-

        enum Fruit {
            Peach
            Pear
            Bannana
        }
    ##

Enum values can be assigned to variables and passed as arguments as well as returned by methods.

.. code-block::
    :caption: Enum Usage

        getFruitOfTheDay : Fruit {
            var fruit_of_the_day:Fruit = Fruit.Pear
            ^(fruit_of_the_day)
        }

Equality Test Control Flow with Enum
------------

Enums can be tested for equality using the **==** operator. 

.. code-block::
    :caption: Enum Equality Comparison

    var f:Fruit = getFruitOfTheDay()

    f == Fruit.Peach   ? print("Found a Peach")   :>
    Fruit.Pear == f    ? print("Found a Pear")    :> 
    f == Fruit.Bannana ? print("Found a Bannana") :|

Match Test Control Flow with Enums
------------

Enums have their own control flow syntax for tests.

.. code-block::
    :caption: Enum Test Syntax 

    enum_variable ?:(EnumType)
        :/enum_value_1/ <statements> :>
        :/enum_value_2/ <statements> :>
        :/enum_value_3/ <statements> :  
                <default_statements> :|

Below we can see that a variable **fruit_value** of enum type **Fruit** is tested to 
match one of three values and print the name. If not found, the else clause prints
"Other Fruit". 

.. code-block::
    :caption: System Enum Values

    fruit_value ?:(Fruit) 
        :/Peach/    print("Peaches")     :> 
        :/Pear/     print("Pears")       :> 
        :/Bannana/  print("Bannanas")    :
                    print("Other Fruit") :|


.. code-block::
    :caption: Enum Grocery Demo


    `from enum import Enum`
    `import random`

    fn main {
        var grocery:# = #Grocery()
        print("We are selling " + grocery.getFruitOfTheDay() + " today.")
        print("We sold " + grocery.getFruitOfTheDay() + " yesterday.")
        print("We are selling " + grocery.getFruitOfTheDay() + " tomorrow.")
    }

    #Grocery

        -interface-

        getFruitOfTheDay : String 

        -machine-

        $Start 
            |getFruitOfTheDay| : String

                var f:Fruit = getFruitOfTheDay()

                // Demonstrate boolean tests for enums
                
                f == Fruit.Peach  ? print("Found a Peach.")  :>
                Fruit.Pear == f   ? print("Found a Pear.")   :> 
                f == Fruit.Banana ? print("Found a Banana.") :|

                // Demonstrate enum matching

                f ?:(Fruit) 
                    :/Peach/   ^("Peaches") :> 
                    :/Pear/    ^("Pears")   :> 
                    :/Banana/  ^("Bananas") :| 

                ^("None")

        -actions-

        getFruitOfTheDay : Fruit {
            var val = random.randint(1, 3)

            val ?#
                #/1/ ^(Fruit.Peach)  :>
                #/2/ ^(Fruit.Pear)   :>
                #/3/ ^(Fruit.Banana) :|
        }

        -domain-

        enum Fruit {
            Peach
            Pear
            Banana
        }
    ##

Run the `program <https://onlinegdb.com/YtpIPg0eY>`_. 

.. code-block::
    :caption: Grocery Demo Output

    Found a Pear.
    We are selling Pears today.
    Found a Banana.
    We sold Bananas yesterday.
    Found a Peach.
    We are selling Peaches tomorrow.





