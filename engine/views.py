# -*- coding: utf-8 -*-
from django.http import HttpResponse
from django.shortcuts import render_to_response
from django.template.context import RequestContext
from django.core.mail import *
import sys, traceback, json 
from neo4jrestclient import *
from django.conf import settings
from engine import manager

def handler(request):
    """
    Handler for requests other than the ones
    for the GUI. Supports the "key" search and 
    the "code" search. It expects a GET request
    and a json with a query and type fields.
    """
    if request.method == 'GET':
        results = [] 
        params = json.loads(request.raw_post_data)
        if params["type"] == 'code':
            results = manager.keyword_search(params["query"], settings.CODES_FIELDS)
        if params["type"] == 'key':
            results = manager.keyword_search(params["query"], settings.FULLTEXT_FIELDS)
            
        return HttpResponse(json.dumps(results))            
    else: 
       return HttpResponseBadRequest("You should send a json via a GET request.")   

        
def web_handler(request):
    """
    """
    if request.is_ajax():
        query = request.GET.get( 'q' )
        if query is not None:
            results = manager.keyword_search(query, settings.FULLTEXT_FIELDS)
            
            return HttpResponse(json.dumps(results),mimetype='application/json')
            
    else:
        template = 'engine/search.html'
        return render_to_response( template, {}, 
                               context_instance = RequestContext( request ) )  
                               
                               
                               
def node_search (request, node=0):
    """
    Responsable to get all the information shown in the
    single node page and send it to a django template.
    """
    template = 'engine/node.html'
    node_info = manager.get_node_properties(int(node))
    node_links = manager.get_node_relationships(int(node))
    node_type = manager.get_node_type(int(node))
    resp = {'node_info': node_info, 'node_links': node_links, 'node_type': node_type}
    return render_to_response( template, resp, 
                               context_instance = RequestContext( request ) )
                               
   

def send_email(request):
    """
    Sends an e-mail for the Administator (django settings)
    with the text sent in the request.
    """
    if request.is_ajax():
        mail = request.GET.get( 'text' )
        if mail is not None:
            mail_admins('Erros', mail)
            return HttpResponse(status=200) 
    
    


    
