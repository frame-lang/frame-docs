Frame Docs v0.11 – *main* branch
============================

Welcome! Here you will find the official documentation for the **Frame Language**.

What is Frame?
--------------
Frame is a Domain Specific Language (DSL) language for both designing and programming Frame **systems**. 
Embedded in each Frame system is an **automaton**, also known as a state machine or Turing machine. 
For simplicity, Frame simply refers to this part of a system as the **machine**. 

Using the open source **Framepiler** tool, Frame programs are transpiled to other languages
as well as into UML documentation. Currently Frame supports Python as its only target programming language 
and UML Statechart visual notation for documentation. 

In the future Frame will expand its target language set beyond Python to include JavaScript, Java, 
C#, C++, Golang, Rust. Other languages will follow as the project gains support and adoption. 

State as a First Class Citizen
--------------

Frame enables the solution of a problem to look like the problem it is solving. What does this mean and
why should you care?

At the core of most popular programming languages are data structures. Subsequently the syntax of these languages 
is designed to optimize the manipulation of data. In these languages, logical state is not a 
first class citizen, meaning there is no built-in syntax for state definition and manipulation. 
Instead, logical state is derived by conditional tests on low level data. As a system grows in 
size, so does the web of complex conditional logic thats sole purpose is to figure out 
what state the system is in. Thus is born - spaghetti code. 

In contrast, logical state is inherent to automata - state is what they are all about. Therefore logical state 
is a first class citizen of automata and is what you think about first when creating one. 

However, using non-automata-oriented languages (meaning all popular modern programming languages) to build automata 
is fraught with challenges. Strange new classes of problems 
emerge when systems are "compartmentalized" into states. Some things that were easy are now harder, 
though arguably still better. Frame is designed to address this new class of problems 
and to make state-oriented programming a natural way to create software. 

Because Frame is a language for implementing automata, Frame's syntax
aligns with the logical problems being solved by system designers and programmers. When creating 
systems using Frame, developers don't start with defining data - they 
start by defining the logical solution to a problem. 

Frame Innovations in Automata Design 
--------------

Frame was born from a deep interest in making automata easy to use in day-to-day software system design and programming.
Automata (state machines, pushdown automata and Turing machines) are bedrock computer science, yet are
considered esoteric and reserved for heavy use in only a few specialized fields. 

For those familiar with UML, Frame fully supports powerful UML statechart features such as
enter/exit events and Hierarchical State Machines (HSMs), but also adds numerous innovations to those
basic capabilities. 

Most importantly, Frame is a textual language for expressing automata that enables developers to
directly engage with the logical aspects of the problems they are trying to solve.


Textual language
===========

Most low-code workflow and statechart based languages are visual, meaning the developer 
must layout the flow of the program. Despite seeming to be a more sophisticated 
approach to modeling software, this aspect is, in fact, ergonomically inefficient. 
Small changes to the system can take significant time to adjust the drawing properly. 

Additionally, visual approaches prevent utilization of text based diff validation of changes, 
thus making visual based system development more challenging to support with regards to 
change management. 

Frame, as a textual language, does not have these challenges yet still benefits from 
visual documentation of the system due to its ability to emit UML diagrams from 
the Frame system specifications. With Frame, you get the best of both worlds. 


Framepile into Your Favorite Programming Languages
===========

Frame is supported by the Framepiler - a transpiler written in Rust that generates 
Frame systems in Python, UML and eventually other languages. To support taking
full advantage of the capabilities of the target language, Frame syntax is very permissive in passing through 
native syntax implicitly. Where there is a conflict between Frame syntax and the target language, 
Frame enables explicit passthrough syntax using literal "superstrings" that simply inject the 
contents of the superstring into the output. 

Statechart Semantics
===========

UML Statecharts introduced a number of important innovations in working with automata. 
Three of the most useful are:

1. Enter/exit events for states 
2. Hierarchical State Machines
3. State history 

Frame considers these capabilities to be table stakes for a language for automata, therefore supports these 
and adds features to make them more powerful and useful. 


Enter/Exit event parameters
===========

One innovation on traditional statecharts is the ability to pass arguments with 
enter and exit events during transitions. This ability enables a direct means to transfer
data transfer from one state to another. This capability avoids the need to find ad hoc caching 
mechanisms for data that needs to be transmitted from one state to another during a transition. 

State Parameters 
===========

In addition to passing arguments on enter and exit events during transitions, 
Frame also enables states to have 
parameters which are also initialized during a transition. Unlike enter and exit 
parameters, state parameters are scoped to the lifetime of the state itself. 

State Variables
===========

Frame supports states having their own local variables. 
This feature keeps data related to
a state in the state's local scope rather than the system scope. This approach 
to data isolation at the state level makes it easier to reason about state behavior 
and not accidentally modify another state's data incorrectly.

State Instances (Compartments)
===========

The mechanism enabling enter/exit event parameters, state parameters and state variables
is one of Frame's important, but initially subtle, 
features with regards to how states are implemented. Many state machine implementations
simply implement "states" as an enumerated type to be used to switch between different code paths
corresponding to the current state.

Frame, however, manages a data structure for each state instance called a 
**compartment**. Every time a state is entered, a new state compartment is instantiated. 
Additionally, if the current state inherits behavior from parent states, a chained set 
of compartments is instantiated for the full hierarchy. 

Compartments are where enter/exit event arguments, state arguments and state variables are kept. 
This implementation approach also makes it possible to
return to a state in the exact condition it 
was left it via the history mechanism. Compartments also enable a Frame feature called 
**Event Forwarding**.


Event Forwarding
===========

Sometimes events can happen while in one state that should be processed in another state. This situation
is difficult to cleanly handle in other paradigms for implementing automata. To address 
this situation Frame provides a simple mechanism to easily forward an event 
when transitioning to another state, thus greatly simplifying these kind of not so uncommon situations.    


Operations
===========

Frame systems are by default intended to be closed and the functionality accessible only through the 
interface and machine. However there are some situations, including testing and validation, that 
having privileged access to the system's inner data and functionality makes much simpler. 
Operations provide this type of access.

Persistence and Workflows
===========

One very common requirement for business use cases is to support **workflows**. Workflows are
stateful sequences of activity in a system. Workflows are also not typically memory resident 
and instead need to be persisted on some durable medium or data repository. 

Using operations, Frame supports save and load operations for systems, enabling Frame workflows 
to easily be persisted and restored from disk. 

Long Running Services
=========== 

Lastly, the Frame runtime kernel embedded in each Frame system provides mechanisms to execute 
as long running services. This differs from other approaches to implementing 
automata which are typically modeled as event driven and return control to the caller after 
each call to the system. While Frame systems are typically event driven, 
Frame easily supports both modes of operation. 



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
    intermediate_frame/lists
    intermediate_frame/loops
    intermediate_frame/enums
    intermediate_frame/systems
    intermediate_frame/interface
    intermediate_frame/return
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
