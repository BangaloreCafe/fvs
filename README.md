Minimum Feedback Vertex Set
===
`Genetic Algorithm`

The minimum feedback vertex set in a directed graph is NP-hard problem i.e. it is very unlikely that a
polynomial algorithm can be found to solve any instance of it. It has several real-life use case, hence
it is important to study it and to create more efficient soultions for special use cases. Also, find
some near optimal solutions to general class. Here we present a genetic algorithm which breaks down problem
into individual genetic solution for a set of a graph ( Strongly Connected Components )


Finding the minimum feedback vertex Set of a directed graph
-------------------------------------------------------

- Feedback vertex set is set of vertices in a directed graph removing which  will eliminate all the
cycles of the graph.

- Please read [wiki](https://github.com/codeAshu/fvs/wiki) for detailed explanation.


-----------------------------------------------------------------------------

					
	Takes a component from strongly connected component and returns the best one which  can eliminate
	most of the cycles in that component.
   
    Hurestics : If by removing a vertex gives maximum number of strongly connected  component in
                the graph made by only that component, then consider that vertex
			   and call the other strongly connected components recursivly.

    Limitation : Graph should not have self loop and parallel loop parallel loop is loop between
	two vertices.

    Fitness Function : maximum no of strongly connected component.

