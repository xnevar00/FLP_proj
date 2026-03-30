%%%%%%%%%%%%%%%%%%%% PRL project 2 (Babylon tower) %%%%%%%%%%%%%%%%%%%
% File: tower.pl
% Description: predicates for moving the tower + checking if the tower is solved
% Author: Veronika Nevarilova (xnevar00)
% date: 4/25
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% predicates for rotating horizontally %%%%%%%%%%%%%%%

% rotate_row_right(+InputRow, -OutputRow)
% rotates a certain row one step to the right
% InputRow - a row to be rotated
% OutputRow - rotated row
rotate_row_right(InputRow, OutputRow) :-
    append(HeadList, [TailElement], InputRow),
    OutputRow = [TailElement | HeadList].

% rotate_row_right(+InputRow, -OutputRow)
% rotates a certain row one step to the left
% InputRow - a row to be rotated
% OutputRow - rotated row
rotate_row_left([H|T], L) :- append(T, [H], L).

% replace_nth0(+Index, +InputList, +Element, -OutputList)
% replaces the element on index N with element X
% Index - index to be replaced
% InputList - List where the element on index Index should eb replaced
% Element - the new value to be replaced with
% OutputList - List with replaced element 
replace_nth0(0, [_|T], X, [X|T]).
replace_nth0(N, [H|T], X, [H|Rest]) :-
    N > 0,
    N1 is N - 1,
    replace_nth0(N1, T, X, Rest). 

% rotate_left(+Tower, +RowIndex, -OutputTower)
% gets the row to rotate to the left, rotates it and replaces it
% Tower - tower to work with
% RowIndex - index of row to be rotated
% OutputTower - tower with rotated row
rotate_left(Tower, RowIndex, OutputTower) :-
    nth0(RowIndex, Tower, Row, _),
    rotate_row_left(Row, NewRow),
    replace_nth0(RowIndex, Tower, NewRow, OutputTower). 

% rotate_right(+Tower, +RowIndex, -OutputTower)
% gets the row to rotate to the right, rotates it and replaces it
% Tower - tower to work with
% RowIndex - index of row to be rotated
% OutputTower - tower with rotated row
rotate_right(Tower, RowIndex, OutputTower) :-
    nth0(RowIndex, Tower, Row, _),
    rotate_row_right(Row, Newrow),
    replace_nth0(RowIndex, Tower, Newrow, OutputTower). 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% predicates for moving vertically %%%%%%%%%%%%%%%%%%%

% find_empty_cell(+Tower, +RowNumber, -RowIdx, -ColumnIdx)
% returns the row and col index of empty cell ([*,*])
% Tower - the tower to work with
% RowNumber - row number to check for [*,*]
% RowIdx - index of row containing empty cell
% ColumnIds - index of column containing empty cell
find_empty_cell([Row|_], RowNumber, RowIdx, ColumnIdx) :-
    nth0(ColumnIdx, Row, [*, *]),
    RowIdx is RowNumber,
    !.

find_empty_cell([_|Rest], RowNumber, RowIdx, ColumnIdx) :-
    NewRowNumber is RowNumber + 1,
    find_empty_cell(Rest, NewRowNumber, RowIdx, ColumnIdx).

% move_empty_cell_up(+Tower, -UpdatedTower)
% moves the empty cell one step up
% Tower - Tower to work with
% UpdatedTower - tower with moved empty cell up
move_empty_cell_up(Tower, UpdatedTower) :-
    find_empty_cell(Tower, 0, RowIdx, ColumnIdx),
    RowIdx > 0,
    TopRowIdx is RowIdx - 1,
    nth0(RowIdx, Tower, BottomRow, _),
    nth0(TopRowIdx, Tower, TopRow, _),
    nth0(ColumnIdx, TopRow, TopCell, _),
    replace_nth0(ColumnIdx, TopRow, [*, *], UpdatedTopRow),
    replace_nth0(ColumnIdx, BottomRow, TopCell, UpdatedBottomRow),
    replace_nth0(TopRowIdx, Tower, UpdatedTopRow, Tower2),
    replace_nth0(RowIdx, Tower2, UpdatedBottomRow, UpdatedTower).

% move_empty_cell_down(+Tower, -UpdatedTower)
% moves the empty cell one step down
% Tower - Tower to work with
% UpdatedTower - tower with moved empty cell down
move_empty_cell_down(Tower, UpdatedTower) :-
    find_empty_cell(Tower, 0, RowIdx, ColumnIdx),
    length(Tower, NumRows),
    RowIdx < NumRows - 1,
    BottomRowIdx is RowIdx + 1,
    nth0(BottomRowIdx, Tower, BottomRow, _),
    nth0(RowIdx, Tower, TopRow, _),
    nth0(ColumnIdx, BottomRow, BottomCell, _),
    replace_nth0(ColumnIdx, BottomRow, [*, *], UpdatedBottomRow),
    replace_nth0(ColumnIdx, TopRow, BottomCell, UpdatedTopRow),
    replace_nth0(BottomRowIdx, Tower, UpdatedBottomRow, Tower2),
    replace_nth0(RowIdx, Tower2, UpdatedTopRow, UpdatedTower).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% predicates for goal state %%%%%%%%%%%%%%%%%%%%

%%%%%% numbers check

% raw_correct_numbers(+Row, +RowIdx)
% checks if there are correct numbers on certain line
% Row - row to check
% RowIdx - index of the row (it's the value to check for in row elements)
row_correct_numbers([], _).
row_correct_numbers([[_, NumberChar] | Rest], RowIdx) :-
    atom_number(NumberChar, Number),
    Number =:= RowIdx,
    row_correct_numbers(Rest, RowIdx).

% check_row_with_star(+Row, +RowIdx)
% check for last line (checks if there is [*,*] at first position, then processes that as the rest of the lines)
% Row - row to check
% RowIdx - index of the row (it's the value to check for in row elements)
check_row_with_star([['*', '*'] | Rest], RowNumber) :-
    row_correct_numbers(Rest, RowNumber).

% all_rows_correct_numbers(+Tower, +RowIdx, +TotalRows)
% check if all rows items have corresponding number
% Tower - tower to check
% RowIdx - current row id
% TotalRows - total number of rows in tower
all_rows_correct_numbers([], _, _).
all_rows_correct_numbers([Row | Rest], RowIdx, TotalRows) :-
    RowNumber is RowIdx + 1,
    (RowIdx =:= TotalRows - 1 ->
        check_row_with_star(Row, RowNumber)
    ;
        row_correct_numbers(Row, RowNumber)
    ),
    all_rows_correct_numbers(Rest, RowNumber, TotalRows).

%%%%%% letters check

% get_column_elements(+Tower, +ColIdx, -ColElements)
% returns a list of elements in certain column
% Tower - tower to work with
% ColIdx - index of column to take the elemenents from
% ColElements - output list with column elements
get_column_elements([], _, []).
get_column_elements([Row | Rest], ColIdx, [CurrentElement | L]) :-
    length(Row, NumCols),
    ColIdx < NumCols,
    nth0(ColIdx, Row, CurrentElement, _),
    get_column_elements(Rest, ColIdx, L).

% check_col_letters(+ColumnElements, +ExpectedElement)
% checks if all elements in a column contain certain expected character
% ColumnElements - elements to check
% ExpectedElement - letter that should the elements contain
check_col_letters([], _).
check_col_letters([['*', '*']], _) :- !.
check_col_letters([[Letter, _] | T], ExpectedElement) :-
    Letter == ExpectedElement,
    check_col_letters(T, ExpectedElement).

% check_columns(+Tower, +ColIdx, +NumColumns)
% checks if all the elements in all the columns have correct letter
% Tower - tower to check
% ColIdx - currect column id
% NumColumns - total number of columns
check_columns(_, ColIdx, NumColumns) :-
    ColIdx >= NumColumns, !.

check_columns(Tower, ColIdx, NumColumns) :-
    ExpectedCharCode is 65 + ColIdx, % 65 is ascii value for 'A'
    char_code(ExpectedChar, ExpectedCharCode),
    get_column_elements(Tower, ColIdx, ColElements),
    check_col_letters(ColElements, ExpectedChar),
    NextColIdx is ColIdx + 1,
    check_columns(Tower, NextColIdx, NumColumns).

% all_columns_correct_letters(+Tower, +TotalColumns)
% checks the tower for correct letters
% Tower - tower to check
% TotalColumns - total number of columns
all_columns_correct_letters(Tower, TotalColumns) :-
    check_columns(Tower, 0, TotalColumns).

% is_solved(+Tower)
% is true if the state of the babylon tower meets all the requirements above
% Tower - tower to check
is_solved(Tower) :-
    nth0(0, Tower, FirstRow),
    length(FirstRow, NumColumns),
    all_columns_correct_letters(Tower, NumColumns),
    length(Tower, NumRows),
    all_rows_correct_numbers(Tower, 0, NumRows).