from django.db import models

class Thing(models.Model):
    name = models.CharField(max_length=100)
    coolness = models.IntegerField() # Positif = cool, negatif = uncool

    def __unicode__(self):
        return u"<Thing: %s / %d>" % (self.name, self.coolness)
