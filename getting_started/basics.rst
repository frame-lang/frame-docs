==========
The Basics
==========

This article will discuss aspects to the language that are common throughout
a system specification.

Comments
--------

Frame supports single line C style comments:

.. code-block::

    // this is a single line comment


Variable and Parameter Declarations
-----------------------------------

Variables and parameter declarations share a common core syntax for identifier typing. For both, there 
are three type options:

#. Untyped identifiers
#. Typed identifiers
#. Superstring typed identifiers

We will explore these options for variable declarations first. 

.. _variable_declarations:

Variable Declarations
---------------------

Before examining each variable declaration variation, it is important to note that a common requirement 
for all of them is that the variable must be initialized. As Frame is intended to transpile to multiple
target languages it makes no assumptions about a default values.

With regard to types, Frame has a very limited set of native types including systems, states and events. 
Other than these, Frame does not "understand" types and does no checking or validation of them. Instead,
for both flavors of types, Frame simply passes them through to the generated code as is.  

Frame variables do not require a type but the target language may. If a type is declared and 
is required or optional in the target language, Frame will generate it. 
Conversely, if a variable declaration does not have a type but one is required in the target langauge,
Frame will generate `:<?>`. This type token is intended to generate an error when the target language program is compiled. 


Untyped Variables
~~~~~~~~~~~~~~~~~

Untyped variables are valid only for target languages that don't require types. 

.. code-block::
    :caption: Untyped Variable Declaration

    // var <name> = <intializer_expr>
    var x = 0  
    var name = "Spock"
    var value = nil

Typed Variables
~~~~~~~~~~~~~~~~~ 

Typed variables are indicated by the use of ':' <type> syntax. 

.. code-block::
    :caption: Typed Variable Declaration

    var <name>:<type> = <intializer_expr>
    var x:int = 1  // p
    var <name> = <intializer_expr>

Superstring Typed Variables
~~~~~~~~~~~~~~~~~ 

The Framepiler makes relatively conservative assumptions about what syntax is permitted in a type 
declaration. Do circumvent Frame errors for type syntax, simply enclose the type string in backticks to 
make it a superstring and thus passed directly through to the code generators as-is.

This frequently requires that the expression that is assigned is also a superstring: 

``golang``

.. code-block::
    :caption: Superstring Typed Variable Declaration

    var <name>:<`type`> = <intializer_expr>
    var array:`[4][2]int` =  `[4][2]int{{10, 11}, {20, 21}, {30, 31}, {40, 41}}`

In future releases, Frame's syntax may support more native syntax for declarations and expressions. 

Parameter Declarations
^^^^^^^^^^^^^^^^^^^^^^

Parameter lists are one or
more parameter declarations separated by commas and enclosed in square brackets:

.. code-block::

    [p1, p2:int, p3:`[4][2]int`]


As we can see, parameters are typed with the same kinds of options as variables:

#. Untyped parameters
#. Typed parameters
#. Superstring typed parameters

Frame parameters can not be assigned default values for missing arguments.

.. code-block::

    identifier:type


.. _methods:

Functions, Interface Methods and Actions
-------

Frame has three flavors of function types:

#. Functions 
#. System Interface Methods
#. System Actions

Frame functions are normal, globally scoped routines. 

.. NOTE::
    In v0.11 Frame only supports a single `main()` function. This will be expanded 
    to support multiple functions in v0.12.

Interface methods are publicaly accessible methods on systems. Frame itself does not currently 
support general object oriented class-like types. However systems are implemented using object oriented classes.

All methods (for all blocks) have a similar syntax:

.. code-block::

    <method-name> <parameters-opt> <return-value-opt>

As implied above, the parameters and return value are optional. Here are the
permutations for method declarations:

.. code-block::

    method_name
    method_name [param]
    method_name [param:type]
    method_name [param1 param2]
    method_name [param1:type param2:type]
    method_name : return_value
    method_name [param1:type param2:type] : return_value

Whitespace separators
---------------------

One important difference between Frame and other languages is the lack of any
commas or semicolons as separators. Instead Frame relies on whitespace to
delineate tokens:

.. code-block:: language

    --- lists ---
    [x y]
    [x:int y:string]
    (a b c)
    (d() e() f())

    --- statements ---

    a() b() c()
    var x:int = 1

Unlike other languages where structured whitespace is significant (e.g. Python),
Frame’s use of whitespace is unstructured. Frame only separates tokens with
whitespace and does not insist on any pattern of use.

The esthetic goal is to be as spare and clean as possible, but it may take some
getting used to.

Lists
-----

List come in two flavors - *parameter lists* and *expression lists*.

Frame uses square brackets to denote parameter lists:

.. code-block::

    [x y]
    [x:int y:string]

Next
----

Now that you have a basic introduction to some common syntax, we are now ready
to explore a central concept in the Frame architecture - the
**FrameEvent**.
