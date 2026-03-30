%%%%%%%%%%%%%%%%%%%% PRL project 2 (Babylon tower) %%%%%%%%%%%%%%%%%%%
% File: main.pl
% Description: main predicates
% Author: Veronika Nevarilova (xnevar00)
% date: 4/25
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- consult(stdin_stdout_utils).
:- consult(ids).
:- consult(bfs).

% solve(+InitialTower)
% performs the solving of the babylon tower using IDS algorithm
% InitialTower - the initial state of the tower to be solved
solve(InitialTower) :-
    ids(InitialTower, 1, Solution),
    print_solution(Solution), !.

% solve_bfs(+InitialTower)
% performs the solving of the babylon tower using BFS algorithm
% InitialTower - the initial state of the tower to be solved
solve_bfs(InitialTower) :-
    bfs([[InitialTower, []]], Solution),
    print_solution(Solution), !.

% start()
% main predicate
start() :-
    prompt(_, ''),
    read_lines(LL),
    split_lines(LL, S),
    solve(S),          % COMMENT FOR BFS VERSION
    %solve_bfs(S),     % UNCOMMENT FOR BFS VERSION
    halt.