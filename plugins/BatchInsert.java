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

import org.neo4j.graphdb.DynamicRelationshipType;
import org.neo4j.graphdb.index.BatchInserterIndex;
import org.neo4j.graphdb.index.BatchInserterIndexProvider;
import org.neo4j.helpers.collection.MapUtil;
import org.neo4j.index.impl.lucene.LuceneBatchInserterIndexProvider;
import org.neo4j.kernel.impl.batchinsert.BatchInserter;
import org.neo4j.kernel.impl.batchinsert.BatchInserterImpl;

import com.csvreader.CsvReader;


/**
 * Class responsible to insert bulk information into the graph and geo databases.
 * @author Milena Araujo
 *
 */
public class BatchInsert {

	/**
	 * Absolute path to the graph database.
	 */
	private static final String GRAPH_URL = "/home/milena/graph/data/graph.db/";

	/**
	 * Absolute path to the files used to gather information.
	 */
	private static final String BASE_AIRLINE_FILE = "/home/milena/workspace/TSE/base/airlines.ref";
	private static final String BASE_AIRPORT_FILE = "/home/milena/workspace/TSE/base/airports.csv";
	private static final String BASE_REF_NODE = "/home/milena/workspace/TSE/base/reference_nodes.ref";
	private static final String BASE_CONTINENTS = "/home/milena/workspace/TSE/base/continents.ref";
	private static final String BASE_COUNTRIES = "/home/milena/workspace/TSE/base/countries.csv";


	/**
	 * Neo4j's classes to do the bulk insert.
	 */
	private BatchInserter inserter = null;
	private BatchInserterIndexProvider indexProvider = null;
	private BatchInserterIndex typeIndex = null;
	private BatchInserterIndex keywordIndex = null;
	private BatchInserterIndex labelIndex = null;
	private BatchInserterIndex placeIndex = null;


	/**
	 * Constructor that only initiates the batchinsert.
	 */
	public BatchInsert(){
		inserter = new BatchInserterImpl( GRAPH_URL );
		indexProvider = new LuceneBatchInserterIndexProvider( inserter );

		typeIndex = indexProvider.nodeIndex( "types", MapUtil.stringMap( "type", "exact" ) );
		keywordIndex = indexProvider.nodeIndex( "keywords", MapUtil.stringMap( "type", "fulltext" ) );
		labelIndex = indexProvider.relationshipIndex( "labels", MapUtil.stringMap( "type", "fulltext" ) );
		placeIndex = indexProvider.nodeIndex( "places", MapUtil.stringMap( "type", "fulltext" ) );
	}

	/**
	 * Executes the bulk insert and shows the duration of it in the default output.
	 */
	public static void main(String [] args){
		long start = System.currentTimeMillis();
		BatchInsert bi = new BatchInsert();
		bi.makeReferenceNodes(new File(BASE_REF_NODE));
		bi.createContinentNodes(new File(BASE_CONTINENTS));
		bi.createCountryNodes();
		bi.createAirportNodes();
		bi.createAirlineNodes(new File(BASE_AIRLINE_FILE));

		bi.stopBatch();

		long end = System.currentTimeMillis();
		System.out.println("Total time: " + (end-start));

	}


	/**
	 * Creates nodes for the entity of the kind Country.
	 * @param file which has all the information concerned to the country.
	 */
	void createCountryNodes() {
		long refNode = typeIndex.get("type", "country").getSingle();

		try {
			CsvReader countries = new CsvReader(BASE_COUNTRIES);
			countries.readHeaders();

			while (countries.readRecord()){
				Map<String,Object> properties = new HashMap<String,Object>();
				properties.put("name", countries.get("name"));
				properties.put("place_code", countries.get("code"));
				long node = createAndIndexNode(properties, keywordIndex);
				placeIndex.add( node, properties );
				long continentNode = placeIndex.get("placeCode", countries.get("continent")).getSingle();
				relateNodes(node, refNode, "IS");
				relateNodes(node, continentNode, "IS AT");

				placeIndex.flush();
			}

			countries.close();

		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	/**
	 * Creates nodes for the entity of the kind Continent.
	 * @param file which has all the information concerned to the continents.
	 */
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
				properties.put("placeCode", props[0]);
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

	/**
	 * Creates the reference nodes used to navigate thought the graph.
	 * @param file with the name of each kind of information, one per line.
	 */
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

	/**
	 * Creates nodes for the entity of the kind Airport.
	 */
	void createAirportNodes(){
		long refNode = typeIndex.get("type", "airport").getSingle();
		try {
			CsvReader airports = new CsvReader(BASE_AIRPORT_FILE);
			airports.readHeaders();

			while (airports.readRecord()){
				String iata = airports.get("iata_code");
				if ((iata != "") && (keywordIndex.get("iata", iata).getSingle() == null)){
					Map<String, Object> properties = createPOIProperties(iata,"", airports.get("name"),airports.get("id"));
					long node = createAndIndexNode(properties, keywordIndex);
					addPOIGeoDb(airports.get("longitude_deg"),airports.get("latitude_deg"), "airport" ,  node );
					long cityNode = getOrCreateCityNode(airports.get("municipality"), airports.get("iso_country"));
					relateNodes(refNode, node, "IS");
					relateNodes(node, cityNode, "IS AT");
					keywordIndex.flush();
				}

			}

			airports.close();

		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}


	/**
	 * Creates nodes for the entity of the kind Airline.
	 * @param file which has all the information concerned to the airlines.
	 */
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

	/**
	 * Create all the relationships between airline and airport of the kind
	 * "ACTS" that means that an airline operates on that airport.
	 * @param map that would have the airline:airport list information. 
	 */
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

	/**
	 * Extract from the schedules the information about in which airport
	 * each airline acts.
	 * @return A Map like <airline iata code, list of airport iata codes>
	 */
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

	/**
	 * Create a new entry in the Geo database.
	 * @param longitude 
	 * @param latitude
	 * @param kind the name of the "kind" entity in the graph database.
	 * @param node id of the entity in the graph database that has the related information.
	 */
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

	/**
	 * Tries to get a node of the type City by it's name. If note found, creates a new City.
	 * @param name of the city
	 * @param country that the City belongs to. It's only used if the city is not found.
	 * @return The found or created City node.
	 */
	private long getOrCreateCityNode(String name, String country) {
		Long node = placeIndex.get("name", name).getSingle();
		if(node == null){
			long refNode = typeIndex.get("type", "city").getSingle();
			Map<String,Object> properties = new HashMap<String,Object>();
			properties.put("name", name);
			node = createAndIndexNode(properties, keywordIndex);
			long countryNode = placeIndex.get("place_code", country).getSingle();
			relateNodes(node, refNode, "IS");
			relateNodes(node, countryNode, "IS AT");
		}

		return node;
	}

	/**
	 * Removes non alphanumeric digit.
	 * @param word String with the characters to be removed.
	 * @return The same string with only alphanumeric characters and spaces.
	 */
	private String removeSpecialCharacters(String word){
		return word.replaceAll("[^a-zA-Z 0-9]+"," ");
	}

	/**
	 * Take the information needed and make a properties Map for including on a node.
	 * @param iata
	 * @param icao
	 * @param name
	 * @param ourAirportId for further use, making possible the user edit this information online
	 * @return A Maps <key, information> for creating a node.
	 */
	private Map<String,Object> createPOIProperties(String iata, String icao, String name, String ourAirportId) {
		Map<String,Object> properties = new HashMap<String,Object>();

		properties.put( "name", name );
		properties.put( "our_airport_id", ourAirportId );
		properties.put( "iata", iata.toUpperCase() );
		properties.put( "icao", icao.toUpperCase() );

		return properties;
	}

	/**
	 * Take the information needed and make a properties Map for including on a node.
	 * @param props List of information that comes from a file.
	 * @return A Maps <key, information> for creating a node.
	 */
	private Map<String, Object> createAirlinesProperties(String[] props) {
		Map<String,Object> properties = new HashMap<String,Object>();

		properties.put( "name", props[2] );
		properties.put( "call_sign", props[4] );
		properties.put( "nationality", props[3] );
		properties.put( "iata", props[0].toUpperCase() );
		properties.put( "icao", props[1].toUpperCase() );

		return properties;
	}

	/**
	 * Create a relationship between the two given nodes.
	 * @param node1
	 * @param node2
	 * @param label the "type" or "name" of the relationship.
	 */
	private void relateNodes(long node1,long node2,String label){
		inserter.createRelationship( node1, node2, DynamicRelationshipType.withName( label ), null );
//		labelIndex.add(arg0, arg1)
	}

	/**
	 * Method that creates a node and index it.
	 * @param properties the fields of the new entity
	 * @param index the one that should be used to index the new entity
	 * @return the new node.
	 */
	private long createAndIndexNode(Map<String,Object> properties, BatchInserterIndex index){
		long node = inserter.createNode( properties );
		index.add( node, properties );

		return node;
	}

	/**
	 * Helper method to end the connection with the Index provider and the 
	 * Graph Database.
	 */
	void stopBatch(){
		indexProvider.shutdown();
		inserter.shutdown();
	}

}

