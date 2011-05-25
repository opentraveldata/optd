from django.core.management.base import BaseCommand, CommandError, NoArgsCommand
from django.conf import settings
import json, psycopg2, traceback
import MySQLdb, contextlib, urllib2
from collections import defaultdict
from neo4jrestclient import *


gdb = GraphDatabase(settings.NEO4J_URL)

class Command(NoArgsCommand):

    def handle_noargs(self, **options):
        add_description()

def add_description():
    index = gdb.nodes.indexes.create("description", type="fulltext", provider="lucene")
#    airports = get_node_from_index("types", "type", "airport")

    add_new_refnode("hotel")
    
    try:
        file=open("/home/milena/workspace/TSE/geonames-dump/hotel-test.txt");
        name = file.readline().strip("\n")
        en = file.readline().strip("\n")
        pt = file.readline().strip("\n") 
        fr = file.readline().strip("\n")
        
        
        node = gdb.node(name=name, description=en, description_pt=pt, description_fr=fr)
        
        index_node("keywords", "name", name, node)
        index_node("keywords", "description", en, node)
        index_node("keywords", "description", pt, node)
        index_node("keywords", "description", fr, node)
        
        relate_with_node(get_node_from_index("types", "type", "hotel"), node, "IS")
        
    except:   
        print traceback.format_exc() 
    
    
def relate_with_node(ref_node, node, type):
    ref_node.relationships.create(type, node)    
    
    
def add_new_refnode(name):
    node = gdb.node(type=name)
    index_node("types", "type", name, node)
    
    
def index_node(ind, key, value, node):

    index = None
    try:
        index = gdb.nodes.indexes.get(ind)
    except NotFoundError:
        index = gdb.nodes.indexes.create(ind, type="fulltext", provider="lucene")
        
    index.add(key, value, node)
    
    
    
def get_node_from_index(index, key, value):
    index = gdb.nodes.indexes.get(index)
    result = index[key][value]
    if result:
        return result[0]
    return result
    
