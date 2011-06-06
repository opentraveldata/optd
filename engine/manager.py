import sys, traceback
import httplib2
import json, psycopg2
from neo4jrestclient import *
from neo4jrestclient.client import Node
from django.conf import settings
from urllib import urlencode

gdb = GraphDatabase(settings.NEO4J_URL)

def keyword_search(q):
    query = split_query_keywords(q.encode('utf-8'))
    if query:
        results = []
        index = gdb.nodes.indexes.get("keywords")
        keys = ""
        for key in query:
            keys += "*" + key + "* "
            
        final_query = keys + "OR description:" + keys
        
        for result in index.query("name", final_query):
            result.properties['id'] = result.id
            results.append(result.properties)
                
        return results[:settings.MAX_RESULTS]
        
#def code_search(q):
#    query = split_query_keywords(q.encode('utf-8'))
#    if query:
#        results = []
#        index = gdb.nodes.indexes.get("keywords")
#            
#        final_query = query + "OR icao:" + query
#        
#        for result in index.query("iata", final_query):
#            results.append(result.properties)
#                
#        return results        
            

def code_search(code_list, query):
    keys = split_query_keywords(query.upper())
    results = []
    h = httplib2.Http()
    url = "http://localhost:7474/db/data/ext/GremlinPlugin/graphdb/execute_script"
    headers = {'Content-Type':'application/x-www-form-urlencoded'}

    ref_nodes = gdb.nodes.indexes.get("types").query("type", "*")
    
    for key in keys:
        for ref in ref_nodes:
            for code in code_list:
                data = dict(script="g.v("+ str(ref.id)+ ").bothE('IS').outV{it."+code +"=='"+key+"'}")
                resp, content = h.request(url,"POST",headers=headers, body= urlencode(data))
                result = json.loads(content)
                print result
                if result:
                    for r in result:
                        node = Node(r["self"])
                        node.properties['id'] = r.id
                        results.append(node.properties)
    
    return results[:settings.MAX_RESULTS]
    
    

def get_lng_lat(graphid):
    try:
       conn = psycopg2.connect("dbname='geodb' user='postgres' host='localhost' password='geodb'");
       cursor = conn.cursor()
       
       sql = "SELECT st_X(place), st_Y(place) FROM poi where graphid= '"+ graphid + "'"
       
       cursor.execute(sql)
       rows = cursor.fetchall()
       
       result = {}
       result['longitude'] = rows[0][1]
       result['latitude'] = rows[0][0]
       
       return result
       conn.close()
    except:
       print "I am unable to connect to the database"
       print traceback.format_exc()
       

def get_node_properties(id):
    return gdb.node[id].properties
    
def get_node_relationships(id):
    results = []
    node = gdb.node[id]
    nodes = node.traverse(order=[constants.BREADTH_FIRST])
    for n in nodes:
        try:
            nd = {}
            nd['name'] = n.properties['name']
            nd['id'] = n.id
            results.append(nd)
        except:
            pass
           
        
    return results            
                               
def split_query_keywords(query):
    keywords = []
    # Deal with quoted keywords
    while '"' in query:
        first_quote = query.find('"')
        second_quote = query.find('"', first_quote + 1)
        quoted_keywords = query[first_quote:second_quote + 1]
        keywords.append(quoted_keywords.strip('"'))
        query = query.replace(quoted_keywords, ' ')
    # Split the rest by spaces
    keywords.extend(query.split())
    return keywords
