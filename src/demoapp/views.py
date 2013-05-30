from django.shortcuts import render_to_response

from .models import Thing

def things_view(request, things, positive, viewname):
    return render_to_response('index.html', {'things': things, 'viewname': viewname})

def pluscool(request):
    things = Thing.objects.filter(coolness__gt=0).order_by('-coolness').all()
    return things_view(request, things, True, 'pluscool')

def moinscool(request):
    things = Thing.objects.filter(coolness__lte=0).order_by('coolness').all()
    return things_view(request, things, False, 'moinscool')
