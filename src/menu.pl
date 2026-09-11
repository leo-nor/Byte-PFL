:- consult(utils).
:- consult(displays).


menu(GameOption) :-
    display_header,
    options(GameOption).
    %display_game_mode,
    %select_mode(Option).

select_mode(GameOption) :-
    write('Select game mode (1 or 2): '),
    read_number(Input),
    format("INPUT : ~d~n", [Input]),
    validate_option(Input, GameOption).

validate_option(Input, GameOption) :-
    \+ between(1, 2, Input),
    format("Debug: validate_option/2 failed with Input = ~w~n", [Input]),
    write('Invalid option. Please select 1 or 2.\n'),
    select_mode(GameOption).

validate_option(Input, GameOption) :-
    format("Debug: validate_option/2 called with Input = ~w~n", [Input]),
    GameOption is Input,
    !.

options(GameOption) :-
    display_options,
    nl,
    write('Enter your choice: '),
    read_number(Option),
    format("OPTION: ~d~n", [Option]),
    handle_option(Option, GameOption).

handle_option(1, GameOption) :-
    display_game_mode,
    select_mode(GameOption).

handle_option(2, GameOption) :-
    display_instructions,
    nl,
    write('Press any key to return to options...\n'),
    skip_line,
    options(GameOption).

handle_option(3, _):-
    write('goodbye!\n'),
    halt.

handle_option(_, GameOption) :-  % invalid input
    write('Invalid option. Please try again.\n'),
    options(GameOption).



initial_state(1, [1, Board, [0,0]]):-
    board(Board).

initial_state(2, 2).
