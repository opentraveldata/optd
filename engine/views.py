# -*- coding: utf-8 -*-
from django.http import HttpResponse
from django.http import HttpResponseServerError
from django.shortcuts import render_to_response
from django.template.context import RequestContext
from django.core.mail import *
import sys, traceback, json 
from neo4jrestclient import *
from django.conf import settings
from TSE.engine import manager
import logging

# Get an instance of a logger
logger = logging.getLogger(__name__)

def handler(request):
    """
    Handler for requests other than the ones
    for the GUI. Supports the "key" search and 
    the "code" search. It expects a GET request
    and a json with a query and type fields.
    """
    if request.method == 'GET':
        results = [] 
        try:
            params = json.loads(request.raw_post_data)
        except:
           logger.error("Malformed json") 
           return HttpResponseServerError()
        try:   
            if params["type"] == 'code':
                results = manager.keyword_search(params["query"], settings.CODES_FIELDS, params["max"])
            if params["type"] == 'key':
                results = manager.keyword_search(params["query"], settings.FULLTEXT_FIELDS, params["max"])
        except:
           logger.error("Wrong fields. Should be: 'query', 'type' and 'max'.") 
           return HttpResponseServerError() 
            
        return HttpResponse(json.dumps(results))            
    else: 
       logger.warning("Not a GET request.") 
       return HttpResponseBadRequest("You should send a json via a GET request. The following params are required: type, query, max")   

        
def web_handler(request):
    """
    Handler for ajax requests for the view.
    If it's not an ajax request, it renders the
    main page.
    """
    if request.is_ajax():
        logger.info("Ajax request made.")
        query = request.GET.get( 'q' )
        if query is not None:
            try:
                results = manager.keyword_search(query, settings.FULLTEXT_FIELDS, settings.MAX_RESULTS)
                logger.info("Information retrieved")
            except:
                logger.error("Couldn't make the query.")
                return HttpResponseServerError()
                
            return HttpResponse(json.dumps(results),mimetype='application/json')
        else:
            logger.warning("Null query.")    
            
    else:
        logger.info("No ajax request made.")
        template = 'engine/search.html'
        return render_to_response( template, {}, 
                               context_instance = RequestContext( request ) )  
                               
                               
                               
def node_search (request, node=0):
    """
    Responsable to get all the information shown in the
    single node page and send it to a django template.
    """
    template = 'engine/node.html'
    try:
        node_info = manager.get_node_properties(int(node))
        node_links = manager.get_node_relationships(int(node))
        node_type = manager.get_node_type(int(node))
    except:
        logger.error("Coudn't retrieve the node's information")
        return HttpResponseServerError()
        
    logger.info("Node's information retrieved successfully")    
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
            logger.info("E-mail sent.")
            return HttpResponse(status=200)
        else:
            logger.error("You can't send an empty mail.")    
    else:
        logger.warning("It only accepts ajax requests.")         
    
    


    
