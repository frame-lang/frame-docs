==================
Interface Block
==================

The system interface block contains the set of publicly accessible methods. The block is 
indicated by the **-interface-** keyword and must be the first block if it is present. 

Interface methods have two responsibilities:

#. Build a FrameEvent from the data provided by the caller 
#. Return the event return value to the caller if it exists on the event.

The three parts of the signature for interface methods are:

#. Method name
#. Parameter list
#. Return type

.. admonition:: Interface Method Syntax

    <method_name> ('[' (<prm_name> (':' <prm_type>)?)+ ']')? (':' <ret_type>))? 
  
Interface Method Name 
---------------------

The interface method name must be a string of alphanumeric characters plus the underscore '_' character and
the name must not start with a number.  Ultimately this name must also be valid in the target language as 
a method identifier.

Interface Parameter List 
---------------------

The parameter list for interface methods follows the same rules as `functions and actions`_. 
Although any combination of typed or untyped parameters is permitted, the target language must support 
the generated syntax. It is a syntax error to have an empty parameter list. 

Paramter types can be superstrings.

Return Type
-----------

As with variable typing, method return types are indicated by **': ret_type'** syntax. 
Return types are optional and can be any valid identifier or superstring. 


Examples
--------

The following examples show the permitted variations in method signatures:

.. code-block::
    :caption: Interface Examples

    -interface-

    simple_method
    method_untyped_params [p1,p2] 
    method_superstring_params [p1:`[]int`] 
    method_typed_params [p1:T1,p2:T2] 
    method_params_ret [p1:T1,p2:T2] : T3
    method_superstring_ret : `[]int`
    method_alias [p1,p2:T2] : T3 