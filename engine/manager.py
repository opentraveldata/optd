import sys, traceback
import httplib2
import json, psycopg2
from neo4jrestclient import constants
from neo4jrestclient.client import *
from neo4jrestclient.client import Node
from django.conf import settings
from urllib import urlencode

gdb = GraphDatabase(settings.NEO4J_URL)

def keyword_search(q):
    query = split_query_keywords(q.encode('utf-8'))
    if query:
        keys = []
        index = gdb.nodes.indexes.get("keywords")
        for key in query:
            keys.append(key + "*")
            
        return  make_custom_query(make_query(keys, settings.FULLTEXT_FIELDS))

        
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
       
        sql = "SELECT st_X(place), st_Y(place) FROM poi where graphid= '"+ str(graphid) + "'"
       
        cursor.execute(sql)
        rows = cursor.fetchall()
       
        result = {}
        if rows:
            result['latitude'] = rows[0][1]
            result['longitude'] = rows[0][0]
       
        return result
        conn.close()
    except:
       print "I am unable to connect to the database"
       print traceback.format_exc()
       

def get_node_properties(id):
    longlat = get_lng_lat(id)
    results = gdb.node[id].properties
    if longlat:
        results['longitude'] = longlat['longitude']
        results['latitude'] = longlat['latitude']
    return results
    
    
def get_node_type(id):
    node = gdb.node[id]
    type_node = node.relationships.all(types=["IS"])[0].start
    if 'type' not in type_node.properties.keys():
        type_node = node.relationships.all(types=["IS"])[0].end
        
    rel_type = type_node.properties['type']
    return rel_type
    
    
def get_node_relationships(id):
    results = []
    node = gdb.node[id]
#    nodes = node.traverse(order=[constants.BREADTH_FIRST])
    
    for rel in node.relationships.incoming():
        if rel.type != 'IS':
            nd = {}
            nd['name'] = rel.start.properties['name']
            nd['id'] = rel.start.id
            nd['link'] = rel.type
            results.append(nd)    
             
    for rel in node.relationships.outgoing():
        if rel.type != 'IS':
            nd = {}
            nd['name'] = rel.end.properties['name']
            nd['id'] = rel.end.id
            nd['link'] = rel.type
            results.append(nd)          
    
#    for rel in node.relationships.all():
#        for n in nodes:
#            if (rel.end == n or rel.start == n) and rel.type != 'IS':
#                nd = {}
#                nd['name'] = n.properties['name']
#                nd['id'] = n.id
#                nd['link'] = rel.type
#                results.append(nd)
        
    return results  
    
    
def get_relationship_kind(node1, node2):
    for rel in node1.relationships.all():
        if(rel.start == node2 or rel.end == node2):
            return rel.type
    

def make_query(keys, fields):
    query = ""
    for field in fields:
        for key in keys:
            query += field + ":" + key + " OR "
    
    return query[:-4]
    
def make_custom_query(query):
    
    nodes = gdb.extensions.CustomQuery.makeQuery(query=query, max=settings.MAX_RESULTS) 
    results = []        
    for node in nodes:
        node.properties['id'] = node.id
        results.append(node.properties)
        
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
