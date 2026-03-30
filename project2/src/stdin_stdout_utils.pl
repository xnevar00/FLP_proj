%%%%%%%%%%%%%%%%%%%% PRL project 2 (Babylon tower) %%%%%%%%%%%%%%%%%%%
% File: stdin_stdout_utils.pl
% Description: predicates for reading from stdin and for printing solution to stdout
% Author: Veronika Nevarilova (xnevar00)
% date: 4/25
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% predicates copied from input2.pl

% read_line(-L, +C)
% reads one line of std input
% L - List representing one line
% C - character that has been read
read_line(L,C) :-
	get_char(C),
	(isEOFEOL(C), L = [], !;
		read_line(LL,_),
		[C|LL] = L).

% isEOFEOL(+C)
% checks if the given character C is either tend of file or the newline character
% C - character to be checked
isEOFEOL(C) :-
    C == end_of_file;
    (char_code(C,Code), Code==10).

% split_line(+List, -SplitList)
% splits the list into sublists of characters separated by spaces
% List - list to be split
% SplitList - the resulting list of sublists
split_line([],[[]]) :- !.
split_line([' '|T], [[]|S1]) :- !, split_line(T,S1).
split_line([32|T], [[]|S1]) :- !, split_line(T,S1).
split_line([H|T], [[H|G]|S1]) :- split_line(T,[G|S1]).

% split_lines(+List, -SplitList)
% splits all the lines into sublists of characters separated by spaces
% List - list of lines
% SplitList - the resulting list of sublists
split_lines([],[]).
split_lines([L|Ls],[H|T]) :- split_lines(Ls,T), split_line(L,H).        

% read_lines(-Ls)
% reads lines from input and stores them in the list Ls
% Ls - List of lists, each representing a line of input as a list of characters
read_lines(Ls) :-
	read_line(L,C),
	( C == end_of_file, Ls = [] ;
	  read_lines(LLs), Ls = [L|LLs]
	).

% end of predicates copied from input2.pl

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% printing output %%%%%%%%%%%%%%%%%%%%%%%%%%

% print_row(+Row)
% prints one row of tower
% Row - row to be printed
print_row(Row) :-
    print_row_elements(Row),
    nl.

% print_tower(+Tower)
% prints the tower line by line
% Tower - tower to be printed
print_tower([]).
print_tower([Row | Rest]) :-
    print_row(Row),
    print_tower(Rest).

% print_solution(+Solution)
% prints the whole solution
% Solution - path of the correct solution
print_solution([]).
print_solution([H]) :-
    print_tower(H).
print_solution([H | Solution]) :-
    print_tower(H),
    nl,
    print_solution(Solution).

% print_row_elements(+Row)
% prints row elements in correct format
% Row - row to be printed
print_row_elements([]).
print_row_elements([[Letter, Value]]) :- % last element
    write(Letter),
    write(Value).
print_row_elements([[Letter, Value] | Rest]) :-
    write(Letter),
    write(Value),
    write(' '),
    print_row_elements(Rest).