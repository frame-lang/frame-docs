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

Variables and parameter declarations share a common core syntax.

Parameter Declarations
^^^^^^^^^^^^^^^^^^^^^^
Parameters are declared as follows:

.. code-block::

    identifier:type

The name is required but the :type is optional. 

Parameter lists are one or
more parameter declarations separated by commans and enclosed in square brackets:

.. code-block::

    [p1:int, p2, p3:`[]`]

Parameter `p1` shows the typed syntax for parameters while `p2` shows the untyped. p3 shows how to 
use the `superstring` syntax to specify types whose syntax Frame doesn't support - in this case 
Python lists. 

Frame's handling of types is covered in more detail next. 

.. _variable_declarations:

Variable Declarations
---------------------

Variable and constant declarations have the following format:

.. code-block::

    var <name>:<type_opt> = <intializer_expr>

    var x:int = 1
    var name = "Boris"

Frame variables do not require a type but the target language may. If a type is declared and 
is required or optional in the target language, Frame will generate it. 
Conversely, if a variable declaration does not have a type but one is required in the target langauge,
Frame will generate `:<?>`. This type token is intended to generate an error when the target language program is compiled. 

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
