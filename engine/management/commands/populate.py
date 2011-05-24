from django.core.management.base import BaseCommand, CommandError, NoArgsCommand
from django.conf import settings
import json, psycopg2, traceback
import MySQLdb, contextlib, urllib2
from collections import defaultdict
from neo4jrestclient import *


gdb = GraphDatabase(settings.NEO4J_URL)

class Command(NoArgsCommand):

    def handle_noargs(self, **options):
        start_graphdb(settings.BASE_REF_NODE)


def start_graphdb(theFile):
    try:
        file=open(theFile);
        for line in file.readlines():
            add_new_refnode(line.split("\n")[0].lower())
    except:
        print traceback.format_exc()
    
    add_airport_nodes(get_node_from_index("types", "type", "airport"))
    add_airlines_nodes(settings.BASE_AIRLINE_FILE, get_node_from_index("types", "type", "airline"))
 
def get_airport_airline_list():
    try:
        file=open(settings.BASE_AIRPORT_AIRLINE);
        return json.loads(file.read())
    except:
        print traceback.format_exc()    

def add_airport_nodes(ref_node):
    db= MySQLdb.connect(host="nceoridb01.nce.amadeus.net", user="sim", passwd="pods3030", db="geography",use_unicode=True)
    cursor = db.cursor()

    sql = "SELECT * FROM icao"
    try:
        cursor.execute(sql)
        results = cursor.fetchall()
        for row in results:
            make_new_poi(row, ref_node)
    except:
        print "pifou !"
        print traceback.format_exc()
 
    db.close()
    

def make_new_poi(row,ref_node):
            
    node = gdb.nodes.create(
        name= row[3],
        iata = row[0].upper(),
        icao = row[1].upper()
        )
    add_point_geodb(row[2], row[4], row[5], row[6], ref_node.properties['type'], node.url)
            
    #index poi's properties.
    index_properties(node)
            
    #add relatioship with it's reference node.
    relate_with_node(node, ref_node, "IS")
            
    return node
            
       
def add_point_geodb(city, country, longitude, latitude, kind, graphid):
   try:
       conn = psycopg2.connect("dbname='geodb' user='postgres' host='localhost' password='geodb'");
       cursor = conn.cursor()
       
       sql = "INSERT INTO poi (graphid, city, country, type, place) "
       sql += "VALUES ('"+replace_special_characters(graphid) + "',"
       sql += "'" + replace_special_characters(city) +"','"+replace_special_characters(country) +"',"
       sql += "'" + kind +"',"
       sql += "ST_GeomFromText('SRID=32661;POINT("+str(longitude)+" "+ str(latitude)+")') );"
       
       cursor.execute(sql)
#       rows = cursor.fetchall()
       conn.commit()
       conn.close()
   except:
       print "I am unable to connect to the database"
       print traceback.format_exc()

def find_code_name(list, code):
    name = ""
    for alternatives in list:
        if code in alternatives.values():
            name = alternatives['name']
            break
    return name


def relate_with_node(ref_node, node, type):
    ref_node.relationships.create(type, node)
    
    
def add_new_refnode(name):
    node = gdb.node(type=name)
    index_node("types", "type", name, node)


def index_properties(node):
    for key in node.properties:
        if node.properties[key]:
            if key in settings.BASE_CODES:
                index_node("codes", key, replace_special_characters_url(node.properties[key]), node)
            else:
                index_node("keywords", key,replace_special_characters_url(node.properties[key]), node)  
            
 

def replace_special_characters(data):
    return data.replace("'", "")
 
def replace_special_characters_url(data):
    return data.replace(" ", "%20").replace('/', "%2F").replace("\\", "%5C").encode('utf-8')
    
def index_node(ind, key, value, node):

    index = None
    try:
        index = gdb.nodes.indexes.get(ind)
    except NotFoundError:
        index = gdb.nodes.indexes.create(ind, type="fulltext", provider="lucene")
        
    index.add(key, value, node)

    
def create_airline_node(data):
    l=data.split('^')

    node = gdb.node(
        name = l[2],
        call_sign = l[4],
        iata = l[0].upper(),
        icao = l[1].upper(),
        nationality = l[3])

    return node
    

def get_node_from_index(index, key, value):
    index = gdb.nodes.indexes.get(index)
    result = index[key][value]
    if result:
        return result[0]
    return result



def add_airport_airline_relationship():
    db= MySQLdb.connect(host="nceoridb01.nce.amadeus.net", user="sim", passwd="pods3030", db="geography",use_unicode=True)

    sql = "SELECT DISTINCT destination, airline FROM `schedules`"
    try:
        
        db.query(sql)
        results = db.store_result()
        
        dicti = defaultdict(list)
        
        while True:
            row = results.fetch_row()
            if row: 
                dicti[row[0][1]].append(row[0][0])
            else:
                break    
            
        
        for key in dicti.keys():
            airline = get_node_from_index("codes", "iata", key)
            if airline:
                for airp in dicti[key]:
                    airport = get_node_from_index("codes", "iata", airp)
                    if airport:
                        relate_with_node(airline, airport, "ACTS")
            
    except:
        print "add_airport_airline_relationship"
        print traceback.format_exc()
 
    db.close()



def add_airlines_nodes(theFile, ref_node):
    #create nodes
    try:
        file=open(theFile);
        for line in file.readlines():
            node = create_airline_node(line)
            
            #index properties
            index_properties(node)
            
            #relate with ref_node
            relate_with_node(ref_node, node, "IS")
            
        #relate with the airports
        add_airport_airline_relationship()
            
    except:
        print "erro em airline" 
        print traceback.format_exc()
    
   
    
    
