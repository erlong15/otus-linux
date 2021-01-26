#SITE_ROOT = "https://my-monitoring-project.com"
#SITE_NAME = "My Monitoring Project"
# DEFAULT_FROM_EMAIL = "noreply@my-monitoring-project.com"

# Uncomment to use Postgres:
DATABASES = {
     'default': {
         'ENGINE': 'django.db.backends.postgresql',
         'NAME': 'otus',
         'USER': 'django',
         'PASSWORD': 'pass123pass',
         'HOST': 'db1',
         'TEST': {'CHARSET': 'UTF8'}
     }
 }

# Uncomment to use MySQL:
# DATABASES = {
#     'default': {
#         'ENGINE': 'django.db.backends.mysql',
#         'NAME': 'your-database-name-here',
#         'USER': 'your-database-user-here',
#         'PASSWORD': 'your-database-password-here',
#         'TEST': {'CHARSET': 'UTF8'}
#     }
# }

# Email
# EMAIL_HOST = "your-smtp-server-here.com"
# EMAIL_PORT = 587
# EMAIL_HOST_USER = "username"
# EMAIL_HOST_PASSWORD = "password"
# EMAIL_USE_TLS = True