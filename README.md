fvs
===

Feed back vertex set

Finding the feedback vertex Set of a directed graph
-------------------------------------------------------

Feedback vertex set is set of vertices in a directed graph removing which 
will eliminate all the cycles of the graph

Algorithm by Ashutosh Trivedi and Sumit Singh Chauhan
IIIT Bangalore , 01-05-2014
-----------------------------------------------------------------------------
	Limitation : Graph should not have self loop and parallel loop parallel loop is loop between two vertices.
					
	Takes a componant from strongly connected componant and returns the best one which  can eliminate most of the cycles in that componant. 
   
    Hurestics : If by removing a vertex gives maximum number of strongly connected 
			   componant in the graph made by only that componant, then consider that vertex 
			   and call the other strongly connected componants recursivly.

Fitness Function : maximum no of strongly connected componant.
	

generating a random graph, just input the vertex size  and edge set size. go to psvm function to do the change.
Not taking user inputs. lazy to do that. Feel free to change the way it takes the input
