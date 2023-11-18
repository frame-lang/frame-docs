===========================
System Behavior Design with Frame
===========================

Systems Engineering methodology describes two broad categories of aspects to a system -
**structure** and **behavior**. Frame is a **Domain Specific Language (DSL)** for for defining system behavior 
and is based on ideas from `UML Statecharts
<https://www.sciencedirect.com/science/article/pii/0167642387900359/>`_. 

Unlike the visual design 
paradigm of Statecharts where it is intended developers would code by drawing, Frame 
is a textual language. However, Frame still provides all the benefits of visual design as 
statecharts can be generted from a Frame system specification (spec) and used as both an aide during 
development as well as being intrincially documented after completion. 

Although Frame is starting to take steps to being a general purpose programming language, its 
focus is on helping developers design complex softwre organized as **syatems**. In practice, Frame currently 
generates object-oriented classes as the container for each system, however that is not a requirement but 
simply a byproduct of Frame development focusing on object-oriented languages as the first platform targets.

We will now explore how Frame enables developers to easily think about building systems using 
intuitive syntax crafted for that purpose. 

Defining a System 
------------------

In Frame notation a Frame system specification starts with the `#` token and the name of the system
and terminated with the `##` token:

``Frame System``

.. code-block::

    #TrafficLight
    ##

At this point `#TrafficLight` is an empty system spec and has no behavior. Next we will add the 
structure needed to start to add functionality to our TrafficLight. 

Blocks
======

Frame specs are organized internally into four *blocks* that are all optional,
as we just saw, but if present must be defined in a specified order.

.. code-block::

    #TrafficLight

    -interface-
    -machine-
    -actions-
    -domain-

    ##

In the next articles in this series, we will investigate role each of these blocks plays 
in defining a Frame system. 
