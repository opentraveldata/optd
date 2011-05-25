from django.conf.urls.defaults import *
from engine.views import *

urlpatterns = patterns( '',
#    url( r'^search$', search ),
    url( r'^search$', handler ),
#    url( r'^rsearch$', rule_search ),
    url( r'^get_airlines$', get_airlines ),
)
