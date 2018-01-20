
(* An Algorithm for finding the feedback vertex Set of a directed graph  *)
(*
Author : Ashutosh Trivedi
		 Sumit Singh Chauhan
*)
  
 (********************************************************************************************************
	A graph is represented as a pair of counter of the number of vertices and a list of vertices.
	A vertex is represented as a triple of a unique integer ID, an outgoing list and an incoming list.
	An edge is a triple of a source vertex, destination vertex and weight 
 *********************************************************************************************************)
  type vertex = V of (int * ((vertex * int) list ref) * ((vertex * int) list ref))
  type edge = vertex * vertex * int
  type graph = (int ref * (vertex list) ref)

 
 (**********************************************************************************
  Helper functions for extracting the values from graph and its vertices!! 
 ***********************************************************************************)
  let compare_v (V (id1, _, _)) (V (id2, _, _)) = compare id1 id2

  let create () = (ref 0, ref [])

  let is_empty (c, _) = !c = 0

  let vertices (_, vl) = !vl

  let num_vertices (c, _) = !c

  let edge_info e = e

  let vertex_id (V (id, _,  _)) = id

  let outgoing src =
    let V (_, ol, _) = src in
    List.map (fun (dst, w) -> (src, dst, w)) !ol

  let incoming_rev revsrc =
    let V (_, _, il) = revsrc in
    List.map (fun (revdst, w) -> (revsrc, revdst, w)) !il

  let incoming dst =
    let V (_, _, il) = dst in
    List.map (fun (src, w) -> (src, dst, w)) !il

  let out_degree (V (_, ol, _)) = List.length !ol

  let in_degree (V (_, _, il)) = List.length !il

  let edges (_, vl) = List.flatten (List.map outgoing !vl)

  
 (*Find out consequtive duplicate and remove them !!*) 
  let compress l =
	let rec compress_2 l e =
		 match l with
		[]      -> [e]
		| h::t  ->
				if ( h = e ) 
					then ( compress_2 t e )      (*ignore until its same as e*)
				else e::( compress_2 t h )	 	 (*as somthing other than e comes append it to e and recursive call*)
	in
		match l with
		[]      -> []
		|       h::t    -> compress_2 t h
;;

(*Set of function to remove l2 from l1 and return the remaining list!!*) 
	let rec find x l = 
	match l with
	[]->false
	|h::t -> if(h = x) then true else find x t

	let rec remove l1 l2 =
	match l1 with
	h::t -> if (find h l2) then (remove t l2) else h::remove t l2
	|[]->[] 
	;;

(* Set of function to print a list of list *) 
	let rec print_list = function 
	[] -> ()
	| e::l -> print_int e ; print_string " " ; print_list l
		
	let rec print_list_list = function 
	[] -> ()
	| e::l -> print_list e ; print_string " " ; print_list_list l	
;;
(**********************************************************************************
  Graph Modification Functions :
  add_vertex
  add_edge
  remove_edge
  remove_vertex
 ***********************************************************************************)  
  
  let add_vertex (c, vl) =
    incr c;
    let v = V (!c, ref [], ref []) in
    vl := v :: !vl;
    v

  (* When adding and removing edges, dst goes in out-list of src
   * and src goes in in-list of dst *)
  let add_edge (src, dst, w) =
    let V (id1, ol, _), V (id2, _, il) = src, dst in
    ol := (dst, w) :: !ol;
    il := (src, w) :: !il

  let remove_edge (src, dst) =
    let V (_, ol, _), V (_, _, il) = src, dst in
    ol := List.remove_assoc dst !ol;
    il := List.remove_assoc src !il

  let remove_vertex g v =
    match v with V (id, ol, il) ->
      (* Remove v from in-list of all vertices on its out-list and
         from out-list of all vertices on its in-list.  *)
      (List.iter (fun (dst, w) ->
        match dst with
      V (_, _, il') -> il' := List.remove_assoc v !il') !ol;
       List.iter (fun (src, w) ->
        match src with
      V(_, ol', _) -> ol' := List.remove_assoc v !ol') !il;
       ol := [];
       il := [];
       (* Decrease vertex count and remove from vertex list. *)
       match g with (c, vl) ->
         c := !c - 1;
         vl := List.filter (function (V (id', _, _)) -> id' <> id) !vl)

  
  
  
  (******************************************************************************************
     To copy a graph, create a map from vertices of the old graph to
     vertices of the new graph, then iterate over edges of the old
     graph adding edges between corresponding vertices of the new graph (using the map).
   *****************************************************************************************) 

  module VMap = Map.Make (struct type t = vertex let compare = compare end)

  let copy g =
    let map = ref VMap.empty in
    let ng = (ref 0, ref []) in
    match g with
      (_, vl) ->
        match ng with
          (nc,nvl) ->
            (* Create new vertices and add to map from old
             * vertices, ensuring corresponding vertices have same
             * id number. *)
             (List.iter
               (function v ->
                  match v with V (id, _, _) ->
                    (nc := !nc + 1;
                    nvl := V (id, ref [], ref []) :: !nvl;
                    map := VMap.add v (List.hd !nvl) !map))
              !vl;
       (* Iterate over old edges, for each creating
        * corresponding new edge by looking up new
        * vertices in map. *)
       List.iter
         (function e ->
            match e with
              (src, dst, w) ->
                 let nsrc = VMap.find src !map
                 and ndst = VMap.find dst !map in
                 (match nsrc with
                    V (_, ol, _) -> ol := (ndst, w) :: !ol;
                    match ndst with
                      V(_, _, il) -> il := (nsrc, w) :: !il))
         (edges g);
       ng)

(* 
Sets of vertices, used in traversing from a node via DFS or BFS 
*)

module VSet = Set.Make (struct type t = vertex let compare = compare end)

let vset_ids v = List.map vertex_id (VSet.elements v)

(* A signature matched by queues and stacks *)
module type BagType =
  sig
    type 'a t
    exception Empty
    val create : unit -> 'a t
    val push : 'a -> 'a t -> unit
    val pop : 'a t -> 'a (* raises Empty *)
    val top : 'a t -> 'a (* raises Empty *)
    val clear : 'a t -> unit
    val copy : 'a t -> 'a t
    val is_empty : 'a t -> bool
    val length : 'a t -> int
    val iter : ('a -> unit) -> 'a t -> unit
  end
  
(* A Bag is something that you can put things into *)
(* and take them out of *)
    
(* Functor that makes a Bag out of a queue or stack *)
module MakeBag =
  functor (X : BagType) ->
    struct
      exception Empty = X.Empty
      type 'a t = 'a X.t
      let create = X.create
      let put = X.push
      let get = X.pop (* raises Empty *)
      let next = X.top (* raises Empty *)
      let clear = X.clear
      let copy = X.copy
      let is_empty = X.is_empty
      let size = X.length
      let iter = X.iter
    end

(* use Queue for BFS, Stack for DFS *)
module Bag = MakeBag (Queue)



  (***************************************************************************************
   Simple graph traversal (BFS or DFS) returns a set of nodes accessible from a starting node. 
   ***************************************************************************************)
let traverse v0 dir =
  let disc = Bag.create()
  and visited = ref VSet.empty in
    (* Expand the visited set to contain everything v goes to,
     * and add newly seen vertices to the stack/queue. *)
  let expand v =
    let handle_edge e =
      let (v, v', _) = edge_info e in
  if not (VSet.mem v' !visited)
  then (visited := (VSet.add v' !visited); Bag.put v' disc)
  else () in
  List.map handle_edge (if dir < 0 then (incoming_rev v) else (outgoing v))
  in
    (visited := VSet.add v0 !visited;
     Bag.put v0 disc;
     while (not (Bag.is_empty disc)) do
       ignore (expand (Bag.get disc))
     done;
     !visited)

(* Weakly connected component containing v0, simply the set of nodes
   accessible from this node.  *)

let component v0 = traverse v0 1

(* Strongly connected component containing v0, intersecting the weak
   components found using traverse in the graph and in the graph with
   the edges reversed.  *)

let strong_component v0 =
  VSet.inter (traverse v0 1) (traverse v0 (-1))

(************************************************************************************ 
   The strongly connected components form a partition of the vertices.
 ************************************************************************************)
	 let strong_components g =
	  let vs = ref VSet.empty
	  and cs = ref [] in
		(List.iter (fun v -> vs := VSet.add v !vs) (vertices g);
		 while (not (VSet.is_empty !vs)) do
		   let c = strong_component (VSet.choose !vs) in
		   (vs := VSet.diff !vs c;
		   cs := c::!cs)
		 done;
		 !cs)

(************************************************************************************ 
   Takes a graph and vertex_id and remove that vertex based on the id passed to it
 ************************************************************************************)
 
let modify_graph gr y =
 let vl = vertices gr in
    if vl = [] then []
	else
		let sl = List.filter (fun v -> vertex_id v = y) vl in
        if sl = []  
			then []
		else
		let v = List.hd sl in remove_vertex gr v;
		(*return dummy for handling side effect in the give_best function*)
		[]
;;


(****************************************************************************************************************** 
   Takes a componant from strongly connected componant and returns the best one which 
   can eliminate most of the cycles in that componant.
   
    Hurestics : If by removing a vertex it gives maximum number of strongly connected 
			   componant in the graph made by only that componant, the use that and call the other strongly
			   connected componants recursivly.

    Fitness Function : maximum no of strongly connected componant.
 ************************************************************************************************************************)
	let give_best ls blst g =
	   let rec loop ls g = 
		let nList = ls in
		let scc =  ref [[]]  in
		let culprit =   ref 900 in
		let max = ref 0 in	
		 (*check each vertex in this scc and remove then than take the one which gives maximum scc*)
		 List.iter (function v -> 
				let gr = copy g in
				let fList =ref[] in
				(*create a new graph of only for this strongly connected componant*)
				let graphList = remove  (List.flatten blst) ls  in
							   List.iter( function y ->	fList := modify_graph gr y;) graphList;   
				fList := modify_graph gr v;
				(*strongly connected componant by removing one vertices in the graph*)
				scc := List.map vset_ids(strong_components gr) ;
				(*fitness process to choose the one which give maximum no of strongly connected componants*)
				if !max < (List.length !scc) 
					then begin
						   max := (List.length !scc);
						   culprit := v; 
				end
	    ) nList;
	if (List.length ls) > 2
	  (*append the best one and call recursivly*)
	  then 	[!culprit]@ (loop (List.flatten ( List.filter (fun v -> (List.length v) > 2) !scc))   g)  
	else
	   []
	in
	loop ls g
	
;;
(****************************************************************************
	Takes List of list of all the strongly conected componants.
	Does exception handling and pass each scc set to give_best function

******************************************************************************) 
	let rec decode (l:int list list) g =
		if (List.tl l) = [] then give_best (List.hd l) l g
		else
			if (List.length (List.hd l)) > 2 
				
				then (give_best (List.hd l) l g) @ (decode (List.tl l) g)
			else	 
				(List.hd l)@(decode (List.tl l) g)	
;;

(*************************************************************************************************************
	Calculate the strongly connected componants and pass them to decode function
****************************************************************************************************************)
let remove_cycle g = 
let pcc = List.filter(fun v -> List.length v > 2) (List.map vset_ids (strong_components g);)
in decode pcc g

(*************************************************************************************************************
	After getting the result from decode it append one of the vertex from scc which has just two elements
	One of them has to be killed to be able to get all the loops out of the graph
****************************************************************************************************************)
let fvs g = 
let res =  compress( List.sort compare (remove_cycle g) ) in
res

(***********************************************************************************************************************)


(* Simple test cases  *)

let g1 = create();;

let v1 = add_vertex g1;;
let v2 = add_vertex g1;;
let v3 = add_vertex g1;;
let v4 = add_vertex g1;;
let v5 = add_vertex g1;;
let v6 = add_vertex g1;;
let v7 = add_vertex g1;;
let v8 = add_vertex g1;;
let v9 = add_vertex g1;;
let v10 = add_vertex g1;;

add_edge (v1, v4, 1);;
add_edge (v1, v2, 1);;

add_edge (v2, v5, 1);;
add_edge (v2, v3, 1);;

add_edge (v3, v5, 1);;
add_edge (v3, v9, 1);;

add_edge (v4, v5, 1);;
add_edge (v4, v6, 1);;

add_edge (v6, v5, 1);;
add_edge (v6, v7, 1);;

add_edge (v7, v6, 1);;
add_edge (v7, v3, 1);;
add_edge (v7, v9, 1);;

add_edge (v8, v10, 1);;
add_edge (v8, v6, 1);;

add_edge (v9, v10, 1);;
add_edge (v9, v1, 1);;

add_edge (v10, v7, 1);;
add_edge (v10, v8, 1);;

vset_ids (component v1);;
vset_ids (component v2);;
vset_ids (component v3);;
vset_ids (component v4);;
vset_ids (component v5);;
vset_ids (component v6);;
vset_ids (component v7);;
vset_ids (component v8);;
vset_ids (component v9);;
vset_ids (component v10);;

vset_ids (strong_component v1);;
vset_ids (strong_component v2);;
vset_ids (strong_component v3);;
vset_ids (strong_component v4);;
vset_ids (strong_component v5);;
vset_ids (strong_component v6);;
vset_ids (strong_component v7);;
vset_ids (strong_component v8);;
vset_ids (strong_component v9);;
vset_ids (strong_component v10);;

Printf.printf "\n--------------Output------------\n\n";
(*Call fvs on the graph created above *)
fvs g1;;

