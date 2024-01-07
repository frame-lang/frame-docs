==========
Frame Basics
==========

This article will discuss core Frame syntax and concepts.

Comments
--------

Frame supports single line C style comments:

.. code-block::

    // this is a single line comment


Whitespace, Formatting, Expressions and Statements
--------

Frame synatax does not require nor restrict any particular use of whitespace for formatting. As Frame's 
grammar does not require it, Frame does not have any need for a token to indicate the end of a statement (like ';'). 

Frame expressions are typical syntax constructs that return values. No control structure syntax serves 
as an expression. 

Superstrings 
------------

One way Frame can be loosely characterized is as a templated Domain Specific Langauge (DSL) for system design
in other languages. As Frame does not (currently) generate executable programs but instead transpiles Frame programs into 
other programming languages, one of the biggest challenges is to properly handle target language types and 
syntax that Frame does not directly support. 

One way in which Frame generically accomodates other language sytnax is in the use of **superstrings**. Frame 
superstrings are enclosed in either a pair of single backticks for inline needs or three 
backticks for a block of content: 

.. code-block::
    :caption: Frame superstring syntax 

    var foo:`&[**]!` = `%#@!$%`    

    ```
    Block of arbitrary
    content in the target language
    ```

Superstrings are not parsed by Frame and are simply passed through to the code generator for the target language. 

.. _variable_declarations:

Variable and Parameter Declarations
-----------------------------------

Variables and parameter declarations share a common syntax for identifier typing. For both, there 
are three type options:

#. Untyped identifiers
#. Typed identifiers
#. Superstring typed identifiers

Frame variables are declared using the **var** keyword, can be typed or untyped and must be initialized. 

.. code-block::
    :caption: Basic Variable Declarations

    var x = 0  
    var name:String = "Spock"

Frame variables do not require a type but the target language may. 
If a variable has a type the Framepiler will generate it if the target language is a typed language.  
Conversely, if a variable declaration does not have a type and the target language is typed,
Frame will generate `:<?>`. This invalid type token is intended to generate an error when the program is compiled. 

As discussed in the superstring section above, Frame genericially supports any type declaration for any language 
using superstrings. Here is an example from Golang that would parse using superstrings but not as a native 
Frame type syntax:

``golang``

.. code-block::
    :caption: Superstring Typed Variable Declaration

    // var <name>:<`type`> = <intializer_expr>
    var array:`[4][2]int` =  `[4][2]int{{10, 11}, {20, 21}, {30, 31}, {40, 41}}`

Frame Native Types
^^^^^^^^^^^^^^^^^^^^^^

Frame has a very limited set of native types: systems, states and events. 
Frame utilizes special tokens to type delarations of these special entities. 

.. list-table:: Frame Type Tokens
    :widths: 25 25 50
    :header-rows: 1

    * - Token
      - Type
      - Example
    * - #
      - System
      - #Andromeda
    * - $
      - State
      - $Florida
    * - @
      - Event
      - @

Note that the semantics of these entities are not yet completely uniform but will likely be 
brought closer into alignment in future versions of the Frame language. For example, system instances can be instantiated 
and referenced from variables, but states cannot. Events, on the other hand, can not be instantiated programatically but 
are created by the Frame runtime. Additionally the **@** symbol is only valid in the context of an event handler (or passed to an action) and refers to the
currently selected event instance.  

Parameter Declarations
^^^^^^^^^^^^^^^^^^^^^^

Parameters are declared in lists containing one or
more parameter declarations separated by commas and enclosed in square brackets:

.. code-block::

    // p1 is untyped, p2 is typed and p3 has a superstring type
    [p1, p2:int, p3:`[4][2]int`]


As we can see, parameters are typed with the same kinds of options as variables:

#. Untyped parameters
#. Typed parameters
#. Superstring typed parameters

Frame parameters cannot be assigned default values for missing arguments.

.. code-block::

    identifier:type


.. _methods:
.. _functions:
.. _functions and actions:

Functions, Interface Methods and Actions
-------

Frame has four flavors of callable routine types:

#. Functions 
#. System Interface Methods
#. System Actions
#. System Operations

Frame functions are normal, globally scoped callable subroutines. 

.. NOTE::
    In v0.11 Frame only supports an single (and optional) `main()` function. This will be expanded 
    to support multiple functions in v0.12.

The main() Function 
~~~~~~~~~~~~~~~~~~

Frame currently supports having a single function for a program - `main()`. The reason for this limitation 
is that until recently Frame's development was focused on adding features to the system aspect of the language.
With most essential language features for Frame systems at least represented in the language now, 
Frame's feature development is broadening to becoming a more complete programming language. 

Frame's syntax for functions is simple and has four variations: 

.. code-block::
    :caption: Frame Main Variations

    // no parameters; no return value
    fn main {
    }

    // no parameters; return value
    fn main : int {
        ^(0)
    }

    // parameters; no return value
    fn main [sys_arg1, sys_arg2] {
        print(sys_arg1 + "," + sys_arg2)
    }

    fn main [sys_arg1, sys_arg2] : int {
        print(sys_arg1 + "," + sys_arg2)
        ^(0)
    }

Interface Methods 
~~~~~~~~~~~~~~~~~~

Interface methods are publicly accessible methods on systems. Although Frame does not  
support general purpose object oriented class-like types, Frame systems generate object-oriented classes.

All subroutine types have a similar signature syntax:

.. code-block::
    :caption: Subroutine Name Syntax 

    <subroutine-name> <parameters-opt> <return-value-opt>

As implied above, the parameters and return value are optional. Here are the
permutations for method declarations:

.. code-block::

    subroutine-name
    subroutine-name [param]
    subroutine-name [param:type]
    subroutine-name [param1, param2]
    subroutine-name [param1:type, param2:type]
    subroutine-name : return_value
    subroutine-name [param1:type, param2:type] : return_value

Lists
-----

Frame does not (yet) have any genernal list or array syntax. Instead, Frame only supports
 *parameter lists* for subroutine and event handlers.

Frame uses square brackets to denote parameter lists:

.. code-block::
    :caption: Frame Parameter Lists

    |msg| [x,y] ^           // Event Handler Parameter List
    foo [x:int,y:string]    // Sub-routine Parameter List

Next
----

With mastery of basic Frame syntax, we can now explore the central aspect of the Frame language - 
the system. 
