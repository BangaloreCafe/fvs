fvs
===

Feed back vertex set

Finding the feedback vertex Set of a directed graph
-------------------------------------------------------

Feedback vertex set is set of vertices in a directed graph removing which 
will eliminate all the cycles of the graph

Algorithm by Ashutosh Trivedi and Sumit Singh Chauhan

<object data="http://yoursite.com/the.pdf" type="application/pdf" width="700px" height="700px">
    <embed src="https://raw.githubusercontent.com/codeAshu/fvs/master/info.pdf">
        This browser does not support PDFs. Please download the PDF to view it: <a href="http://yoursite.com/the.pdf">Download PDF</a>.</p>
    </embed>
</object>

-----------------------------------------------------------------------------
	Limitation : Graph should not have self loop and parallel loop parallel loop is loop between
	two vertices.
					
	Takes a component from strongly connected component and returns the best one which  can eliminate
	most of the cycles in that component.
   
    Hurestics : If by removing a vertex gives maximum number of strongly connected  component in
                the graph made by only that component, then consider that vertex
			    and call the other strongly connected components recursivly.

Fitness Function : maximum no of strongly connected component.
	

