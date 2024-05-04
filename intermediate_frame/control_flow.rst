==================
Control Flow
==================


Frame control flow has a compact syntax for various forms of branching.  
It is inspired by the 'C' language ternary expression:

.. code-block::
    :caption: 'C' language ternary syntax

    condition ? value_if_true : value_if_false

The following example sets the variable **x** to 10:

.. code-block::
    :caption: Ternary Expression Example in C

    int a = 10, b = 20, x;

    x = (a < b) ? a : b; // x = a


In 'C' the ternary operator is an expression that returns a value. Above we see 
that **x** is assigned the value of **a** which is 10. 

In contrast, Frame uses similar syntax as a statement and not an expression. 
This means that no values are returned for assignment. Let's see how this works in 
a simple boolean test first.

Boolean Tests 
--------

Frame supports both an "if-then-else" syntax as well as optional "else-if" clauses. Frame 
uses special tokens instead of keywords for this syntax.

.. list-table:: Boolean Test Operators
    :widths: 25 25 50
    :header-rows: 1

    * - Operator
      - Name
      - Purpose
    * - ? | ?!
      - Boolean Test Operators
      - Test if condition is true or not true
    * - :>
      - Else Continue Operator (optional)
      - Performs as an 'else if' in other languages
    * - :
      - Else Operator (optional)
      - Performs as an 'else' in other languages
    * - :|
      - Test Terminator Token 
      - Ends a Boolean test


Boolean tests have the following syntax:

.. code-block::
    :caption: Frame Boolean Test Syntax

    <condition> ('?' | '?!') <if_true_statements> 
                ( ':>' <condition> ('?' | '?!') <else_if_statements> )* 
                ( ':' <if_false_statements> )? ':|'

Boolean tests support "if" and "if not" conditions as well as an "else" clause as shown here: 

.. code-block::
    :caption: Basic Boolean Tests Demo

    var x:bool = true
    x ? print("x is true") :|

    x = true 
    x ? print("x is true")  :
        print("x is false") :|

    x = false 
    x ? print("x is true")  :
        print("x is false") :|

    x = true 
    x ?! print("x is true")  :
         print("x is false") :|

    x = false 
    x ?! print("x is true")  :
         print("x is false") :|

The output of the code above is shown here: 

.. code-block::
    :caption: Basic Boolean Tests Demo Output 

    x is true
    x is true
    x is false
    x is false
    x is true

Equality Tests 
--------

To highlight uses of the test syntax, the next demo shows output of a series of tests 
organized as "if" statements. In this demo, multiple tests can be true for a given 
value of y in the loop. 

.. code-block::
    :caption: Individual Equality Tests Demo

    print("y|")
    print("--")
    loop var y = 0; y <= 5; y = y + 1 {
        prefix = str(y) + "| "
        y == 0 ? print(prefix + "y == 0") :|
        y == 1 ? print(prefix + "y == 1") :|
        y <  2 ? print(prefix + "y <  2") :|
        y >= 3  && y < 4 ? print(prefix + "y >= 3  && y < 4") :|        
    }    

.. code-block::
    :caption: Individal Equality Tests Demo

    y|
    --
    0| y == 0
    0| y <  2
    1| y == 1
    1| y <  2
    3| y >= 3  && y < 4

Frame also supports an if-then-else syntax as well. 
Using the tests from above but with the "Else Continue" operator instead of the test terminator 
will result in only one clause selected for each increment of y in the loop. 
Additionally, this demo provides an else clause if none of the conditioned branches 
match the test criteria. 

.. code-block::
    :caption: Test-Else-Continue Equality Tests Demo

    print("y|")
    print("--")
    loop var y = 0; y <= 5; y = y + 1 {
        prefix = str(y) + "| "
        y == 0 ? print(prefix + "y == 0") :>
        y == 1 ? print(prefix + "y == 1") :>
        y <  2 ? print(prefix + "y <  2") :>
        y >= 3  && y < 4 ? print(prefix + "y >= 3  && y < 4") :
                           print(prefix + "No match") :|        
    }    

.. code-block::
    :caption: Individal Equality Tests Demo

    y|
    --
    0| y == 0
    1| y == 1
    2| No match
    3| y >= 3  && y < 4
    4| No match
    5| No match


Run the `program <https://onlinegdb.com/YQPlNSxCf>`_. 

Matching Tests
-----------------

Frame supports a number of testing variants based on a standardized matching syntax.
Each match type has a different match test format

.. list-table:: Match Test Tokens
    :header-rows: 1

    * - Match Test Type
      - Test Operator
      - Single Match  
      - Multiple Match  
      - Special Tokens
    * - Boolean 
      - ? | ?!
      - N/A
      - N/A
      - N/A
    * - String 
      - ?~
      - ~/Roy/
      - ~/Alice|Bob/
      - | ~// (empty string)
        | !// (null)
    * - Number
      - ?#
      - #/42/
      - #/1|2|3/ 
      - N/A
    * - Enumerator
      - ?:(EnumType) 
      - :/Apple/
      - :/Peach|Pear/
      - N/A

As shown in the table, if multiple values should match a branch, separate each by a '|' token.


String Matching
++++++++++

.. code-block::
    :caption: Basic String Matching Test Grammar

    <reference_string> '?~' 
                        ( '~/' <match_string> ( '|' <match_string> )* '/' statements*
                        ( ':>' ( '~/' <match_string> '/' statements* )* 
                        ( ':' <if_false_statements> )? ':|'

String match tests determine if a test string is equal to one or more options. If so, 
the associated statements are executed. 


.. code-block::
    :caption: String Matching Examples 

    letter ?~
        ~/a|e|i|o|u/    vowel(letter)     :>
        ~/y/            notSure(letter)   :>
        :               consonant(letter) :|

    food ?~
        ~/Pea|Potato/     logFoodKind("Vegetable")  :>
        ~/Apple|Bananna/  logFoodKind("Fruit")      :>
        ~/Kansas|City/    logFoodKind("Not a food") :>
        :                 logFoodKind("Not sure")   :|


The string match syntax has two special match operators for **empty strings** and **null** 
values. String matching uses the token **~** to differentiate the match type. 

.. code-block::
    :caption: Special String Matching 

    name ?~
        ~/Alice|Bob/    log("person")       :>
        ~//             log("empty string") :>
        !//             log("null")         :>
        :               log("unknown")      :|

Number Matching
++++++++++

Number matching follows the same pattern as string matching but does not have any special 
match patterns. Number matching uses the token **#** to differentiate the match type. 

.. code-block::
    :caption: Number Matching Tests

    number ?#
        #/1|2/        log("small")      :>
        #/3|4/        log("medium")     :>
        #/5|6/        log("large")      :>
        #/1.2|7.1/    log("mixed")      :>
        :             log("unknown")    :|

Enumeration Value Matching
++++++++++

Enumeration matching follows a similar pattern as string matching but does not have any special 
match patterns. Enumeration matching uses the token **:** to differentiate the match type
and also requires identifying the enum type in the test token. 

.. code-block::
    :caption: Enumeration Matching 

    today ?:(Day) 
        :/Monday/                       print("I don't like today") :>
        :/Tuesday|Wednesday|Thursday/   print("Not great either.")  :>
        :/Friday/                       print("Pretty good day")    :>
        :                               print("Yea!")               :|

