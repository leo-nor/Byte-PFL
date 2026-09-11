/*
    The calculate_distance predicate calculates the distance between two points
    The first four arguments are the coordinates of the two points and the last argument is the distance between them
 */
calculate_distance(Col1, Row1, Col2, Row2, Distance) :-
    nonvar(Col1), nonvar(Row1), nonvar(Col2), nonvar(Row2),
    ColDiff is abs(Col1 - Col2),
    RowDiff is abs(Row1 - Row2),
    Distance is max(ColDiff, RowDiff).

/*
    The is_within_board predicate checks if a given point is within the board
    The first two arguments are the coordinates of the point and the third is a boolean that indicates if the point is within the board
 */
is_within_board(X, Y, true):-
    X >= 0,
    X < 8,
    Y >= 0,
    Y < 8.

is_within_board(_, _, false).


/*
    The is_stack predicate checks if a given stack is a stack
    The first argument is the stack and the second is a boolean that indicates if it is a stack
 */
is_stack([]):-false.         % Empty list is not a stack
is_stack([e | _]):-false.    % Starts with `e` is not a stack
is_stack([w | _]):-true.     % Any other case is a valid stack
is_stack([b | _]):-true. 


/*
    The count_non_empty predicate counts the number of non-empty elements, i.e., w or b checkers, in a given list
    The first argument is the list, the second is the accumulator and the third is the final number of non-empty elements
 */
count_non_empty([], Acc, Acc).

count_non_empty([e | Tail], Acc, FinalAcc) :-
    count_non_empty(Tail, Acc, FinalAcc).

count_non_empty([H | Tail], Acc, FinalAcc) :-
    H \= e,
    NextAcc is Acc + 1,
    count_non_empty(Tail, NextAcc, FinalAcc).



write_ten(Y):-
    Y < 10,
    write(' '), write(Y).

write_ten(Y):-
    \+ Y < 10,
    write(Y).

read_number(X) :-
    read_number(X, 0).

read_number(Acc, Acc) :-
    peek_code(10),
    get_code(_). 

read_number(X, Acc) :-
    get_code(Code),
    Code >= 48,
    Code =< 57,
    NumAux is Code - 48,
    NewAcc is Acc * 10 + NumAux,
    read_number(X, NewAcc).

read_number(X, _) :-
    get_code(Code),
    Code < 48,
    Code > 57,
    write('Invalid input. Please enter numeric digits only.\n'),
    skip_line,              
    read_number(X, 0).

between(Min, Max, X) :-
    number(Min),
    number(Max),
    number(X),
    X >= Min,
    X =< Max.
