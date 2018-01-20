
/* FeedBackVetexSet.java --- demonstration of operations on directed graphs
 * Copyright (C) 2014  Ashutosh Trivedi ashu.trv@gmail.com;
 */

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Random;
import java.util.Set;

import org.jgrapht.alg.*;
import org.jgrapht.alg.cycle.SzwarcfiterLauerSimpleCycles;
import org.jgrapht.*;
import org.jgrapht.graph.*;

/********************************************************************************************************
 * Finding the feedback vertex Set of a directed graph
-------------------------------------------------------

Feedback vertex set is set of vertices in a directed graph removing which 
will eliminate all the cycles of the graph

Algorithm by Ashutosh Trivedi and Sumit Singh Chauhan
-----------------------------------------------------------------------------
Limitation : Graph should not have self loop and parallel loop parallel loop is loop between two vertices.

Takes a component from strongly connected component and returns the best one which can eliminate 
most of the cycles in that component. 

Heuristics : If by removing a vertex gives maximum number of strongly connected  component in the graph 
made by only that component, then consider that vertex and call the other strongly connected component 
Recursively.

Fitness Function : maximum no of strongly connected component.

 * @author Ashutosh and Sumit
 * @since 2014-05-17
 **********************************************************************************************************/

public class FeedBackVetexSet {

	static ArrayList<String> result = new ArrayList<>();
	static int max = 0;

	/*************************************************************************************************************
	 * @param graph
	 * @param scc
	 *
	 *Takes a component from strongly connected component and returns the best one which can eliminate most of the
	 * cycles in that component.
	 *********************************************************************************************************** */
	private static void givebest(DirectedGraph<String, DefaultEdge> graph,
			DirectedGraph<String, DefaultEdge> scc) {

		String res = null ;
		StrongConnectivityInspector<String, DefaultEdge> sci = null;


		//scc is strongest component
		Set<String> vSet = scc.vertexSet();
		Iterator<String> iter = vSet.iterator();

		//take each node from this scc and remove it from scc
		while(iter.hasNext()) {

			String iterval = iter.next();

			DirectedGraph<String, DefaultEdge> tempGraph =  new DefaultDirectedGraph<String, DefaultEdge>(DefaultEdge.class);

			Graphs.addGraph(tempGraph, scc);
			tempGraph.removeVertex(iterval);

			//again compute strongest component
			sci = new StrongConnectivityInspector<String, DefaultEdge>(tempGraph);

			//save the one which give maximum no of scc -> more cycle removal
			if( sci.stronglyConnectedSets().size() > max)
			{
				max = sci.stronglyConnectedSets().size() ;
				res = iterval;
			}
		}

		if(scc.vertexSet().size() > 2)
		{
			result.add(res);
			max=0;

			//recursive call for each scc computed from this scc 	
			DirectedGraph<String, DefaultEdge> tempGraph =  new DefaultDirectedGraph<String, DefaultEdge>(DefaultEdge.class);

			// remove the node which has removed most no of cycles
			Graphs.addGraph(tempGraph, scc);
			tempGraph.removeVertex(res);

			//again calculate scc
			sci = new StrongConnectivityInspector<String, DefaultEdge>(tempGraph);
			List<DirectedSubgraph<String, DefaultEdge>> sccList = sci.stronglyConnectedSubgraphs();


			//for all scc do the recursive call of this function
			for (int i = 0; i < sccList.size(); i++) {

				DirectedGraph<String, DefaultEdge> sub = (DirectedGraph<String, DefaultEdge>) sccList.get(i);

				if(sub.vertexSet().size() >= 3)
					givebest(graph, sub);
			}
		}
		else
			return;

	}

	public static void main(String args[]) {

		// constructs a directed graph with the specified vertices and edges
		DirectedGraph<String, DefaultEdge> graph =
				new DefaultDirectedGraph<String, DefaultEdge>
		(DefaultEdge.class);

		//add vertices and edges
		int vSize = 100;
		for (int i = 0; i < vSize ; i++) {
			graph.addVertex(Integer.toString(i));	
		}

		Random r = new Random();
		//maximum no of edges would be n(n-1)
		//lets take vSize *5 edges

		for (int i = 0; i < vSize*2; i++) {
			int s;
			int d;
			do
			{
				s = r.nextInt(vSize);
				d = r.nextInt(vSize);
			}
			while(s==d);

			graph.addEdge(Integer.toString(s), Integer.toString(d));
		}


		//print graph cycles
		SzwarcfiterLauerSimpleCycles<String, DefaultEdge> cgraph = new SzwarcfiterLauerSimpleCycles<String, DefaultEdge>(graph);	
		List<?> cList = cgraph.findSimpleCycles();

		Iterator<?> iter = cList.iterator();
		System.out.println("cycles before :");
		/*	
		while (iter.hasNext())
		{

			ArrayList<?> cycle = (ArrayList<?>) iter.next();
			System.out.println(cycle);
		}
		 */
		System.out.println("\n\n\nTotal no of cycles :"+cList.size() );
		System.out.println("\n\n");

		// computes all the strongly connected components of the directed graph
		StrongConnectivityInspector<String, DefaultEdge> sci =
				new StrongConnectivityInspector<String, DefaultEdge>(graph);
		List<?> stronglyConnectedSubgraphs = sci.stronglyConnectedSubgraphs();



		// prints the strongly connected components
		System.out.println("Strongly connected components:");
		for (int i = 0; i < stronglyConnectedSubgraphs.size(); i++) {
			System.out.println(stronglyConnectedSubgraphs.get(i));
		}

		//for each scc run the algorithm
		for (int i = 0; i < stronglyConnectedSubgraphs.size(); i++) {

			//get the vertex list of strongly connected component
			@SuppressWarnings("unchecked")
			DirectedGraph<String, DefaultEdge> sub = (DirectedGraph<String, DefaultEdge>) stronglyConnectedSubgraphs.get(i);

			givebest(graph,sub);

		}
		System.out.println();


		//remove duplicates
		HashSet<String> hs = new HashSet<String>();
		hs.addAll(result);
		result.clear();
		result.addAll(hs);

		System.out.println("Feedback Vertex set :");
		System.out.print("[");
		for (String res : result) {
			System.out.print(res+" ");
		}
		System.out.print("]");
		System.out.println();


		DirectedGraph<String, DefaultEdge> tempGraph =  new DefaultDirectedGraph<String, DefaultEdge>(DefaultEdge.class);
		Graphs.addGraph(tempGraph, graph);

		for (String res : result) {
			tempGraph.removeVertex(res);
		}

		/*****************************************Print Results*******************************************************/

		System.out.println("\ncycle after removing the FVS ");
		SzwarcfiterLauerSimpleCycles<String, DefaultEdge> resGraph = new SzwarcfiterLauerSimpleCycles<String, DefaultEdge>(tempGraph);	
		List<?> resList = resGraph.findSimpleCycles();

		Iterator<?> resiter = resList.iterator();
		if(resList.size() >0)
		{
			
			while (resiter.hasNext())
				System.out.println(resiter.next());
		}
		else
			System.out.println("\nAll cycles have been removed !!");


	}
}