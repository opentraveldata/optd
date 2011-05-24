from django.http import HttpResponse
from django.shortcuts import render_to_response
from django.template.context import RequestContext
import sys, traceback
import httplib
import ast
import json, psycopg2
from neo4jrestclient import *
from django.conf import settings

gdb = GraphDatabase(settings.NEO4J_URL)

def handler ( request ):
    httpServ = httplib.HTTPConnection("127.0.0.1", 7474)
    httpServ.connect()

    if request.method == 'GET':
        httpServ.request('GET', "/db/data/node/1/")
        response = httpServ.getresponse()
    
        if response.status == httplib.OK:
            results= json.loads(response.read())
        httpServ.close()
        return HttpResponse(json.loads(results))
        
    if request.method == 'POST':
       return
        
    if request.is_ajax():
        query = request.GET.get( 'q' )
        return
    
    httpServ.close()    
    template = 'engine/search.html'
    return render_to_response( template, {}, 
                               context_instance = RequestContext( request ) )
                               
   

def search( request ):
    if request.is_ajax():
        query = request.GET.get( 'q' )
        if query is not None:
            keys = split_query_into_keywords(query)
            results = code_Search(keys)
#            if not results:
#                results = makeNameSearch(keys)
            data = json.dumps(results)
#            data = serializers.serialize('json', results)
            return HttpResponse(data,mimetype='application/json')
            
    else:
        template = 'engine/search.html'
        return render_to_response( template, {}, 
                               context_instance = RequestContext( request ) )


def keyword_search(request):
    if request.is_ajax():
        query = split_query_into_keywords(request.GET.get( 'q' ).encode('utf-8'))
        if query:
            results = []
            index = gdb.nodes.indexes.get("keywords")
            q = ""
            for x in query:
                q += "*" + x + "* "
            for result in index.query("name", q):
                results.append(result.properties)
            for result in index.query("description", q):
                results.append(result.properties)
            data = json.dumps(results)
            return HttpResponse(data,mimetype='application/json')
            
    else:
        template = 'engine/search.html'
        return render_to_response( template, {}, 
                               context_instance = RequestContext( request ) )


def code_Search(keys):
    index = gdb.nodes.indexes.get("codes")
    results = []
    for key in keys:
        iata = index['iata'][key]
        icao = index['icao'][key]
        if iata:
            node = iata[0]
        else:
            node = icao[0]
        
        result = get_lng_lat(node.url)
        result.update(node.properties)
        result['id'] = node.id
        results.append(result)
        
    return results

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
 
def get_airlines(request):
    data = None
    query = request.GET.get( 'id' )
    if query is not None:
        result = []
        node = gdb.nodes[query]
        rels =  node.relationships.incoming(["ACTS"])
        for rel in rels:
            result.append(rel.start.properties)
        data = json.dumps(result)
        
    return HttpResponse(data,mimetype='application/json')
     
                               
def split_query_into_keywords(query):
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

    
