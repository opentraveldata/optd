from django.conf.urls.defaults import *
from engine.views import *

urlpatterns = patterns( '',
    url( r'^[/]?$', web_handler ),
    url( r'^/handler/(?P<type>\w+)/(?P<q>\w+)$', handler ),
    url( r'^/code_search$', code_search ),
#    url( r'^rsearch$', rule_search ),
#    url( r'^get_airlines$', get_airlines ),
)
