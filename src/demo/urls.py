from django.conf.urls import patterns, include, url
from django.views.generic.base import TemplateView

from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('demoapp.views',
    url(r'^$', 'pluscool', name='home'),
    url(r'^pluscool/$', 'pluscool', name='pluscool'),
    url(r'^moinscool/$', 'moinscool', name='moinscool'),
)

urlpatterns += patterns('',
    url(r'^admin/', include(admin.site.urls)),
)
