==================
System Interface
==================

The system interface block contains the set of publicly accessible methods. The block is 
indicated by the **-interface-** keyword and must be the first block if it is present. 

Interface methods have the following synatax:

`<iface_method_name> ('[' (<param_name> (':' <param_type>)?)+ ']')? (':' <return_type>))? ('@(|' msg_alias '|)' )?`

The following examples show the permitted variations in method signatures:

.. code-block::
    :caption: Interface Examples

    -interface-

    simple_method
    method_params [p1,p2] 
    method_params_typed [p1:T1,p2:T2] 
    method_params_ret [p1:T1,p2:T2] : T3
    method_ret : T4
  
Interface Method Name 
---------------------

The interface method name must be a string of alphanumeric characters plus the underscore '_' character and
the name must not start with a number.  Ultimately this name must also be valid in the target language as 
a method identifier.

Interface Parameter List 
---------------------

The parameter list for interface methods follows the same rules as `functions and actions`_. 

Return Type
---------------------

Message Alias
---------------------

  -interface-

  start @(|>>|)
