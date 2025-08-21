Compartments
============

In the sections on transition and state parameters, as well as state variables,
no details were given as to how this data is passed to the state, initialized and/or preserved.
The answer to those questions is a new concept for state machines called
the **compartment**.

Compartments, or *state compartments*, are a closure concept for
states that preserve the state itself, the data from the
various scopes as well as runtime data
needed for the Frame machine semantics.

## Compartment Structure

A compartment is a runtime data structure that encapsulates all the context needed for a state:

.. code-block::
    :caption: Compartment Structure (Python Implementation)

    class SystemCompartment:
        def __init__(self, state, parent_compartment):
            self.state = state                    # Current state identifier
            self.state_args = {}                  # State parameters
            self.state_vars = {}                  # State variables
            self.enter_args = {}                  # Transition enter arguments
            self.exit_args = {}                   # Transition exit arguments
            self.forward_event = None             # Event forwarding data
            self.parent_compartment = parent_compartment  # Hierarchical state support

## Compartment Manifest

The compartment contains the following data:

* **state** - Current state identifier (e.g., '__system_state_Active')
* **state_args** - Parameters passed to the state when created
* **state_vars** - Local variables scoped to the state
* **enter_args** - Arguments passed during state transitions
* **exit_args** - Arguments passed when exiting the state  
* **forward_event** - Runtime data for the event forwarding (@:>) feature
* **parent_compartment** - Reference to parent state (for hierarchical state machines)

## Simple Compartment Example

.. code-block::
    :caption: Basic State with Parameters

    fn main() {
        var demo = CompartmentDemo("initial_value")
    }

    system CompartmentDemo(state_param: string) {

        machine:

        $StartState {
            var v1: string = "state_variable"
            
            $>() {
                print("State param: " + state_param)
                print("State var: " + v1)
                -> $NextState("next_value")
            }
        }

        $NextState {
            $>(p2: string) {
                print("Received: " + p2)
            }
        }
    }

## State Variables and Scope

Compartments manage different scopes of data within state machines:

.. code-block::
    :caption: Variable Scopes in Compartments

    system ScopeDemo {

        machine:

        $StateA {
            var local_to_state_a: int = 100
            
            $>() {
                print("Local variable: " + str(local_to_state_a))
                print("Domain variable: " + str(shared_counter))
                shared_counter = shared_counter + 1
                -> $StateB
            }
        }

        $StateB {
            var local_to_state_b: string = "StateB data"
            
            $>() {
                print("Local variable: " + local_to_state_b)
                print("Domain variable: " + str(shared_counter))
                // local_to_state_a is not accessible here
            }
        }

        domain:
        
        var shared_counter: int = 0  // Accessible from all states
    }

## Transition Parameters

Compartments handle the passing of data between states during transitions:

.. code-block::
    :caption: Transition Parameters via Compartments

    system DataPassingDemo {

        interface:
        
        processData(input: string)

        machine:

        $Idle {
            processData(input: string) {
                -> $Processing(input, "metadata") 
            }
        }

        $Processing {
            $>(data: string, meta: string) {
                print("Processing: " + data + " with " + meta)
                var result = data + "_processed"
                -> $Complete(result)
            }
        }

        $Complete {
            $>(final_result: string) {
                print("Result: " + final_result)
                -> $Idle
            }
        }
    }

## Hierarchical State Compartments

In hierarchical state machines, compartments maintain parent-child relationships:

.. code-block::
    :caption: Hierarchical Compartment Structure

    system HierarchicalDemo {

        machine:

        $Parent {
            commonEvent() {
                print("Handled in parent")
                return
            }
        }

        $Child => $Parent {  // Child inherits from Parent
            $>() {
                print("Entered child state")
            }
            
            specificEvent() {
                print("Handled in child")
                @:>  // Forward to parent if needed
            }
        }
    }

## Compartment Lifecycle

The Frame runtime manages compartment lifecycle automatically:

1. **Creation**: New compartment created during state transitions
2. **Initialization**: State parameters and variables initialized
3. **Execution**: Event handlers execute within compartment context
4. **Transition**: Exit handlers called, new compartment created
5. **Cleanup**: Old compartment released (garbage collected)

## Generated Compartment Code

When Frame generates Python code, compartments become runtime objects:

.. code-block::
    :caption: Generated Python Compartment Usage

    # Frame generates compartment management code like:
    
    def __transition(self, next_compartment):
        self.__next_compartment = next_compartment
        
    # State transitions create new compartments:
    next_compartment = SystemCompartment('__system_state_Next', None)
    self.__transition(next_compartment)
    
    # The runtime kernel manages compartment switching:
    while self.__next_compartment != None:
        # Exit current state
        self.__router(FrameEvent("<$", self.__compartment.exit_args))
        # Switch to next compartment  
        self.__compartment = self.__next_compartment
        # Enter new state
        self.__router(FrameEvent("$>", self.__compartment.enter_args))

## Benefits of Compartments

Compartments provide several key advantages:

* **State Isolation**: Each state's data is properly encapsulated
* **Parameter Passing**: Clean mechanism for inter-state communication  
* **Variable Scoping**: Automatic management of different data scopes
* **Memory Management**: Efficient allocation and cleanup of state data
* **Hierarchical Support**: Enables complex parent-child state relationships
* **Event Forwarding**: Infrastructure for @:> event forwarding feature

Compartments are the foundation that makes Frame's advanced state machine features possible while maintaining clean separation of concerns between states.
