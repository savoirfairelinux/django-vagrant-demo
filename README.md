Django-Vagrant demo
===

This is an example Django projet integrated with Vagrant for an easy local deployment. This
is a simple Django project to demonstrates how easy it is to run, from nothing, a new projet when it
is properly integrated with Vagrant.

Running the project
---

To run the project, you need only 4 things:

1. Git ( http://git-scm.com/ )
2. VirtualBox ( https://www.virtualbox.org/ )
3. Vagrant ( http://www.vagrantup.com/ )
4. Fabric ( http://docs.fabfile.org/ )

Once you have all of this, all you need to do to run the project from nothing is:

    $ git clone https://github.com/savoirfairelinux/django-vagrant-demo
    $ cd django-vagrant-demo/deploy
    $ fab deploy

Then, you can open http://demo-django.local:8080 and visit your newly locally deployed django site!

At one point, your `sudo` password will be asked, that's Vagrant that needs to modify your
`/etc/hosts` file. The project itself will also need to modify that file so that `demo-django.local`
points to `127.0.0.1`, a task which also requires admin privileges.

There's a `fab debugserver` you can use, after your `fab deploy` to start Django's built-in
server from within the Vagrant VM (it makes debugging easier).

When you're finished toying with the project, go into the `vagrant` folder and run `vagrant destroy`
to remove the VM that was automatically created.

Separation of concerns
---

If you take a look at the way to project is organized, you'll notice that Fabric and Puppet (the
scripting language used by Vagrant to provision the VM) share a bit of the same responsibility, that
is to setup an environment for the project to run in.

Depending on the project and school of thought, the responsibilities you want to respectively give
to each tool may vary. At SFL, at least for Django projects, we choose to give
everything-but-python-stuff to Puppet, and the rest, of course, to Fabric.

This means that Fabric tasks assume that once provisioned, it will deploy in an Ubuntu 12.04
environment with all `apt-get` packages properly installed, Apache's virtualenv (configured with
WSGI) correctly pointing to our yet-to-deploy project, and our databases correctly created (in this
example, we use SQLite for simplicity, but in our project, we give the responsibility of setting
up the DB to Puppet).

That being said, your mileage may vary.

About that Puppet code
---

The Puppet code used here is a small subset of our own internal Puppet library. This library is
being written and used by sysadmins here and has a lot of ... battle scars. This is only a showcase
for Vagrant's potential and if you want to bring that awesomeness into your own projects, you might
want to use a more elegant library, such as the ones developed by PuppetLabs at
https://github.com/puppetlabs
