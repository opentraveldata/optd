from django.http import HttpResponse
from django.shortcuts import render_to_response
from django.template.context import RequestContext
import sys, traceback, json 
from neo4jrestclient import *
from django.conf import settings
from engine import manager

def test (request):
    if request.method == 'GET':
        print request.META['QUERY_STRING']
#        results = manager.code_search(settings.BASE_CODES, search[1])
        gdb = GraphDatabase(settings.NEO4J_URL)
        results= gdb.node[14].properties
        return HttpResponse(json.dumps(results))


def handler(request, type="", q=""):
    if request.method == 'GET':
        results = [] 
        
        if type == 'code':
            results = manager.code_search(code_list, q)
        if type == 'key':
            results = manager.keyword_search(q)
            
        return HttpResponse(json.dumps(results))            
    else: 
       print request.method + "," +  request.META['QUERY_STRING']

        
def code_search(request):
    if request.method == 'GET':
        code_list = request.GET.get( 'codes' )
        query = request.GET.get( 'q' )
        if code_list:
            code_list= manager.split_keywords(query)
        else:
            code_list = settings.BASE_CODES    
        
        results = manager.code_search(code_list, query) 
        return HttpResponse(json.dumps(results))
                               
                               
def web_handler(request):
    if request.is_ajax():
        query = request.GET.get( 'q' )
        if query is not None:
            results = []
            search = query.split(':')
            if len(search) > 1:
                if search[0] == 'key':
                    results = manager.keyword_search(search[1])
                    
                if search[0] == 'code':
                    results = manager.code_search(settings.BASE_CODES, search[1])
            
            return HttpResponse(json.dumps(results),mimetype='application/json')
            
    else:
        template = 'engine/search.html'
        return render_to_response( template, {}, 
                               context_instance = RequestContext( request ) )  
                               
                               
                               
def node_search (request, node=0):
    template = 'engine/node.html'
    node_info = manager.get_node_properties(int(node))
    node_links = manager.get_node_relationships(int(node))
    node_type = manager.get_node_type(int(node))
    resp = {'node_info': node_info, 'node_links': node_links, 'node_type': node_type}
    return render_to_response( template, resp, 
                               context_instance = RequestContext( request ) )
                               
   

 


    
