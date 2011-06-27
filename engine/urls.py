from django.conf.urls.defaults import *
from engine.views import *

"""
Redirects each url to it's respective function in the view.
"""
urlpatterns = patterns( '',
    url( r'^[/]?$', web_handler ),
    url( r'^/node/(?P<node>\d+)$', node_search ),
    url( r'^/handler/(?P<type>\w+)/(?P<q>\w+)$', handler ),
    url( r'^/send_email$', send_email ),
    url( r'^/code_search$', code_search ),
)
