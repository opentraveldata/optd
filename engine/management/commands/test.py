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
#    index = gdb.nodes.indexes.create("description", type="fulltext", provider="lucene")
#    airports = get_node_from_index("types", "type", "airport")
    
