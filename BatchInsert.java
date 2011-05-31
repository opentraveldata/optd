import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.HashMap;
import java.util.Map;

import org.neo4j.graphdb.DynamicRelationshipType;
import org.neo4j.graphdb.index.BatchInserterIndex;
import org.neo4j.graphdb.index.BatchInserterIndexProvider;
import org.neo4j.helpers.collection.MapUtil;
import org.neo4j.index.impl.lucene.LuceneBatchInserterIndexProvider;
import org.neo4j.kernel.impl.batchinsert.BatchInserter;
import org.neo4j.kernel.impl.batchinsert.BatchInserterImpl;


public class BatchInsert {
	
	private static final String GRAPH_URL = "/home/milena/graph/data/graph.db/";
	private static final String BASE_AIRLINE_FILE = "/home/milena/workspace/TSE/base/airlines.ref";
	private static final String BASE_REF_NODE = "/home/milena/workspace/TSE/base/reference_nodes.ref";
	
	
	private BatchInserter inserter = null;
	private BatchInserterIndexProvider indexProvider = null;
	private BatchInserterIndex typeIndex = null;
	private BatchInserterIndex codeIndex = null;
	private BatchInserterIndex keywordIndex = null;
	private BatchInserterIndex placeIndex = null;
	
	
	public BatchInsert(){
		inserter = new BatchInserterImpl( GRAPH_URL );
		indexProvider = new LuceneBatchInserterIndexProvider( inserter );
		
		typeIndex = indexProvider.nodeIndex( "types", MapUtil.stringMap( "type", "exact" ) );
		codeIndex = indexProvider.nodeIndex( "codes", MapUtil.stringMap( "type", "exact" ) );
		keywordIndex = indexProvider.nodeIndex( "keywords", MapUtil.stringMap( "type", "fulltext" ) );
		placeIndex = indexProvider.nodeIndex( "places", MapUtil.stringMap( "type", "fulltext" ) );
	}
	
	public static void main(String [] args){
		long start = System.currentTimeMillis();
		BatchInsert bi = new BatchInsert();
		bi.makeReferenceNodes(new File(BASE_REF_NODE));
		
		//TODO change files or databases ..
		bi.createContinentNodes(null);
		bi.createCountryNodes(null);
		
		bi.createAirportNodes();
		bi.createAirlineNodes(BASE_AIRLINE_FILE);
		
		bi.stopBatch();
		
		long end = System.currentTimeMillis();
		System.out.println("Total time: " + (end-start));
		
	}


	void createCountryNodes(File file) {
		try {
			BufferedReader reader = new BufferedReader(new FileReader(file));
			String line;
			Map<String,Object> properties = new HashMap<String,Object>();
			while( (line = reader.readLine()) != null ){
				//TODO change the properties according to the file it cames from
		        properties.put("name", line.split("\n")[0]);
				long node = createAndIndexNode(properties, placeIndex);
				//TODO mudar aqui para o nome do continente ou código ...
				long continentNode = placeIndex.get("name", line).getSingle();
				relateNodes(node, continentNode, "IS AT");
			}
			reader.close();
			placeIndex.flush();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		
	}

	void createContinentNodes(File file) {
		try {
			BufferedReader reader = new BufferedReader(new FileReader(file));
			String line;
			Map<String,Object> properties = new HashMap<String,Object>();
			while( (line = reader.readLine()) != null ){
				//TODO change the properties according to the file it cames from
		        properties.put("name", line.split("\n")[0]);
				createAndIndexNode(properties, placeIndex);
			}
			reader.close();
			placeIndex.flush();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		
	}

	void stopBatch(){
		indexProvider.shutdown();
		inserter.shutdown();
	}
	
	void makeReferenceNodes(File file){
		try {
			BufferedReader reader = new BufferedReader(new FileReader(file));
			String line;
			Map<String,Object> properties = new HashMap<String,Object>();
			while( (line = reader.readLine()) != null ){
		        properties.put("type", line.split("\n")[0].toLowerCase());
				createAndIndexNode(properties, typeIndex);
			}
			reader.close();
			typeIndex.flush();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	void createAirportNodes(){
		long refNode = typeIndex.get("type", "airport").getSingle();
		
		String dbUrl = "jdbc:mysql://nceoridb01.nce.amadeus.net/geography";
		String dbClass = "com.mysql.jdbc.Driver";
		String query = "SELECT * FROM icao";

		try {

			Class.forName(dbClass);
			Connection con = DriverManager.getConnection (dbUrl, "sim", "pods3030");
			Statement stmt = con.createStatement();
			ResultSet rs = stmt.executeQuery(query);

			while (rs.next()) {
				long node = createAndIndexNode(createPOIProperties(rs), keywordIndex);
				//TODO change this numbers with the right number or name.
				addPOIGeoDb(rs.getString(1),rs.getString(1), node );
				long cityNode = getOrCreateCityNode(rs.getString("city"));
				relateNodes(refNode, node, "IS");
				relateNodes(node, cityNode, "IS AT");
				
			}

			con.close();
		} 

		catch(ClassNotFoundException e) {
			e.printStackTrace();
		}

		catch(SQLException e) {
			e.printStackTrace();
		}
		
	}
	
	void createAirlineNodes(String baseAirlineFile) {
		long refNode = typeIndex.get("type", "airline").getSingle();
		//TODO well ... to do :P
		
	}
	
	private void addPOIGeoDb(String longitude, String latitude, long node) {
		// TODO Connect with PostGIS
		
	}

	private long getOrCreateCityNode(String name) {
		long node = 0;
		try{
			node = placeIndex.get("name", name).getSingle();
		}catch (Exception e){
			Map<String,Object> properties = new HashMap<String,Object>();
			properties.put("name", name);
			node = createAndIndexNode(properties, placeIndex);
			//TODO how to relate with the country or region
		}
		return node;
	}
	
	private Map<String,Object> createPOIProperties(ResultSet rs) throws SQLException{
		Map<String,Object> properties = new HashMap<String,Object>();
        
		//TODO finish properties names/numbers
        properties.put( "name", rs.getString(1) );
        properties.put( "iata", rs.getString(1).toUpperCase() );
        properties.put( "icao", rs.getString(1).toUpperCase() );
        
        return properties;
		
	}
	
	private void relateNodes(long node1,long node2,String label){
		inserter.createRelationship( node1, node2, DynamicRelationshipType.withName( label ), null );
	}
	
	private long createAndIndexNode(Map<String,Object> properties, BatchInserterIndex index){
        long node = inserter.createNode( properties );
        index.add( node, properties );
        
        return node;
	}
	
}


