Finding the feedback vertex Set of a directed graph
-------------------------------------------------------

Usage
------

Load graph.ml, it has a buil in input either change it in the file or use following format of 
giving input.

(*create graph*)
let g2 = create();;

(*add vetices*)
let v1 = add_vertex g2;;
let v2 = add_vertex g2;;
let v3 = add_vertex g2;;

(*add edges*)
add_edge (v1, v2, 1);;
add_edge (v2, v3, 1);;
add_edge (v3, v1, 1);;

(*This also is requirement*)
vset_ids (component v1);;
vset_ids (component v2);;
vset_ids (component v3);;

vset_ids (strong_component v1);;
vset_ids (strong_component v2);;
vset_ids (strong_component v3);;

(*call function fvs <graph>*)
fvs g2
	