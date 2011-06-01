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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.NoSuchElementException;

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
	private static final String BASE_CONTINENTS = "/home/milena/workspace/TSE/base/continents.ref";
	private static final String BASE_COUNTRIES = "/home/milena/workspace/TSE/base/countryInfo.ref";



	private BatchInserter inserter = null;
	private BatchInserterIndexProvider indexProvider = null;
	private BatchInserterIndex typeIndex = null;
	private BatchInserterIndex keywordIndex = null;
	private BatchInserterIndex placeIndex = null;


	public BatchInsert(){
		inserter = new BatchInserterImpl( GRAPH_URL );
		indexProvider = new LuceneBatchInserterIndexProvider( inserter );

		typeIndex = indexProvider.nodeIndex( "types", MapUtil.stringMap( "type", "exact" ) );
		keywordIndex = indexProvider.nodeIndex( "keywords", MapUtil.stringMap( "type", "fulltext" ) );
		placeIndex = indexProvider.nodeIndex( "places", MapUtil.stringMap( "type", "fulltext" ) );
	}

	public static void main(String [] args){
		long start = System.currentTimeMillis();
		BatchInsert bi = new BatchInsert();
		bi.makeReferenceNodes(new File(BASE_REF_NODE));
		bi.createContinentNodes(new File(BASE_CONTINENTS));
		bi.createCountryNodes(new File(BASE_COUNTRIES));
		bi.createAirportNodes();
		bi.createAirlineNodes(new File(BASE_AIRLINE_FILE));

		bi.stopBatch();

		long end = System.currentTimeMillis();
		System.out.println("Total time: " + (end-start));

	}


	void createCountryNodes(File file) {
		long refNode = typeIndex.get("type", "country").getSingle();
		try {
			BufferedReader reader = new BufferedReader(new FileReader(file));
			String line;
			String[] props;
			Map<String,Object> properties = new HashMap<String,Object>();
			while( (line = reader.readLine()) != null ){
				if(!line.startsWith("#")){
					props = line.split("	");
					properties.put("name", props[4]);
					properties.put("code", props[1]);
					long node = createAndIndexNode(properties, placeIndex);
					long continentNode = placeIndex.get("code", props[8]).getSingle();
					relateNodes(node, refNode, "IS");
					relateNodes(node, continentNode, "IS AT");
				}

			}
			reader.close();
			placeIndex.flush();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}catch (Exception e){
			e.printStackTrace();
		}

	}

	void createContinentNodes(File file) {
		long refNode = typeIndex.get("type", "continent").getSingle();
		try {
			BufferedReader reader = new BufferedReader(new FileReader(file));
			String line;
			String[] props;
			Map<String,Object> properties = new HashMap<String,Object>();
			while( (line = reader.readLine()) != null ){
				props = line.split("	");
				properties.put("name", props[1]);
				properties.put("code", props[0]);
				long node = createAndIndexNode(properties, placeIndex);
				relateNodes(node, refNode, "IS");
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
				if(keywordIndex.get("iata",rs.getString("iata")).getSingle() == null){
					long node = createAndIndexNode(createPOIProperties(rs), keywordIndex);
					addPOIGeoDb(rs.getString("longitude"),rs.getString("latitude"), "airport" ,  node );
					long cityNode = getOrCreateCityNode(rs.getString("city"), rs.getString("country"));
					relateNodes(refNode, node, "IS");
					relateNodes(node, cityNode, "IS AT");
					keywordIndex.flush();
				}
				
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

	void createAirlineNodes(File file) {
		long refNode = typeIndex.get("type", "airline").getSingle();
		try {
			BufferedReader reader = new BufferedReader(new FileReader(file));
			String line;
			while( (line = reader.readLine()) != null ){
				String[] props = line.split("\\^");
				if(keywordIndex.get("iata", props[0]).getSingle() == null){
					long node = createAndIndexNode(createAirlinesProperties(props), keywordIndex);
					relateNodes(node, refNode, "IS");
					keywordIndex.flush();
				}
				
			}
			reader.close();
			
			relateAirlinesAndAirports(createAirlineToAirportMap());
			
			
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}catch (Exception e){
			e.printStackTrace();
		}

	}
	
	private void relateAirlinesAndAirports(Map<String, ArrayList<String>> map) {
		for (String airline : map.keySet()) {
			Long al = keywordIndex.get("iata", airline).getSingle();
			if(! (al==null)){
				for (String airport : map.get(airline)) {
					Long ap = keywordIndex.get("iata", airport).getSingle();
					if( !(ap == null)){
						relateNodes(al, ap, "ACTS");
					}
				}
			}
			
		}
		
	}

	private Map<String, ArrayList<String>> createAirlineToAirportMap(){
		Map<String,ArrayList<String>> map = new HashMap<String,ArrayList<String>>();
		
		String dbUrl = "jdbc:mysql://nceoridb01.nce.amadeus.net/geography";
		String dbClass = "com.mysql.jdbc.Driver";
		String query = "SELECT DISTINCT destination, airline FROM `schedules`";

		try {

			Class.forName(dbClass);
			Connection con = DriverManager.getConnection (dbUrl, "sim", "pods3030");
			Statement stmt = con.createStatement();
			ResultSet rs = stmt.executeQuery(query);

			while (rs.next()) {
				if(map.containsKey(rs.getString("airline"))){
					map.get(rs.getString("airline")).add(rs.getString("destination"));
				}else{
					ArrayList<String> list = new ArrayList<String>();
					list.add(rs.getString("destination"));
					map.put(rs.getString("airline"), list);
				}
				
			}

			con.close();
		} 

		catch(ClassNotFoundException e) {
			e.printStackTrace();
		}

		catch(SQLException e) {
			e.printStackTrace();
		}
		
		return map;
	}

	private Map<String, Object> createAirlinesProperties(String[] props) {
		Map<String,Object> properties = new HashMap<String,Object>();
		
		properties.put( "name", props[2] );
		properties.put( "call_sign", props[4] );
		properties.put( "nationality", props[3] );
		properties.put( "iata", props[0].toUpperCase() );
		properties.put( "icao", props[1].toUpperCase() );

		return properties;
	}

	private void addPOIGeoDb(String longitude, String latitude,String kind, long node) {
		String dbUrl = "jdbc:postgresql://localhost/geodb";
		String dbClass = "org.postgresql.Driver";

		String sql = "INSERT INTO poi (graphid, type, place) ";
		sql += "VALUES ('"+node + "','" + kind +"',";
		sql += "ST_GeomFromText('SRID=32661;POINT("+longitude+" "+ latitude+")') );";

		try {

			Class.forName(dbClass);
			Connection con = DriverManager.getConnection (dbUrl, "postgres", "geodb");
			Statement stmt = con.createStatement();
			stmt.executeUpdate(sql);
			con.close();
		} 

		catch(ClassNotFoundException e) {
			e.printStackTrace();
		}

		catch(SQLException e) {
			e.printStackTrace();
		}

	}

	private long getOrCreateCityNode(String name, String country) {
		Long node = placeIndex.get("name", name).getSingle();
		if(node == null){
			long refNode = typeIndex.get("type", "city").getSingle();
			Map<String,Object> properties = new HashMap<String,Object>();
			properties.put("name", name);
			node = createAndIndexNode(properties, placeIndex);
			long countryNode;
			try{
				countryNode = placeIndex.query("name", removeSpecialCharacters(country) + "~").next();
			}catch (NoSuchElementException e){
				countryNode = placeIndex.query("code", country + "~").next();
			}
			relateNodes(node, refNode, "IS");
			relateNodes(node, countryNode, "IS AT");
		}

		return node;
	}

	private String removeSpecialCharacters(String word){
		return word.replaceAll("[^a-zA-Z 0-9]+"," ");
	}

	private Map<String,Object> createPOIProperties(ResultSet rs) throws SQLException{
		Map<String,Object> properties = new HashMap<String,Object>();

		properties.put( "name", rs.getString("name") );
		properties.put( "iata", rs.getString("iata").toUpperCase() );
		properties.put( "icao", rs.getString("icao").toUpperCase() );

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


