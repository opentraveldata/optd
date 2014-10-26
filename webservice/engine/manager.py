# -*- coding: utf-8 -*-
import sys, traceback
import httplib2
import json, psycopg2
from neo4jrestclient import constants
from neo4jrestclient.client import *
from neo4jrestclient.client import Node
from django.conf import settings
from urllib import urlencode

"""
Creates an object for the graph database with the default
path for it.
"""
gdb = GraphDatabase(settings.NEO4J_URL)

def keyword_search(q, fields, maximum):
    """
    Pré-build the request for make a query with the 
    keywords index, within all the fields given as
    parameters.
    """
    query = split_query_keywords(q.encode('utf-8'))
    if query:
        keys = []
        index = gdb.nodes.indexes.get("keywords")
        for key in query:
            keys.append(key + "*")
            
        return  make_custom_query(make_query(keys, fields), maximum)
    

def get_lng_lat(graphid):
    """
    Returns a dictionary with the latitude and longitude for
    the given node id. These informations are in the geodb.
    """
    try:
        conn = psycopg2.connect("dbname='geodb' user='postgres' host='localhost' password='geodb'");
        cursor = conn.cursor()
       
        sql = "SELECT st_X(Geometry(place)), st_Y(Geometry(place)) FROM poi where graphid= '"+ str(graphid) + "'"
       
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
    """
    For the given node id, return all the properties for that
    node in the graph database and in the geodb, if applicable.
    """
    longlat = get_lng_lat(id)
    results = gdb.node[id].properties
    if longlat:
        results.update(longlat)
    return results
    
    
def get_node_type(id):
    """
    From the node, find the relationship "IS" (it's
    supposed to have only one) and get's the node with
    the type. Return a string with the type's name.
    """
    node = gdb.node[id]
    is_rel = node.relationships.all(types=["IS"])[0]
    type_node = is_rel.start
    if 'type' not in type_node.properties.keys():
        type_node = is_rel.end
        
    rel_type = type_node.properties['type']
    return rel_type
    
    
def get_node_relationships(id):
    """
    For a given node1 id, returns all the nodes that
    have a direct relatioship with it (if the node2
    has more than one direct relationship, the node is 
    returned as many times as relationships) and the
    name of the relationship is added to the node2 
    properties.
    """
    results = []
    node = gdb.node[id]
#    nodes = node.traverse(order=[constants.BREADTH_FIRST])

    for rel in node.relationships.all():
        if rel.type != 'IS':
            nd = {}
            nd['link'] = rel.type
            if rel.end == node:
                nd['name'] = rel.start.properties['name']
                nd['id'] = rel.start.id
            else:
                nd['name'] = rel.end.properties['name']
                nd['id'] = rel.end.id 
                
            results.append(nd) 
    
    return results  
    
    
def get_relationship_kind(node1, node2):
    """
    Returns a string with the name of the 
    relationship between the two given nodes.
    """
    for rel in node1.relationships.all():
        if(rel.start == node2 or rel.end == node2):
            return rel.type
    

def make_query(keys, fields):
    """
    Builds a string for make a custom query with
    the given keys and fields (both lists).
    """
    query = ""
    for field in fields:
        for key in keys:
            query += field + ":" + key + " OR "
    return query[:-4]
    
def make_custom_query(query, maximum):
    """
    Using the CustomQuery plugin, executes the given query.
    """
    nodes = gdb.extensions.CustomQuery.makeQuery(query=query, max=maximum) 
    results = []        
    for node in nodes:
        node.properties['id'] = node.id
        results.append(node.properties)
     
    return results    
        
def get_pois_around(node_id, distance):
    """
    Makes a "within distance" query in the geodatabase
    that returns all the POIs inside the buffer of distance in metters.
    """
    try:
        conn = psycopg2.connect("dbname='geodb' user='postgres' host='localhost' password='geodb'");
        cursor = conn.cursor()
       
        sql = "SELECT DISTINCT p1.graphid FROM poi p1, poi p2 WHERE p2.graphid = '"+ str(node_id) 
        sql += "' AND p1.graphid <> p2.graphid AND ST_DWithin(p1.place, p2.place, "+ str(distance) +", false); "
        cursor.execute(sql)
        rows = cursor.fetchall()
       
        result = []
        for row in rows:
            result.append(gdb.node[int(row[0])])
        
        return result
        conn.close()
        
    except:
       print "I am unable to connect to the database"
       print traceback.format_exc()
                               
def split_query_keywords(query):
    """
    Splits the string in the spaces, but the ones 
    between quotation marks are kept together.
    """
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
