
:- use_module(library(lists)).
:- use_module(library(random)).

:- consult(menu).
:- consult(utils).
:- consult(displays).

play :-
    menu(Option),
    initial_state(Option, GameState),
    game_loop(Option, GameState).
    
/*
   The game_over predicate checks if there is any winner in the current play
   The first argument is the game state and the second is the game winner, if any
  */
game_over([CurrentBoard, _], Winner) :-
    flatten_board(CurrentBoard, Stacks),  
    check_winner(Stacks, Winner).          

/*
   The flatten_board predicate flattens the board in order to make it easier to manipulate it
   It iterates for each row, flattens that row and then goes into the next one
   The first argument is the board and the second is the flatten board
 */
flatten_board([], []).
flatten_board([Row | Rest], FlatBoard) :-
    flatten_row(Row, FlatRow),
    flatten_board(Rest, RestFlatBoard),
    append(FlatRow, RestFlatBoard, FlatBoard).

/*
   The flatten_row predicate is an auxiliary predicate that flattens a row of the board
   The first argument is the row and the second is the flatten row
 */
flatten_row([], []).
flatten_row([Elem | Rest], [Elem | FlatRest]) :-
    flatten_row(Rest, FlatRest).

/*
    The check_winner predicate checks if there is a winner in the current play
    The first argument is the list of stacks and the second is the winner, if any
 */
check_winner([], no_winner).    
          
check_winner([Stack | _], Winner) :-
    get_winner(Stack, Winner),             
    Winner \= no_winner,                  
    !.
check_winner([_ | Rest], Winner) :-
    check_winner(Rest, Winner).           

/*
    The get_winner predicate checks if there is a winner in the current play
    The first argument is the stack and the second is the winner, if any
 */
get_winner(Stack, b) :-
    length(Stack, 8),                     
    last(Stack, b).                       

get_winner(Stack, w) :-
    length(Stack, 8),                     
    last(Stack, w).                        

get_winner(Stack, no_winner) :-
    length(Stack, 8),                      
    last(Stack, e).                        

get_winner(_, no_winner).
    
/*
    The get_closest_stacks predicate gets the closest stacks to a given point
    The first argument is the board, the second and third are the coordinates of the point, the fourth is the accumulator, the fifth is the current closest stacks, the sixth is the final closest stacks, the seventh is the current distance and the eighth is the final distance
 */

get_coordinates(Acc, Col, Row):-
    Col is (Acc mod 8), 
    Row is (Acc div 8).

% Base case
get_closest_stacks([], _, _, _, ClosestStacks, ClosestStacks, FinalDistance, FinalDistance) :- !.
                                                                                               
get_closest_stacks([H | T], Col, Row, Acc, CurrentClosest, FinalClosest, CurrentDistance, FinalDistance) :-
    is_stack(H),
    get_coordinates(Acc, Col, Row),
    !, 
    AccNext is Acc + 1,
    get_closest_stacks(T, Col, Row, AccNext, CurrentClosest, FinalClosest, CurrentDistance, FinalDistance).


% Case: Distance is the same
get_closest_stacks([H | T], Col, Row, Acc, CurrentClosest, FinalClosest, CurrentDistance, FinalDistance) :-
    is_stack(H),
    get_coordinates(Acc, CurrentCol, CurrentRow),
    !, 
    calculate_distance(Col, Row, CurrentCol, CurrentRow, CurrentDistance),
    append(CurrentClosest, [(CurrentCol, CurrentRow)], NewClosestStacks),
    !,  % Prevent backtracking
    AccNext is Acc + 1,
    get_closest_stacks(T, Col, Row, AccNext, NewClosestStacks, FinalClosest, CurrentDistance, FinalDistance).

% Case: Distance is smaller
get_closest_stacks([H | T], Col, Row, Acc, _, FinalClosest, CurrentDistance, FinalDistance) :-
    is_stack(H),
    get_coordinates(Acc, Col, Row),
    !, 
    calculate_distance(Col, Row, CurrentCol, CurrentRow, CalculatedDist),
    CalculatedDist < CurrentDistance,
    NewClosestStacks = [(CurrentCol, CurrentRow)],
    !,  % Prevent backtracking
    AccNext is Acc + 1,
    get_closest_stacks(T, Col, Row, AccNext, NewClosestStacks, FinalClosest, CalculatedDist, FinalDistance).

% Case: Not a stack or greater distance
get_closest_stacks([_ | T], Col, Row, Acc, CurrentClosest, FinalClosest, CurrentDistance, FinalDistance) :-
    AccNext is Acc + 1,
    get_closest_stacks(T, Col, Row, AccNext, CurrentClosest, FinalClosest, CurrentDistance, FinalDistance).


/*
    The get_checkers predicate gets the checkers of a given point
    The first argument is the flatten board, the second and third are the coordinates of the point and the fourth is the list of checkers in that point
 */
get_checkers(Board, Col, Row, Checkers):-
    is_within_board(Col, Row, true),
    Pos is Row * 8 + Col,
    nth0(Pos, Board, Checkers),
    !.

get_checkers(_, Col, Row, []):-
    is_within_board(Col, Row, false).

/*
    The filter_stacks predicate filters the stacks that are not stacks
    The first argument is the list of stacks, the second is the current list of stacks and the third is the final list of stacks
 */
filter_stacks([], CurrentStacks, FinalStacks) :-
    reverse(CurrentStacks, FinalStacks).

filter_stacks([((X, Y), Stack) | Rest], CurrentStacks, FinalStacks) :-
    is_stack(Stack),  % Check if the stack is valid.                % Commit to this clause if `true`.
    filter_stacks(Rest, [(X, Y) | CurrentStacks], FinalStacks).

filter_stacks([((_, _), Stack) | Rest], CurrentStacks, FinalStacks) :-
    \+is_stack(Stack),  % Skip invalid stacks.
    filter_stacks(Rest, CurrentStacks, FinalStacks).

/*
    The stack_adjacents predicate gets the adjacent stacks of a given point
    The first argument is the board, the second and third are the coordinates of the point and the fourth is the list of adjacent stacks
    It returns a list of tuples, where the first element is the coordinates of the adjacent stack and the second is the stack itself
 */
stack_adjacents(Board, Row, Col, AdjacentStacks) :-
    flatten_board(Board, FlattenBoard),
    NextCol is Col+1,
    NextRow is Row+1,
    PreviousCol is Col-1,
    PreviousRow is Row-1,
    get_checkers(FlattenBoard, NextCol, NextRow, Checkers1),
    get_checkers(FlattenBoard, NextCol, PreviousRow, Checkers2),
    get_checkers(FlattenBoard, PreviousCol, NextRow, Checkers3),
    get_checkers(FlattenBoard, PreviousCol, PreviousRow, Checkers4),
    Adjacents = [((NextCol, NextRow), Checkers1), ((NextCol, PreviousRow), Checkers2), ((PreviousCol, NextRow), Checkers3), ((PreviousCol, PreviousRow), Checkers4)],
    filter_stacks(Adjacents, [], AdjacentStacks).

/*
    The replace_in_column predicate replaces a given stack in a given column
    The first argument is the column, the second is the new stack and the third is the column with the new stack
 */
replace_in_column([], _, _, []).
replace_in_column([_|Tail], 0, Elem, [Elem|Tail]).
replace_in_column([Head|Tail], Index, Elem, [Head|NewTail]) :-
    Index > 0,
    NewIndex is Index - 1,
    replace_in_column(Tail, NewIndex, Elem, NewTail).

/*
    The replace_in_board predicate replaces a given stack in a given board
    The first argument is the board, the second and third are the coordinates of the point, the fourth is the new stack and the fifth is the board with the new stack
 */
replace_in_board(Board, Row, Col, NewStack, NewBoard) :-
    nth0(Row, Board, CurrentRow),   
    replace_in_column(CurrentRow, Col, NewStack, NewRow),
    replace(Board, Row, NewRow, NewBoard).       

/*
    The replace predicate replaces a given element in a given list
    The first argument is the list, the second is the index of the element to be replaced, the third is the new element and the fourth is the list with the new element
 */
replace([], _, _, []) :- !.                      
replace([_|Tail], 0, Elem, [Elem|Tail]) :- !.    
replace([Head|Tail], Index, Elem, [Head|NewTail]) :-
    Index > 0,
    NewIndex is Index - 1,
    replace(Tail, NewIndex, Elem, NewTail).

/*
    The get_possible_moves predicate gets the possible moves of a given point
    The first argument is the board, the second and third are the coordinates of the point, the fourth is the player, the fifth is the list of possible moves
 */
% This is the base case, when there are no more directions to check
get_possible_moves(_, _, _, [], _, AccumulatedMoves, AccumulatedMoves).

% This is the case when the current direction is a possible move
get_possible_moves(Board, Col, Row, [[NewCol, NewRow] | Rest], ClosestStacks, AccumulatedMoves, Moves) :-
    move_closer(Col, Row, NewCol, NewRow, ClosestStacks),
    is_within_board(NewCol, NewRow, true),
    get_possible_moves(Board, Col, Row, Rest, ClosestStacks, [(NewCol, NewRow) | AccumulatedMoves], Moves).

% This is the case when the current direction is not a possible move
get_possible_moves(Board, Col, Row, [_ | Rest], ClosestStacks, AccumulatedMoves, Moves) :-
    get_possible_moves(Board, Col, Row, Rest, ClosestStacks, AccumulatedMoves, Moves).

/*
    The possible_moves predicate gets the possible moves of a given point
    The first argument is the board, the second and third are the coordinates of the point, the fourth is the player, the fifth is the list of possible moves
 */
 % This is the base case, when the stack is not a stack
possible_moves(Board, Col, Row, _, []) :-
    flatten_board(Board, FlattenedBoard),
    get_checkers(FlattenedBoard, Col, Row, Stack),
    \+is_stack(Stack).

% This is the case when the stack is a stack and there are no adjacent stacks, i.e., the stack is isolated, so it can move in the direction of the closest stack
possible_moves(Board, Col, Row, Player, Moves) :-
    flatten_board(Board, FlattenedBoard),
    get_checkers(FlattenedBoard, Col, Row, Stack),
    is_stack(Stack),
    nth0(0, Stack, Bottom),
    owns_checker(Bottom, Player),        
    stack_adjacents(Board, Row, Col, []),
    get_directions(Col, Row, Directions),
    flatten_board(Board, FlattenedBoard),
    get_closest_stacks(FlattenedBoard, Col, Row, 0, [], ClosestStacks, 1000, _),
    get_possible_moves(Board, Col, Row, Directions, ClosestStacks, [], Moves).

possible_moves(Board, Col, Row, Player, []) :-
    flatten_board(Board, FlattenedBoard),
    get_checkers(FlattenedBoard, Row, Col, Stack),
    is_stack(Stack),
    nth0(0, Stack, Bottom),
    \+owns_checker(Bottom, Player).

% This is the case when the stack is a stack and there are adjacent stacks, so it has to be merged with them
possible_moves(Board, Col, Row, Player, Moves) :-
    flatten_board(Board, FlattenedBoard),
    get_checkers(FlattenedBoard, Col, Row, Stack),
    is_stack(Stack),
    stack_adjacents(Board, Row, Col, Adjacents),
    possible_substacks(Board, Col, Row, Player, Substacks),
    get_possible_merge(FlattenedBoard, Adjacents, Substacks, [], Moves).


print_moves([]).
print_moves([[Col, Row] | Rest]) :-
    format("(~d, ~d) ", [Col, Row]),
    print_moves(Rest).

/*
    The get_possible_merge predicate gets the possible merges of a given point
    The first argument is the board, the second is the list of adjacent stacks, the third is the list of possible substacks, the fourth is the accumulator, the fifth is the list of possible merges
    It returns a list of tuples, where the first element is the coordinates of the adjacent stack and the second is the list of possible substacks that can be merged with the adjacent stack
 */
get_possible_merge(_, [], _, CurrentRes, CurrentRes).

get_possible_merge(Board, [(Col, Row) | T], Substacks, CurrentRes, Res) :-
    get_checkers(Board, Col, Row, Stack),
    filter_substacks(Substacks, Stack, [], AccumulatedSubstacks),
    get_possible_merge(Board, T, Substacks, [((Col, Row), AccumulatedSubstacks) | CurrentRes], Res).

/* 
    The filter_substacks predicate filters the substacks that can be merged with a given stack
    The first argument is the list of substacks, the second is the stack, the third is the accumulator, the fourth is the list of substacks that can be merged with the stack
 */
filter_substacks([], _, CurrentSubstacks, CurrentSubstacks).

filter_substacks([(Substack, CurrentLevel) | Rest], Stack, CurrentSubstacks, FinalSubstacks) :-
    filter_by_height(Stack, Substack),
    filter_by_level(Stack, CurrentLevel),
    filter_substacks(Rest, Stack, [Substack | CurrentSubstacks], FinalSubstacks).

filter_substacks([(_, _) | Rest], Stack, CurrentSubstacks, FinalSubstacks) :-
    filter_substacks(Rest, Stack, CurrentSubstacks, FinalSubstacks).

/*
    The filter_by_height predicate filters the substacks that can be merged with a given stack by height, i.e., 
    the total height of the stack and the substack is less than or equal to 8
    The first argument is the stack, the second is the substack and the third is a boolean that indicates if the substack can be merged with the stack
 */
filter_by_height(Stack, Substack) :-
    count_non_empty(Stack, 0, StackHeight),
    count_non_empty(Substack, 0, SubstackHeight),
    TotalHeight is StackHeight + SubstackHeight,
    TotalHeight =< 8.

/*
    The filter_by_level predicate filters the substacks that can be merged with a given stack by level, i.e., 
    the level of the substack is greater than or equal to the level of the stack, as the bottom checker of the substack has to go to an higher level
    The first argument is the stack, the second is the level of the substack and the third is a boolean that indicates if the substack can be merged with the stack
 */
filter_by_level(Stack, MinLevel) :-
    count_non_empty(Stack, 0, StackHeight),
    StackHeight >= MinLevel.


owns_checker(w, 1):-true. % Player 1 owns white checkers
owns_checker(b, 2):-true. % Player 2 owns black checkers
owns_checker(_, _):-false.

/*
    The possible_substacks predicate gets the possible substacks of a given point
    The first argument is the board, the second and third are the coordinates of the point, 
    the fourth is the player, the fifth is the list of possible substacks
 */
get_possible_substacks([], _, _, CurrentSubstacks, CurrentSubstacks).

get_possible_substacks([H | T], Player, CurrentLevel, CurrentSubstacks, FinalSubstacks) :-
    \+owns_checker(H, Player),
    NextLevel is CurrentLevel + 1,
    get_possible_substacks(T, Player, NextLevel, CurrentSubstacks, FinalSubstacks).

get_possible_substacks([H | T], Player, CurrentLevel, CurrentSubstacks, FinalSubstacks) :-
    owns_checker(H, Player), 
   Level is CurrentLevel + 1, 
   NewSubstack = [H | T],
   trim_substack(NewSubstack, [], TrimmedSubstack), 
   get_possible_substacks(T, Player, Level, [(TrimmedSubstack, Level) | CurrentSubstacks], FinalSubstacks).



/*
    The possible_substacks predicate gets the possible substacks of a given point
    The first argument is the board, the second and third are the coordinates of the point,
    the fourth is the player, the fifth is the list of possible substacks
 */
possible_substacks(Board, Col, Row, Player, Substacks):-
    flatten_board(Board, FlattenedBoard),
    get_checkers(FlattenedBoard, Col, Row, Stack),
    get_possible_substacks(Stack, Player, 0, [], Substacks).

/* 
    The trim_substack predicate trims a substack, i.e., it removes the empty checkers from the top of the substack
    The first argument is the substack, the second is the current substack and the third is the trimmed substack
 */
trim_substack([], CurrentSubstack, CurrentSubstack).
trim_substack([e | _], CurrentSubstack, CurrentSubstack).
trim_substack([H | T], CurrentSubstack, TrimmedSubstack):-
    append(CurrentSubstack, [H], NewCurrentSubstack),
    trim_substack(T, NewCurrentSubstack, TrimmedSubstack).

/*
    The get_directions predicate gets the possible directions of a given point
    The first argument is the coordinates of the point, the second is the list of possible directions
 */
get_directions(Col, Row, Directions) :-
    NextRow is Row + 1,
    NextCol is Col + 1,
    PreviousRow is Row - 1,
    PreviousCol is Col - 1,
    Directions = [[NextCol, NextRow], [NextCol, PreviousRow], [PreviousCol, NextRow], [PreviousCol, PreviousRow]].

/*
    The move_closer predicate checks if a given point is closer to the closest stack than the current point
    The first four arguments are the coordinates of the point, the fifth is the list of closest stacks
 */
move_closer(_, _, _, _, []):-
    false.

move_closer(Col, Row, NewCol, NewRow, ClosestStacks):-
    check_all_closest_stacks(Col, Row, NewCol, NewRow, ClosestStacks).

/* 
    The check_all_closest_stacks predicate checks if a given point is closer to the closest stack than the current point
    The first four arguments are the coordinates of the point, the fifth is the list of closest stacks
 */
check_all_closest_stacks(_, _, _, _, []) :-
    false.

check_all_closest_stacks(Col, Row, NewCol, NewRow, [(ClosestCol, ClosestRow)| _]):-
    calculate_distance(NewCol, NewRow, ClosestCol, ClosestRow, NewDist),
    calculate_distance(Col, Row, ClosestCol, ClosestRow, CurrentDist),
    NewDist < CurrentDist.

check_all_closest_stacks(Col, Row, NewCol, NewRow, [(ClosestCol, ClosestRow)| Rest]):-
    calculate_distance(NewCol, NewRow, ClosestRow, ClosestCol, NewDist),
    calculate_distance(Col, Row, ClosestCol, ClosestRow, CurrentDist),
    NewDist >= CurrentDist,
    check_all_closest_stacks(Col, Row, NewCol, NewRow, Rest).

game_loop(1, [_, _, CurrentScore]):-
    verify_winner(CurrentScore, Winner),
    Winner \= -1,
    format("PLAYER ~d WON!\n", [Winner]).

game_loop(1, [Player, Board, CurrentScore]):-
    verify_winner(CurrentScore, -1),
    display_board([Player, Board, CurrentScore]), nl,
    move([Player, Board, CurrentScore], [NewPlayer, NewBoard, NewScore]),
    !,
    game_loop(1, [NewPlayer, NewBoard, NewScore]).

check_for_full_stacks(Board, CurrentScore, NewBoard, NewScore) :-
    process_rows(Board, CurrentScore, [], NewBoard, NewScore).

process_rows([], CurrentScore, ProcessedRows, NewBoard, CurrentScore) :-
    reverse(ProcessedRows, NewBoard).

process_rows([Row | Rest], CurrentScore, ProcessedRows, NewBoard, FinalScore) :-
    process_row(Row, CurrentScore, UpdatedScore, ProcessedRow),
    process_rows(Rest, UpdatedScore, [ProcessedRow | ProcessedRows], NewBoard, FinalScore).

process_row([], CurrentScore, CurrentScore, []).

process_row([Stack | Rest], CurrentScore, UpdatedScore, [NewStack | ProcessedRow]) :-
    process_stack(Stack, CurrentScore, IntermediateScore, NewStack),
    process_row(Rest, IntermediateScore, UpdatedScore, ProcessedRow).

process_stack(Stack, CurrentScore, UpdatedScore, []) :-
    count_non_empty(Stack, 0, 8),
    last(Stack, TopChecker),
    award_point(TopChecker, CurrentScore, UpdatedScore).

process_stack(Stack, CurrentScore, CurrentScore, Stack) :-
    count_non_empty(Stack, 0, Length),
    Length \= 8.

award_point(w, [Score1, Score2], [NewScore1, Score2]) :-
    NewScore1 is Score1 + 1.

award_point(b, [Score1, Score2], [Score1, NewScore2]) :-
    NewScore2 is Score2 + 1.

award_point(_, CurrentScore, CurrentScore).

verify_winner([Score1, _], 1):-
    Score1>=2.
verify_winner([_, Score2], 2):-
    Score2>=2.
verify_winner(_, -1).


move([Player, Board, CurrentScore], [NewPlayer, NewBoard, NewScore]) :-
    move_input((Col, Row)),
    is_within_board(Col, Row, IsWithin),
    process_board_selection(IsWithin, Player, Board, CurrentScore, Col, Row, [NewPlayer, NewBoard, NewScore]).


% Case where there are adjacent stacks, so the moves have to be merges
process_board_selection(true, Player, Board, CurrentScore, Col, Row, [NewPlayer, NewBoard, NewScore]) :-
    stack_adjacents(Board, Col, Row, AdjacentStacks),
    AdjacentStacks \= [],
    possible_moves(Board, Col, Row, Player, Moves),
    filter_non_empty_moves(Moves, FilteredMoves),
    FilteredMoves \= [],
    DisplayCol is Col+1,
    DisplayRow is Row+1,
    format("Possible moves from (~d, ~d):~n", [DisplayCol, DisplayRow]),
    display_possible_merge_moves(FilteredMoves),
    write('Select a move by index (coordinates): '),
    read_number(MoveIndex),
    nth1(MoveIndex, FilteredMoves, ((NewCol, NewRow), MergeStack)),
    write('Select a substack by index to merge: '),
    read_number(SubstackIndex),
    nth1(SubstackIndex, MergeStack, SelectedSubstack),
    apply_move(Board, (Col, Row), (NewCol, NewRow), SelectedSubstack, CurrentBoard),
    switch_player(Player, NewPlayer),
    check_for_full_stacks(CurrentBoard, CurrentScore, NewBoard, NewScore). % updates the score, by removing any full stacks, i.e., with 8 non-empty checkers

% Case where there are adjacent stacks, so the moves have to be merges, but there are no possible merges
process_board_selection(true, Player, Board, CurrentScore, Col, Row, [NewPlayer, NewBoard, NewScore]) :-
    stack_adjacents(Board, Row, Col, AdjacentStacks),
    AdjacentStacks \= [],
    possible_moves(Board, Row, Col, Player, Moves),
    filter_non_empty_moves(Moves, []),
    DisplayCol is Col+1,
    DisplayRow is Row+1,
    format("No moves available in (~d, ~d)~n", [DisplayCol, DisplayRow]),
    move([Player, Board, CurrentScore], [NewPlayer, NewBoard, NewScore]).

% Case where there are no adjacent stacks, so the moves can be 'simple'
process_board_selection(true, Player, Board, CurrentScore, Col, Row, [NewPlayer, NewBoard, NewScore]) :-
    stack_adjacents(Board, Row, Col, []),  
    possible_moves(Board, Col, Row, Player, Moves),
    process_possible_moves(Moves, Player, Board, CurrentScore, Col, Row, NewPlayer, NewBoard, NewScore).
    
process_possible_moves(Moves, Player, Board, CurrentScore, Col, Row, NewPlayer, NewBoard, NewScore) :-
    DisplayCol is Col+1,
    DisplayRow is Row+1,     
    format("Possible moves from (~d, ~d)~n", [DisplayCol, DisplayRow]),
    handle_normal_move_selection(Moves, (NewCol, NewRow)),
    apply_simple_move(Board, (Col, Row), (NewCol, NewRow), CurrentBoard),
    switch_player(Player, NewPlayer),
    check_for_full_stacks(CurrentBoard, CurrentScore, NewBoard, NewScore).

process_possible_moves([], Player, Board, CurrentScore, Col, Row, NewPlayer, NewBoard, NewScore) :-
    DisplayCol is Col+1,
    DisplayRow is Row+1, 
    format("No moves available in (~d, ~d)~n", [DisplayCol, DisplayRow]),
    move([Player, Board, CurrentScore], [NewPlayer, NewBoard, NewScore]).
                                                                        
apply_simple_move(Board, (Col, Row), (NewCol, NewRow), NewBoard):-
    replace_in_board(Board, Row, Col, [], TempBoard),        
    flatten_board(Board, FlattenBoard),
    get_checkers(FlattenBoard, Col, Row, Checkers),
    fill_with_empty(Checkers, FinalStack),
    replace_in_board(TempBoard, NewRow, NewCol, FinalStack, NewBoard). 

switch_player(Player, NewPlayer):-
    NewPlayer is 3 - Player. % 3 - 2 = 1 | 3 - 1 = 2


% Handle selection by index with explicit conditions
handle_normal_move_selection(Moves, SelectedMove) :-
    display_possible_normal_moves(Moves),
    write('Select a move by index: '),
    read_number(Index),
    length(Moves, MoveCount),
    validate_and_select_move(Index, MoveCount, Moves, SelectedMove),
    !. 

% Validate and select the move
validate_and_select_move(Index, MoveCount, Moves, SelectedMove) :-
    Index > 0,
    Index =< MoveCount,
    nth1(Index, Moves, SelectedMove).

validate_and_select_move(_, MoveCount, Moves, _) :-
    write('Invalid index. Please try again.\n'),
    format("Valid range: 1 to ~d~n", [MoveCount]),
    handle_normal_move_selection(Moves, _).



filter_non_empty_moves([], []).
filter_non_empty_moves([((Col, Row), []) | Rest], Filtered) :-
    filter_non_empty_moves(Rest, Filtered).
filter_non_empty_moves([((Col, Row), Substacks) | Rest], [((Col, Row), Substacks) | Filtered]) :-
    filter_non_empty_moves(Rest, Filtered).


apply_move(Board, (Col, Row), (NewCol, NewRow), MergeStack, NewBoard) :-
    flatten_board(Board, FlattenCurrentBoard),
    get_checkers(FlattenCurrentBoard, Col, Row, CurrentStack),
    trim_substack(CurrentStack, [], TrimmedCurrentStack),
    append(RemainingStack, MergeStack, TrimmedCurrentStack),
    fill_with_empty(RemainingStack, NewRemainingStack),
    % Update the board at (Row, Col) with the RemainingStack
    replace_in_board(Board, Row, Col, NewRemainingStack, TempBoard),

    flatten_board(TempBoard, FlattenTempBoard),
    get_checkers(FlattenTempBoard, NewCol, NewRow, Checkers),
    
    trim_substack(Checkers, [], TrimmedCheckers),
    append(TrimmedCheckers, MergeStack, NewStack),
    fill_with_empty(NewStack, FinalStack),

    replace_in_board(TempBoard, NewRow, NewCol, FinalStack, NewBoard).


fill_with_empty([], [s,s,s,s,s,s,s,s]).
  
fill_with_empty(CurrentStack, CurrentStack) :-
    length(CurrentStack, 8).

fill_with_empty(CurrentStack, FilledStack) :-
    length(CurrentStack, Len),
    Len < 8, 
    append(CurrentStack, [e], NewStack),
    fill_with_empty(NewStack, FilledStack).

read_coordinate((Col, Row)) :-
    read_row(Row),
    read_column(Col),
    format("Coordinate selected: (~d, ~d)~n", [Col, Row]).

read_row(Row) :-
    write('Enter the row (1-8): '),
    read_number(RowInput),
    valid_row(RowInput, Row).

read_column(Col) :-
    write('Enter the column (1-8): '),
    read_number(ColInput),
    valid_column(ColInput, Col).

valid_row(RowInput, Row) :-
    integer(RowInput),
    between(1, 8, RowInput),
    Row is RowInput - 1.

valid_row(_, Row) :-
    write('Invalid row! Please enter a number between 1 and 8.\n'),
    read_row(Row).

valid_column(ColInput, Col) :-
    integer(ColInput),
    between(1, 8, ColInput),
    Col is ColInput - 1.

valid_column(_, Col) :-
    write('Invalid column! Please enter a number between 1 and 8.\n'),
    read_column(Col).


move_input(Coordinate) :-
    nl,
    write('----- Select Move -----\n'),
    write('-----------------------\n'),
    nl,
    read_coordinate(Coordinate),
    nl.
