============
Frame Grammar v0.11.0
============

frame_spec: header? main_fn? system?
header: ( inline_code_block | code_block )*
main_fn: 'fn' 'main' parameter_list '{' stmt* '}' 
system: system_decl system_body? '##'
system_decl: '#' IDENTIFIER system_params_list?
system_params_list: '[' system_params ']'
system_params: ( start_state_params ',' start_state_enter_params ',' domain_params )
             | ( start_state_params ',' start_state_enter_params )
             | ( start_state_params ',' domain_params )
             | ( start_state_params )
             | ( start_state_enter_params ',' domain_params ) 
             | ( start_state_enter_params )
             | ( domain_params )

start_state_params: '$[' parameter_list ']' 
start_state_enter_params: '>[' parameter_list ']'
domain_params: '#[' parameter_list ']'

system_body: operations_block? iface_block? machine_block? actions_block? domain_block?

operations_block: '-operations-' operation*
operation: '#[static]'?  IDENTIFIER parameter_list? type operation_body?
operation_body: '{' stmt* '}'

iface_block: '-interface-' iface_method*
iface_method: IDENTIFIER parameter_list? type? message_alias?
type: ':' IDENTIFIER | inline_code_block
message_alias: '@' '(' message_selector ')'

machine_block: '-machine-' state*
state: state_name parameter_list? dispatch_clause? def* event_handler*
state_name: '$' IDENTIFIER
dispatch_clause: '=>' state_name
event_handler: message_selector parameter_list? def_or_stmt* event_handler_terminator
message_selector: '|' STRING '|'
def_or_stmt: def | stmt
event_handler_terminator: return_stmt | continue_stmt
return_stmt: '^' ( '(' expr ')' )?
continue_stmt: ':>'
def: ( 'var' | 'const' ) IDENTIFIER type? '=' expr 
stmt: transition_stmt
    | test_stmt
    | loop_stmt
    | block 
    | 'continue'
    | 'break'
    | expr_stmt

block: '{' stmt* '}'

transition_stmt: exit_args? ( transition_group_body | transition_body ) 
transition_group_body: '(' transition_body ')'
transition_body: '->' enter_args? transition_label? state_ref state_args?

exit_args: expr_list
enter_args: expr_list
transition_label: STRING
state_ref: '$' IDENTIFIER
state_args: expr_list

test_stmt: ( bool_test | string_test | number_test | enum_test ) ':|'
bool_test: equality ( '?' | '?!' ) test_branch else_cont_branch* else_branch?
else_cont_branch: ':>' test_branch 
else_branch: ':' test_branch 
test_branch: stmt* return_stmt?
string_test: equality '?~' string_match_branch+ else_branch?
string_match_branch: '~/' str_patterns '/' stmt* ( return_stmt | ':>' )
str_patterns: STRING ( '|' STRING )*
number_test: equality '?#' number_match_branch+ else_branch?
number_match_branch: '#/' number_patterns '/' stmt* ( return_stmt | ':>' )
number_patterns: NUMBER ( '|' NUMBER )*
enum_test: '?:' '(' enum_type ')' enum_match_branch+ else_branch?
enum_match_branch: ':/' enum_patterns '/' stmt* ( return_stmt | ':>') 

state_stack_stmt: state_stack_oper_expr

loop_stmt: 'loop' (loop_for | loop_while)
loop_for: def? ';' expr? ';' expr? '{' stmt* '}'
loop_while: '{' stmt* '}'

expr_stmt: expr
expr: assignment
assignment: equality ( '=' equality )?
equality: comparison ( ( '!=' | '==' ) comparison )*
comparison: term ( ( '>' | '>=' | '<' | '<=' ) term )*
term: factor ( ( '+' | '-' ) factor )*
factor: logical_xor ( ( '*' | '/' ) logical_xor )*
logical_xor: logical_or ( '&|' logical_or )*
logical_or: logical_and ( '||' logical_and )*
logical_and: unary_expr ( '&&' unary_expr )*
unary_expr:   ( '!' | '-' ) unary_expr
            |  '(' expr_list ')
            | '#' '.' IDENTIFIER 
            | '$' '[' IDENTIFIER ']
            | '$' '.' IDENTIFIER
            | '||[' IDENTIFIER ']'
            | '||.' IDENTIFIER ']'
            | literal_expr
            | state_stack_oper_expr
            | frame_event_part_expr
            | expr_list 	
            | call_chain_expr
            | system_instance_instantiation
            | system_instance_expr
            | system_type_expr
            | expr_list_expr@     
            | transition_expr
            | enumerator_expr

system_type_expr: '#' IDENTIFIER '.' call_expr 
system_instance_instantiation: '#' call_expr
call_exp: IDENTIFIER '(' (expr (',' expr)? ')'
system_instance_expr: '#' 
		
call_chain_expr: '&'? identifier_or_call_expr ( '.' identifier_or_call_expr )*
identifier_or_call_expr: IDENTIFIER expr_list? 
expr_list: '(' expr* ')'
literal_expr: NUMBER | STRING | 'true' | 'false' | 'null' | 'nil' | inline_code_block
state_stack_oper_expr: '$$[+]' | '$$[-]'
frame_event_part_expr: '@' ( '[' IDENTIFIER ']' | '^' )?

actions_block: '-actions-' action*
action: IDENTIFIER parameter_list? type action_body? 
action_body: '{' stmt* '}'

domain_block: '-domain-' (enum | def)*
enum: 'enum' enum_type  '{' enum_decl '}'
enum_type: IDENTIFIER 
enum_decl: enum_id ( '=' NUMBER)* 
enum_id: NUMBER
parameter_list: '[' parameter ( ',' parameter )* ']'
parameter: IDENTIFIER type?
type: ':' ( IDENTIFIER | inline_code_block )
inline_code_block: '`' STRING '`'
code_block: '```' STRING '```'

enumerator_expr: enum_type '.' enum_id