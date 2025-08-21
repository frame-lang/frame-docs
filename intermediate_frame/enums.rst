==================
Enumerated Types
==================

Enumerated types in Frame are declared in the domain block for a system. 

.. note:: Frame v0.20 supports system-level enumerated types. Global enums are planned for future versions.

Enums are C-style simple enums declared in the domain block of a system. 
Enum names have no restriction on case but are case sensitive.

.. code-block:: frame
    :caption: System Enums
        
    system CalendarSystem {
        domain:
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
    }

Enums can be assigned specific integer values, which also can be repeated.

.. code-block:: frame
    :caption: System Enum Values

    system CalendarSystem {
        domain:
            enum Days {
                SUNDAY
                monday
                Tuesday = 1000
                WEDNESDAY
                tHuRsDaY
                FRIDAY	
                SATURDAY = 1000
                SUNDAY = 2000
            }
    }

The values assigned start at 0 and will increase by one until an assignment is reached, at which point the counter will be set to that value.

Enums can be used anywhere a literal numeric value can be used. 

.. code-block:: frame
    :caption: System Enum Declaration

    system Grocery {
        domain:
            enum Fruit {
                Peach
                Pear
                Banana
            }
    }

Enum values can be assigned to variables and passed as arguments as well as returned by methods.

.. code-block:: frame
    :caption: Enum Usage

    system FruitSystem {
        actions:
            getFruitOfTheDay(): Fruit {
                var fruit_of_the_day: Fruit = Fruit.Pear
                return fruit_of_the_day
            }
            
        domain:
            enum Fruit {
                Peach
                Pear
                Banana
            }
    }

Equality Test Control Flow with Enum
------------------------------------

Enums can be tested for equality using the **==** operator with standard if/elif/else statements.

.. code-block:: frame
    :caption: Enum Equality Comparison

    fn testFruit() {
        var f: Fruit = getFruitOfTheDay()

        if f == Fruit.Peach {
            print("Found a Peach")
        } elif f == Fruit.Pear {
            print("Found a Pear")
        } elif f == Fruit.Banana {
            print("Found a Banana")
        } else {
            print("Unknown fruit")
        }
    }

Switch-Style Control Flow with Enums
------------------------------------

For multiple enum value comparisons, use if/elif/else chains which provide clear, readable logic:

.. code-block:: frame
    :caption: Enum Multi-Value Testing

    fn describeFruit(fruit_value: Fruit) {
        if fruit_value == Fruit.Peach {
            print("Peaches")
        } elif fruit_value == Fruit.Pear {
            print("Pears") 
        } elif fruit_value == Fruit.Banana {
            print("Bananas")
        } else {
            print("Other Fruit")
        }
    }


.. code-block:: frame
    :caption: Enum Grocery Demo

    `from enum import Enum`
    `import random`

    fn main() {
        var grocery = Grocery()
        print("We are selling " + grocery.getFruitOfTheDay() + " today.")
        print("We sold " + grocery.getFruitOfTheDay() + " yesterday.")
        print("We are selling " + grocery.getFruitOfTheDay() + " tomorrow.")
    }

    system Grocery {
        interface:
            getFruitOfTheDay(): string

        machine:
            $Start {
                getFruitOfTheDay(): string {
                    var f: Fruit = getRandomFruit()

                    // Demonstrate boolean tests for enums and return
                    if f == Fruit.Peach {
                        print("Found a Peach.")
                        return "Peaches"
                    } elif f == Fruit.Pear {
                        print("Found a Pear.")
                        return "Pears"
                    } elif f == Fruit.Banana {
                        print("Found a Banana.")
                        return "Bananas"
                    }
                    
                    return "None"
                }
            }

        actions:
            getRandomFruit(): Fruit {
                var val = random.randint(1, 3)

                if val == 1 {
                    return Fruit.Peach
                } elif val == 2 {
                    return Fruit.Pear
                } elif val == 3 {
                    return Fruit.Banana
                } else {
                    return Fruit.Peach
                }
            }

        domain:
            enum Fruit {
                Peach
                Pear
                Banana
            }
    }

Run the `program <https://onlinegdb.com/YtpIPg0eY>`_. 

.. code-block::
    :caption: Grocery Demo Output

    Found a Pear.
    We are selling Pears today.
    Found a Banana.
    We sold Bananas yesterday.
    Found a Peach.
    We are selling Peaches tomorrow.





