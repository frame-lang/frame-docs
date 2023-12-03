==================
Control Flow
==================


Frame control flow has a compact syntax for various forms of control flow branching.  
It is inspired by the 'C' langauge ternary expression:

.. code-block::
    :caption: 'C' langauge ternary syntax

    condition ? value_if_true : value_if_false

The following example sets the variable **x** to 10:

.. code-block::
    :caption: Tenary Expression Example

    int a = 10, b = 20, x;

    x = (a < b) ? a : b; // x = a


In 'C' the ternary operator is an expression that returns a value. Above we see 
that **x** is assigned the value of **a** which is 10. 

Frame takes a different approach and uses simlar syntax as a statement, not an expression. 
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
In contrast, use of the "Else Continue" operator with the same tests from above
will result in only one clause selected for each increment of y in the loop. 
Additionally, this demo provides an else clause if none of the conditioned branches 
match the test criteria. 

.. code-block::
    :caption: Individual Equality Tests Demo

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
Each match type has a different match test format:


.. list-table:: Match Test Tokens

    :header-rows: 1

    * - Match Test Type
      - Test Operator
      - Match Operator
    * - Boolean 
      - ? | ?!
      - N/A
    * - String 
      - ?~
      - ~/<string>/
    * - Number
      - ?#
      - #/<number>/
    * - Enumerator
      - ?:(EnumType) 
      - :/<enum_value>/

String Matching
++++++++++

.. code-block::
    :caption: String Matching Test Grammar

    <reference_string> '?~' 
                        ( '~/' <match_string> ( '|' <match_string> )* '/' statements*
                        ( ':>' ( '~/' <match_string> '/' statements* )* 
                        ( ':' <if_false_statements> )? ':|'

String match tests determine if a test string is equal to one or more options. If so, 
the following statements are executed. 

.. code-block::
    :caption: String Matching Test Examples 

    letter ?~
        ~/a|e|i|o|u/    vowel(letter)     :>
        ~/y/            notSure(letter)   :>
        :               consonant(letter) :|

    food ?~
        ~/Pea|Potato/     logFoodKind("Vegetable")  :>
        ~/Apple|Bananna/  logFoodKind("Fruit")      :>
        ~/Kansas|City/    logFoodKind("Not a food") :>
        :                 logFoodKind("Not sure")   :|

## Number Matching

Number matching is very similar to string pattern matching:

`Frame`
```
n ?#
    /1/ print("It's a 1")   :>
    /2/ print("It's a 2")   :
        print("It's a lot") ::
```
The output is:

`C#`
{% highlight csharp %}
    if (n == 1)) {
        print_do("It's a 1");
    } else if (n == 2)) {
        print_do("It's a 2");
    } else {
        print_do("It's a lot");
    }
{% endhighlight %}

Frame can also pattern match multiple numbers to a single branch as well as compare decimals:

`Frame`
```
n ?#
    /1|2/           print("It's a 1 or 2")  :>
    /101.1|100.1/   print("It's over 100")  :
                    print("It's a lot")     ::
```
The output is:

`C#`
{% highlight csharp %}
    if (n == 1) || (n == 2)) {
        print_do("It's a 1 or 2");
    } else if (n == 101.1) || (n == 100.1)) {
        print_do("It's over 100");
    } else {
        print_do("It's a lot");
    }
{% endhighlight %}

## Branches and Transitions

The default behavior of Frame is to label transitions with the message that generated the transition. This is fine when an event handler only contains a single transition:

`Frame`
```
#GottaBranch

  -machine-

    $A
        |e1| -> $B ^

    $B

##
```

![](https://www.plantuml.com/plantuml/png/SoWkIImgAStDuG8oIb8L71MgkMgXR2SmErehLa5Nrqx1aSiHH0D5hHJKb0sDJAnJ3I4qbqDgNWhG2000)

However this leads to ambiguity with two or more transitions from the same event handler:

`Frame`
```
#GottaBranch_v2

  -machine-

    $Uncertain
        |inspect|
            foo() ?
                -> $True
            :
                -> $False
            :: ^

    $True

    $False

##
```

![](https://www.plantuml.com/plantuml/png/SoWkIImgAStDuG8oIb8LGlEIKujA4ZFp5AgvQg5Y8KMbgKXSjyISOWW_MYjMGLVN3g692yu2YKCqMYceAHiQcLXdvXKNf2QNG3Ye2i56ubBfa9gN0dGV0000)

Transition labels provide clarity as to which transition is which:

`Frame`
```
#GottaBranch_v3

  -machine-

    $Uncertain
        |inspect|
            foo() ?
                -> "true foo" $True
            :
                -> "foo not true" $False
            :: ^

    $True

    $False

##
```

![](https://www.plantuml.com/plantuml/png/SoWkIImgAStDuG8oIb8LGlEIKujA4ZFp5AgvQg5Y8KMbgKXSjyISOWW_MYjMGLVN3g692yu2YKCqMYcKWAYq_7nKMQWvLY0PXRpy4h0oBeVKl1IWQm00)


## Conclusion

The three core branching statements - boolean test, string pattern match and number pattern match - provide a surprisingly useful set of functionality for most common branching needs despite currently being rather limited in expressive power. Look for advancement in the robustness and capability of the pattern matching statements in the future.