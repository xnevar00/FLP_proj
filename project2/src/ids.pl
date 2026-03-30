%%%%%%%%%%%%%%%%%%%% PRL project 2 (Babylon tower) %%%%%%%%%%%%%%%%%%%
% File: ids.pl
% Description: implementation of Iterative Deepening Search algorithm (IDS)
% Author: Veronika Nevarilova (xnevar00)
% date: 4/25
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- consult(tower).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% solving using IDS algorithm %%%%%%%%%%%%%%%%%%%%

% ids(+InitialState, +MaxDepth, -Solution)
% runs the DLS algorithm repeatedly with increasing depth limit
% InitialState - the initial state of the tower to be solved
% MaxDepth - maximum depth for the DLS algorithm to dive to
% Solution - path to solution, if found.
ids(InitialState, MaxDepth, Solution) :-
    dls([InitialState], MaxDepth, Solution), !.

ids(InitialState, MaxDepth, Solution) :-
    NewLimit is MaxDepth + 1,
    ids(InitialState, NewLimit, Solution).

% dls(+Path, +Visited, +MaxDepth, -Solution)
% performs the DLS algorithm
% Path - path with current state in the head of the list
% Visited - list of already visited states
% MaxDepth - maximum depth to look for the solution in
% Solution - path to solution (list of tower states)
dls([State | Path], _, Solution) :-
    is_solved(State),
    reverse([State | Path], Solution).

dls([State | Path], MaxDepth, Solution) :-
    MaxDepth > 0,
    NewMaxDepth is MaxDepth - 1,
    find_neighbors(State, [State | Path], NewMaxDepth, Solution).

% find_neighbors(+State, +Path, +Visited, +MaxDepth, -Solution)
% finds neighbors and explores them recursively
% State - current state
% Path - path to current state
% Visited - list of already visited states
% MaxDepth - maximum depth to look for the solution in
% Solution - path to solution (list of tower states)
find_neighbors(State, Path, MaxDepth, Solution) :-
    findall(NextState,
        (   (
                move_empty_cell_up(State, NextState)
            ;   move_empty_cell_down(State, NextState)
            ;   rotate_left(State, _, NextState)
            ;   rotate_right(State, _, NextState)
            ),
            \+ memberchk(NextState, Path)
        ),
        Neighbors),
    explore_neighbors(Neighbors, Path, MaxDepth, Solution).

% explore_neighbors(+Neighbors, +Path, +Visited, +MaxDepth, -Solution)
% run DLS on each neighbor recursively
% Neighbors - all the neighbors of current state
% Path - path to current state including the current state
% Visited - list of already visited states
% MaxDepth - maximum depth to look for the solution in
% Solution - path to solution (list of tower states)
explore_neighbors([], _, _, _) :- fail.
explore_neighbors([N | Ns], Path, MaxDepth, Solution) :-
    dls([N | Path], MaxDepth, Solution)
    ;  % if not found solution with current neighbor, try with other neighbors
    explore_neighbors(Ns, Path, MaxDepth, Solution).