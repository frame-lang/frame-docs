Frame Docs v0.11 – *main* branch
============================

Welcome! Here you will find the official documentation for the **Frame Language**.

What is Frame?
--------------
Frame is a Domain Specific Language (DSL) language for both designing and programming state machines (technically Turning Machines). 
Using the open source **Framepiler** tool, Frame programs are transpiled to other languages
as well as into UML documentation. Currently Frame supports Python as its only target language and Statechart visual notation 
for documentation. 

In the future Frame will expand its target language set beyond Python to include JavaScript, Java, C#, C++, Golang and Rust. Other languages 
will follow as the project gains support and adoption. 


.. toctree::
    :hidden:
    :maxdepth: 1
    :caption: About
    :name: sec-about

    about/introduction

.. toctree::
    :hidden:
    :maxdepth: 1
    :caption: Getting Started
    :name: sec-getting-started

    getting_started/index
    getting_started/basics
    getting_started/system
    getting_started/interface_block
    getting_started/frame_events
    getting_started/machine_block
    getting_started/actions_block
    getting_started/domain_block

.. toctree::
    :hidden:
    :maxdepth: 1
    :caption: Intermediate Frame
    :name: sec-intermediate-frame

    intermediate_frame/index
    intermediate_frame/functions
    intermediate_frame/control_flow
    intermediate_frame/loops
    intermediate_frame/enums
    intermediate_frame/systems
    intermediate_frame/interface
    intermediate_frame/states
    intermediate_frame/transitions
    intermediate_frame/hsm
    intermediate_frame/history


.. toctree::
    :hidden:
    :maxdepth: 1
    :caption: Advanced Frame
    :name: sec-advanced-frame

    advanced_frame/index
    advanced_frame/attributes
    advanced_frame/operations
    advanced_frame/persistence
    advanced_frame/runtime
    advanced_frame/cli_programs
    advanced_frame/services

.. toctree::
    :hidden:
    :maxdepth: 1
    :caption: Language
    :name: sec-language

    language/index
