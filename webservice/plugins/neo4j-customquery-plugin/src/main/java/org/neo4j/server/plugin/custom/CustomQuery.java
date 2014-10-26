package org.neo4j.server.plugin.custom;
import java.util.ArrayList;
import java.util.List;

import org.neo4j.graphdb.GraphDatabaseService;
import org.neo4j.graphdb.Node;
import org.neo4j.graphdb.index.Index;
import org.neo4j.graphdb.index.IndexHits;
import org.neo4j.graphdb.index.IndexManager;
import org.neo4j.index.lucene.QueryContext;
import org.neo4j.server.plugins.Description;
import org.neo4j.server.plugins.Parameter;
import org.neo4j.server.plugins.PluginTarget;
import org.neo4j.server.plugins.ServerPlugin;
import org.neo4j.server.plugins.Source;

@Description("Custom Query Plugin")
public class CustomQuery extends ServerPlugin{
	@Description( "Make a custom query and limit the results" )
	@PluginTarget( GraphDatabaseService.class )
	public Iterable<Node> makeQuery(
			@Source GraphDatabaseService graphDb,
			@Description( "The query to be looked for" )
			@Parameter( name = "query" ) String query,
			@Description( "The maximum number of results." )
			@Parameter( name = "max" ) int max )
			{
		IndexManager index = graphDb.index();
		Index<Node> keywordsIndex = index.forNodes( "keywords" );

		QueryContext theQuery = new QueryContext( query );
		IndexHits<Node> hits = keywordsIndex.query( theQuery.sortByScore() );
		List<Node> results = new ArrayList<Node>();

		try	{
			int i =0;
			while(hits.hasNext() && i< max){
				results.add(hits.next());
				i++;
			}

		}finally{

			hits.close();
		}


		return results;
			}

}
