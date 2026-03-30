%%%%%%%%%%%%%%%%%%%% PRL project 2 (Babylon tower) %%%%%%%%%%%%%%%%%%%
% File: bfs.pl
% Description: implementation of Breadth-First Search (BFS)
% Author: Veronika Nevarilova (xnevar00)
% date: 4/25
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- consult(tower).

% dynamic predicate for storing visited states
:- dynamic visited_bfs/1.
reset_visited_bfs :- retractall(visited_bfs(_)).

% bfs(+Queue, -Solution)
% implements BFS algorithm
% Queue - queue with candidate solutions along with their paths
% Solution - path to correct solution
bfs([[State, Path] | _], Solution) :-
    is_solved(State),
    reverse([State | Path], Solution),
    !.

% gets all the possible moves from the current state and adds them to Queue
bfs([[State, Path] | Queue], Solution) :-
    \+ is_solved(State),
    find_neighbors_bfs(State, Path, Queue, NewQueue),
    bfs(NewQueue, Solution).

% find_neighbors_bfs(+State, +Path, +Queue, -NewQueue)
% finds new states from all possible moves (new states are the ones that are not visited)
% State - current state of tower
% Path - path leading to current state
% Queue - queue of candidate solutions
% NewQueue - Queue with added new candidate solutions
find_neighbors_bfs(State, Path, Queue, NewQueue) :-
    findall([NewState, [State | Path]], 
        (   (move_empty_cell_up(State, NewState)
            ; move_empty_cell_down(State, NewState)
            ; rotate_left(State, RowIdx, NewState)
            ; rotate_right(State, RowIdx, NewState)),
            \+ visited_bfs(NewState) % state not visited yet
        ), 
        Neighbors),
    add_to_queue(Neighbors, Queue, NewQueue),
    set_visited(Neighbors).

% add_to_queue(+State, +Queue, -NewQueue)
% adds new states to the end of queue
% State - state with path to be added
% Queue - current queue
% NewQueue - queue with added state
add_to_queue([], Queue, Queue).
add_to_queue([[State, _] | Rest], Queue, NewQueue) :-
    member(State, Queue), % already in queue
    add_to_queue(Rest, Queue, NewQueue).
add_to_queue([[State, Path] | Rest], Queue, NewQueue) :-
    \+ member(State, Queue), % the new state is not in queue yet
    append(Queue, [[State, Path]], NewQueueTail),
    add_to_queue(Rest, NewQueueTail, NewQueue).

% set_visited(+Neighbors)
% sets all neighbors as visited
% Neighbors - Neighbors to be set as visited
set_visited([]).
set_visited([[State, _] | Rest]) :-
    assertz(visited_bfs(State)),
    set_visited(Rest).
