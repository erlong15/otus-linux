SITE_ROOT = "https://hc.otus.iudanet.com"
SITE_NAME = "My Otus Monitoring Project"
DEFAULT_FROM_EMAIL = "otus@iudanet.com"
# DEBUG = False

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
EMAIL_HOST = "smtp.gmail.com"
EMAIL_PORT = 587
EMAIL_HOST_USER = "otus@iudanet.com"
EMAIL_HOST_PASSWORD = "pass123pass"
EMAIL_USE_TLS = True