from django.conf.urls.defaults import *
from django.views.generic.simple import direct_to_template
from django.contrib.auth.views import login, logout_then_login
from django.conf import settings

"""
Redirects each url to it's respective view's urls file
or to file/path.
"""
urlpatterns = patterns('',
    (r'^engine', include('engine.urls')),
    (r'^TSE/media/(?P<path>.*)$', 'django.views.static.serve', { 'document_root': settings.MEDIA_ROOT }),
)

