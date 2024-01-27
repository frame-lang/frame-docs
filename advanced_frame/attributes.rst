Attributes 
===========

Frame supports `Rust/C# style attribute syntax <https://doc.rust-lang.org/reference/attributes.html>`_ to 
add metadata to various entity types. Currently only one attribute is implemented.

Static Operations
-----------------

To make an operation static, add an outer attribute **#[static]** to the function declaration:


.. code-block::
    :caption: Static Operation using an Attribute

    -operations-

    #[static]
    foo {
    }