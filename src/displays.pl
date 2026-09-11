
:- consult(utils).



display_game_mode :-
    write('--- Select Game Mode -----\n'),
    write('--------------------------\n'),
    write('--- 1. Human Vs Human  ---\n'),
    write('---- 2. Human Vs Bot  ----\n').

display_instructions :-
    write('Instructions\n'),
    write('-----------------------------------------------\n'),
    write('Game Objective:\n'),
    write('The objective of the game is to win the majority of the three stacks of eight\n'),
    write('formed during the game. Each time a stack of eight is formed, it is removed from\n'),
    write('the board, and the top checker is placed next to the board to indicate the winner\n'),
    write('of that stack. There are no draws or ties.\n\n'),
    
    write('Gameplay:\n'),
    write('1. The game is played on an 8x8 board (only the dark squares are used).\n'),
    write('2. Players take turns, starting with White.\n'),
    write('3. A stack can be made of any combination of colors, and its height can range\n'),
    write('   from one to eight checkers.\n\n'),
    
    write('Basic Moves:\n'),
    write('1. If a stack is not adjacent to any other stack, and you own the bottom checker\n'),
    write('   in that stack, you may slide the entire stack to an adjacent dark square.\n'),
    write('2. When making a basic move, you must move the stack closer to its closest stack\n'),
    write('   (measured by the number of moves it would take to get from one stack to another).\n'),
    write('3. If multiple stacks are equally close, you may choose which one to move closer to.\n\n'),
    
    write('Merging Stacks:\n'),
    write('1. If two stacks are adjacent, you may pick up your checker from one stack\n'),
    write('   (including all checkers above it) and place it on the other stack.\n'),
    write('2. You can only merge checkers to a higher altitude, not the same or a lower level.\n'),
    write('3. You cannot form a stack of nine or more checkers.\n'),
    write('4. If you have no other moves, you must make a move that benefits your opponent\n'),
    write('   (e.g., creating a stack of eight that they win).\n\n'),
    
    write('Stack of Eight:\n'),
    write('1. When a stack of eight is formed, it is immediately removed from the board.\n'),
    write('2. The top checker of the stack is placed next to the board to indicate the winner\n'),
    write('   of that stack.\n'),
    write('3. The game ends when three stacks of eight have been formed, and the player\n'),
    write('   who wins the majority of these stacks wins the game.\n\n'),
    
    write('Forced Moves:\n'),
    write('1. If you have any moves available, you must make one, even if it benefits your opponent.\n'),
    write('2. If you have no valid moves, you must forfeit your turn until you can move again.\n\n'),
    
    write('Additional Notes:\n'),
    write('1. Only dark squares are used for gameplay.\n'),
    write('2. The game has no draws or ties.\n'),
    write('3. Play strategically to dominate the board and win the majority of stacks.\n\n'),
    
    write('Have fun and good luck!\n'),
    write('-----------------------------------------------\n').


display_top_delimiter(Player, CurrentScore) :-
    nl,
    display_score(Player, CurrentScore), nl,
    write('        1    |     2    |     3    |     4    |     5    |     6    |     7    |     8    '), nl,
    write('  +----------+----------+----------+----------+----------+----------+----------+----------+'), nl.

display_score(1, [Score1, Score2]):-
    format('            **Player 1**                 ~d    |     ~d                 Player 2           ', [Score1, Score2]).

display_score(2, [Score1, Score2]):-
    format('              Player 1                   ~d    |     ~d               **Player 2**         ', [Score1, Score2]).

display_board_rows(_, _, 8,_) :- !.  % Base case: Stop after 8 rows.

display_board_rows(Board, EmptyBoard, Row, Y) :-
    Row < 8,
    display_row_levels(Board, EmptyBoard, Row, 7, Y),  % Render all levels of the row.
    write('  +----------+----------+----------+----------+----------+----------+----------+----------+'), nl,
    NextRow is Row + 1,
    NextY is Y + 8,
    display_board_rows(Board, EmptyBoard, NextRow, NextY).

display_row_levels(_, _, _, -1, _) :- !.
display_row_levels(Board, EmptyBoard, Row, Level, Y) :-
    Level >= 0,
    write_ten(Y),
    NextY is Y + 1,
    write('|'),
    display_row_level(Board, EmptyBoard, Row, Level), 
    nl,
    NextLevel is Level - 1,
    display_row_levels(Board, EmptyBoard, Row, NextLevel, NextY).

display_row_level(Board, EmptyBoard, Row, Level) :-
    nth0(Row, Board, BoardRow),
    nth0(Row, EmptyBoard, EmptyBoardRow),
    displayRowLevelSquares(BoardRow, EmptyBoardRow, Level).

displayRowLevelSquares([], [], _) :- !.  % Base case: Stop when rows are fully processed.

displayRowLevelSquares([Stack | RestBoard], [EmptySquare | RestEmpty], Level) :-
    %write('displayRowLevelSquares'),
    (
        % Case 1: If the board square has a piece, display it.
        Stack \= [],
        %write('  not empty'),
        nth0(Level, Stack, Checker),  % Get the checker at the current level
        char(Checker, Char)
    ;
        % Case 2: If the board square is empty, check empty_board.
        Stack = [],
        (
            EmptySquare = [s | _],  % If empty_board has 's', display it.
            char(s, Char)
        ;
            EmptySquare = [],  % If empty_board is also empty, display a blank square.
            char(u, Char)  % Render as blank space.
        )
    ),
    format(' ~w ', [Char]),  % Render the character.
    write('|'),
    displayRowLevelSquares(RestBoard, RestEmpty, Level).



display_possible_merge_moves([], _).
display_possible_merge_moves([((X, Y), Substacks) | Rest], Index) :-
    DisplayX is X+1,
    DisplayY is Y+1,
    format("~d. Move to (~d, ~d): ~n", [Index, DisplayX, DisplayY]),
    display_substacks(Substacks, 1),
    NextIndex is Index + 1,
    display_possible_merge_moves(Rest, NextIndex).

display_possible_merge_moves(Moves) :-
    display_possible_merge_moves(Moves, 1).

display_substacks([], _).
display_substacks([Substack | Rest], SubIndex) :-
    format("   ~d. Substack: ~w~n", [SubIndex, Substack]),
    NextSubIndex is SubIndex + 1,
    display_substacks(Rest, NextSubIndex).


% Display the possible normal moves
display_possible_normal_moves(Moves) :-
    display_possible_normal_moves(Moves, 1).

display_possible_normal_moves([], _).
display_possible_normal_moves([(X, Y) | Rest], Index) :-
    DisplayX is X+1,
    DisplayY is Y+1,
    format("~d. Move to (~d, ~d)~n", [Index, DisplayX, DisplayY]),
    NextIndex is Index + 1,
    display_possible_normal_moves(Rest, NextIndex).



empty_board([
    [[s, s, s, s, s, s, s, s], [], [s, s, s, s, s, s, s, s], [], [s, s, s, s, s, s, s, s], [], [s, s, s, s, s, s, s, s], []],
    [[], [s, s, s, s, s, s, s, s], [], [s, s, s, s, s, s, s, s], [], [s, s, s, s, s, s, s, s], [], [s, s, s, s, s, s, s, s]],
    [[s, s, s, s, s, s, s, s], [], [s, s, s, s, s, s, s, s], [], [s, s, s, s, s, s, s, s], [], [s, s, s, s, s, s, s, s], []],
    [[], [s, s, s, s, s, s, s, s], [], [s, s, s, s, s, s, s, s], [], [s, s, s, s, s, s, s, s], [], [s, s, s, s, s, s, s, s]],
    [[s, s, s, s, s, s, s, s], [], [s, s, s, s, s, s, s, s], [], [s, s, s, s, s, s, s, s], [], [s, s, s, s, s, s, s, s], []],
    [[], [s, s, s, s, s, s, s, s], [], [s, s, s, s, s, s, s, s], [], [s, s, s, s, s, s, s, s], [], [s, s, s, s, s, s, s, s]],
    [[s, s, s, s, s, s, s, s], [], [s, s, s, s, s, s, s, s], [], [s, s, s, s, s, s, s, s], [], [s, s, s, s, s, s, s, s], []],
    [[], [s, s, s, s, s, s, s, s], [], [s, s, s, s, s, s, s, s], [], [s, s, s, s, s, s, s, s], [], [s, s, s, s, s, s, s, s]]
]).




board([
    [[], [], [], [], [], [], [], []],
    [[], [b, e, e, e, e, e, e, e], [], [b, e, e, e, e, e, e, e], [], [b, e, e, e, e, e, e, e], [], [b, e, e, e, e, e, e, e]],
    [[w, e, e, e, e, e, e, e], [], [w, e, e, e, e, e, e, e], [], [w, e, e, e, e, e, e, e], [], [w, e, e, e, e, e, e, e], []],
    [[], [b, e, e, e, e, e, e, e], [], [b, e, e, e, e, e, e, e], [], [b, e, e, e, e, e, e, e], [], [b, e, e, e, e, e, e, e]],
    [[w, e, e, e, e, e, e, e], [], [w, e, e, e, e, e, e, e], [], [w, e, e, e, e, e, e, e], [], [w, e, e, e, e, e, e, e], []],
    [[], [b, e, e, e, e, e, e, e], [], [b, e, e, e, e, e, e, e], [], [b, e, e, e, e, e, e, e], [], [b, e, e, e, e, e, e, e]],
    [[w, e, e, e, e, e, e, e], [], [w, e, e, e, e, e, e, e], [], [w, e, e, e, e, e, e, e], [], [w, e, e, e, e, e, e, e], []],
    [[], [], [], [], [], [], [], []]
]).


display_board([Player, Board, CurrentScore]) :-
    format("NEW BOARD: ~w~n", [Board]),
    format("NEW PLAYER: ~d~n", [Player]),
    format("NEW SCORE: ~w~n", [CurrentScore]),
    empty_board(EmptyBoard),
    display_top_delimiter(Player, CurrentScore),
    display_board_rows(Board, EmptyBoard, 0, 1).



char(b, 'bbbbbbbb').
char(w, 'wwwwwwww').
char(e, '        ').
char(s, '    e   ').
char(_, '        ').

display_header :-
    write('----------------------------\n'),
    write('---------- Byte ------------\n'),
    write('----------------------------\n').

display_options :-
    write('-------1. Start Game--------\n'),
    write('-------2. Instructions------\n'),
    write('----------3. Leave----------\n').