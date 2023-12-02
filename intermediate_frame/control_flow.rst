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

Boolean tests have the following syntax:

.. code-block::
    :caption: Frame Boolean Test Statement

    <boolean_expresion> ('?' | '?!') <true_statements> ':' <false_statements> ':|'

.. list-table:: Title
   :widths: 25 25 50
   :header-rows: 1

   * - Heading row 1, column 1
     - Heading row 1, column 2
     - Heading row 1, column 3
   * - Row 1, column 1
     -
     - Row 1, column 3
   * - Row 2, column 1
     - Row 2, column 2
     - Row 2, column 3


.. list-table:: State Stack Operators
    :widths: 25 25 50
    :header-rows: 1

    * - Operator
      - Name
      - Purpose
    * - '?' | '?!'
      - Boolean Test Operators
      - Indicates the statement is a test of the preceeding expression
    * - ':'
      - Else Operator (optional)
      - Performs as an 'else' in other languages
    * - ':|'
      - Test Terminator Token
      - Closes test statement  




.. code-block::
    :caption: TODO

    var x:bool = true
    x ? print("x is true") :|

```
    x ?<type> <branches> : <else clause> ::
```

The `:` token is "else" and `::` terminates the statement for all branching statement types.

Let's explore the boolean test first.

## Boolean Tests

The basic boolean test in Frame is:

```
    x ? callIfTrue() : callIfFalse() ::
```
This generates this in `C#`:
{% highlight csharp %}
    if (x) {
        callIfTrue_do();
    } else {
        callIfFalse_do();
    }
{% endhighlight %}

To reinforce the point that branching in Frame is not an expression evaluation, see how we can call multiple statements inside each branch:

`Frame`
```
x ?
    a()
    b()
:
    c()
    d()
::
```
`C#`
{% highlight csharp %}
    if (x) {
        a_do();
        b_do();
    } else {
        c_do();
        d_do();
    }
{% endhighlight %}


To negate the test use the `?!` operator:

`Frame`
```
x ?! callIfFalse() : callIfTrue() ::
```
`C#`
{% highlight csharp %}
    if (!(x)) {
        callIfFalse_do();
    } else {
        callIfTrue_do();
    }
{% endhighlight %}

Next we will explore the Frame equivalent of the switch statement for string matching.

## Pattern Matching Statements

Frame uses a novel but easy to understand notation for switch-like statements:

```
test ?<type>
    /pattern1/ statements :>
    /pattern2/ statements :
               statements ::
```

The currently supported operators are `?~` for string matching and `?#` for number/range matching. The `:` token indicates else/default and `::` terminates the pattern matching statement.

## String Matching

The string matching statement looks like this:

`Frame`
```
name() ?~
    /Elizabeth/ hiElizabeth()   :>
    /Robert/    hiRobert()      :
                whoAreYou()     ::
```
And results in this code:

`C#`
{% highlight csharp %}
    if (name_do() == "Elizabeth") {
        hiElizabeth_do();
    } else if (name_do() == "Robert") {
        hiRobert_do();
    } else {
        whoAreYou_do();
    }
{% endhighlight %}

Frame also permits multiple string matches per pattern:

`Frame`
```
name() ?~
    /Elizabeth|Beth/ hiElizabeth()   :>
    /Robert|Bob/     hiRobert()      :
                     whoAreYou()     ::
```
With this output:

`C#`
{% highlight csharp %}
    if (name_do() == "Elizabeth") || (name_do() == "Beth") {
        hiElizabeth_do();
    } else if (name_do() == "Robert") || (name_do() == "Bob") {
        hiRobert_do();
    } else {
        whoAreYou_do();
    }
{% endhighlight %}

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