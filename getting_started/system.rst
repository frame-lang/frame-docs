===========================
System Behavior Design with Frame
===========================

Systems Engineering methodology broadly divides system aspects into two categories -
**structural** and **behavioral**. Frame
is a **Domain Specific Language (DSL)** focused on defining system behavior 
and is based on ideas from `UML Statecharts
<https://www.sciencedirect.com/science/article/pii/0167642387900359/>`_. 

Unlike the visual design 
paradigm of Statecharts, which anticipated developers would create complex software systems using visual modeling tools, 
Frame is a pragmatically textual language.

However, Frame still provides all the benefits of visual software design as it is intrinsically self documenting. 
Frame tooling enables visual documentation to be generated directly from a Frame system specification (spec).
This is useful as both an aide during 
development as well as providing final documentation of the completed system design. 

Although Frame is starting to take the first steps towards being a general purpose programming language, its 
differentiator from other languages is its introduction of notation specifically related to
Frame concepts related to **systems** design. 

System Controllers
------------------

Currently Frame programs are not compiled to a binary or run in an interpreter. Instead they are 
transpiled into other languages using a CLI based tool called **the Framepiler**. This approach was 
chosen to deliver the greatest impact and adoption by enabling developers to incorporate 
Frame technology into any existing project.

Although Frame supports true functions as of v0.11, the focus of the language is squarely on Frame as 
a systems development language. Frame transpiles system specs into target language objects 
called "system controllers". In object-oriented languages, which are the only kind of target outputs 
currently supported, system controllers are manifested as specially organized object-oriented classes.

Defining a System 
------------------

In Frame notation a Frame system specification starts with the **#** token and the name of the system
and terminated with the **##** token:

``Frame System``

.. code-block::
    :caption: An Empty System 

    #HelloWorldSystem
    ##

**#HelloWorldSystem** is an empty system spec that does nothing. Next we will add the 
code needed to add functionality to our system. 

Blocks
======

Frame specs are organized internally as five optional *blocks*:

#. Operations - privileged special routines
#. Interface  - the public methods of the system 
#. Machine    - the system state machine 
#. Actions    - private routines implementing behavior 
#. Domain     - private system data 


Although each (or all) blocks are optional, if present they must be defined in a specified order.

.. code-block::
    :caption: System Blocks 

    #HelloWorldSystem

        -operations-
        -interface-
        -machine-
        -actions-
        -domain-

    ##

.. note::
    The operations block will be discussed much later in the Advanced section of the documentation. 

In the following articles we will investigate role each of these blocks plays 
in defining a Frame system. 
