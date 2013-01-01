=========================
run:
	*swipl -s lab3.pl -g reset*

set first vertex in path
(calculate lengths for this vertex), e.g. 0:
	*set_shortest_paths(0).*

get length of shortest path between specified vertex and another vertex, e.g. 2:
	*get_tag(2,T).*

get shortest path between specified vertex and another vertex, e.g. 2:
	*get_shortest_path(0,2,Path).*

reset first vertex (and calculated lengths):
	*reset.*
