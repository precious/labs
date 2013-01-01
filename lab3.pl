%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% auxiliary predicates %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vertex(V) :- edge(V,_,_); edge(_,V,_).

%%%%%%%%%%% marks utils %%%%%%%%%%%%%%
:- dynamic marked/1.
marked(V) :- fail.
unmarked(V) :- vertex(V), not(marked(V)).
mark(V) :- assert(marked(V)).
get_all_unmarked(L) :- findall(Next,unmarked(Next),U), list_to_set(U,L).
get_all_verices(L) :- findall(V,vertex(V),U), list_to_set(U,L).
%%% V ---> Neighbor
unmarked_neighbor(V,N) :- edge(V,N,_), unmarked(N).
get_all_unmarked_neighbors(V,L) :-
	findall(Next,unmarked_neighbor(V,Next),U), list_to_set(U,L).

%%%%%%%%%% tags utils %%%%%%%%%%%%%%%%
:- dynamic get_tag_internal/2.
get_tag_internal(0,1000000).
get_tag(V,T) :- (get_tag_internal(V,T) -> get_tag_internal(V,T); T = 1000000).
set_tag(V,T) :- (get_tag_internal(V,_) -> retract(get_tag_internal(V,_)); true),
	assert(get_tag_internal(V,T)).

reset_tags_and_marks([]).
reset_tags_and_marks([H|T]) :- set_tag(H,1000000),
	(marked(H) -> retract(marked(H)); true), reset_tags_and_marks(T).
reset :- consult('base.pl'), get_all_verices(L), reset_tags_and_marks(L).

%%%%%%%% selection utils %%%%%%%%%%%%%
get_vertex_with_min_tag_from_list([H|T],V) :-
	get_vertex_with_min_tag_from_list(T,H,V).

get_vertex_with_min_tag_from_list([],V,V).
get_vertex_with_min_tag_from_list([H|T],Prev,V) :- 
	get_tag(Prev,T_p), get_tag(H,T_h),
	(T_p > T_h -> Min = H; Min = Prev),
	get_vertex_with_min_tag_from_list(T,Min,V).
	
get_unmarked_with_min_tag(V) :- 
	get_all_unmarked(L), (L == [] -> 
		fail;
		get_vertex_with_min_tag_from_list(L,V)
	).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Dijkstra shortest path algorithm %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
process_vertices_recursively :- 
	get_unmarked_with_min_tag(V), % when this fails, predicate fails as well
	get_all_unmarked_neighbors(V,L),
	process_neighbors(V,L),
	mark(V),
	process_vertices_recursively.

%%% V ---> Neighbor
process_neighbors(V,[]).
process_neighbors(V,[H|T]) :-
	get_tag(V,T_v),get_tag(H,T_h),edge(V,H,E_lengt),Sum is T_v + E_lengt,
	(Sum < T_h -> set_tag(H,Sum); true),
	process_neighbors(V,T).

% next predicate sets for each vertex length of shortest path from F as tag
set_shortest_paths(F) :-
	set_tag(F,0),
	process_vertices_recursively; true.

%%% Neighbor ---> V
neighbor_in_path(V,T_v,N) :- edge(N,V,E_length), get_tag(N,T_n), 
	Sum is T_n + E_length, Sum == T_v.
get_previous(V,P) :-
	get_tag(V,T_v),
	findall(Neighbor,neighbor_in_path(V,T_v,Neighbor),Neighbors),
	nth0(0,Neighbors,P).

get_shortest_path(F,F,P,Res) :- append([F],P,Res).
get_shortest_path(F,S,P,Res) :-
	get_previous(S,Prev),
	get_shortest_path(F,Prev,[S|P],Res).

% predicate for getting shortest path between verices F and S
% predicate set_shortest_paths(F) should be called first
get_shortest_path(F,S,Res) :- get_shortest_path(F,S,[],Res), !.
