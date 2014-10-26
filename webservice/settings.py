# Django settings for TSE project.

import os
APP_DIR = os.path.dirname( globals()[ '__file__' ] )
DEBUG = True
TEMPLATE_DEBUG = DEBUG

ADMINS = (
     ('Milena Araujo', 'milena@localhost'),
)

MANAGERS = ADMINS

#Informations for sending an e-mail via the postfix server.
EMAIL_SUBJECT_PREFIX = "[TSE]"
EMAIL_HOST = 'virtual'
EMAIL_PORT = '25'
SERVER_EMAIL = 'root@localhost'

#Informations for the index search.
MAX_RESULTS = 20
CODES_FIELDS = ['iata','icao','city_code','country_code','continent_code']
FULLTEXT_FIELDS = ['name','description','iata','icao','place_code']

#Data to connect to the graph database
NEO4J_URL = 'http://localhost:7474/db/data/'
NEO4J_ADD_NODE = NEO4J_URL + 'node'
NEO4J_INDEX_NODE = NEO4J_URL + 'index/node/'


# Local time zone for this installation. Choices can be found here:
# http://en.wikipedia.org/wiki/List_of_tz_zones_by_name
# although not all choices may be available on all operating systems.
# On Unix systems, a value of None will cause Django to use the same
# timezone as the operating system.
# If running in a Windows environment this must be set to the same as your
# system time zone.
TIME_ZONE = 'America/Chicago'

# Language code for this installation. All choices can be found here:
# http://www.i18nguy.com/unicode/language-identifiers.html
LANGUAGE_CODE = 'en-us'

SITE_ID = 1

# If you set this to False, Django will make some optimizations so as not
# to load the internationalization machinery.
USE_I18N = True

# If you set this to False, Django will not format dates, numbers and
# calendars according to the current locale
USE_L10N = True

# Absolute path to the directory static files should be collected to.
# Don't put anything in this directory yourself; store your static files
# in apps' "static/" subdirectories and in STATICFILES_DIRS.
# Example: "/home/media/media.lawrence.com/static/"
STATIC_ROOT = 'media/'
MEDIA_ROOT = '/home/milena/workspace/TSE/media/'
MEDIA_URL = 'http://localhost:8000/TSE/media/'

# URL prefix for static files.
# Example: "http://media.lawrence.com/static/"
STATIC_URL = '/static/'

# Additional locations of static files
STATICFILES_DIRS = (
    # Put strings here, like "/home/html/static" or "C:/www/django/static".
    # Always use forward slashes, even on Windows.
    # Don't forget to use absolute paths, not relative paths.
    os.path.join( APP_DIR, '/media' )
)

# URL prefix for admin static files -- CSS, JavaScript and images.
# Make sure to use a trailing slash.
# Examples: "http://foo.com/static/admin/", "/static/admin/".
ADMIN_MEDIA_PREFIX = '/static/admin/'


# List of finder classes that know how to find static files in
# various locations.
STATICFILES_FINDERS = (
    'django.contrib.staticfiles.finders.FileSystemFinder',
    'django.contrib.staticfiles.finders.AppDirectoriesFinder',
)

# Make this unique, and don't share it with anybody.
SECRET_KEY = 'x12x+_fev%q_bfivycb-em9b5j0jtrl^=z@&)f#i7=c9t25oyh'

# List of callables that know how to import templates from various sources.
TEMPLATE_LOADERS = (
    'django.template.loaders.filesystem.Loader',
    'django.template.loaders.app_directories.Loader',
)

MIDDLEWARE_CLASSES = (
    'django.middleware.common.CommonMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
)


ROOT_URLCONF = 'TSE.urls'

# Put strings here, like "/home/html/django_templates" or "C:/www/django/templates".
# Always use forward slashes, even on Windows.
# Don't forget to use absolute paths, not relative paths.
TEMPLATE_DIRS = (
    os.path.join( APP_DIR, 'templates' ),
    
)

INSTALLED_APPS = (
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.sites',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'engine',
)

# A sample logging configuration. The only tangible logging
# performed by this configuration is to send an email to
# the site admins on every HTTP 500 error.
# See http://docs.djangoproject.com/en/dev/topics/logging for
# more details on how to customize your logging configuration.
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '%(levelname)s %(asctime)s %(module)s %(process)d %(thread)d %(message)s'
        },
        'simple': {
            'format': '%(levelname)s %(message)s'
        },
    },
    'handlers': {
        'null': {
            'level':'DEBUG',
            'class':'django.utils.log.NullHandler',
        },
        'console':{
            'level':'DEBUG',
            'class':'logging.StreamHandler',
            'formatter': 'verbose',
            'stream'  : 'ext://sys.stdout',
            
        },
        'file':{
            'class' : 'logging.handlers.RotatingFileHandler',
            'filename': 'logconfig.log',
            'formatter': 'verbose',
            'maxBytes' : '1024',
            'backupCount': '3'
        }
    },
    'loggers': {
        'engine.views':{
            'handlers' : ['file'],
            'level': 'ERROR',
        },
        'django.request': {
            'handlers': ['console'],
            'level': 'ERROR',
            'propagate': True,
        },
    }
}
