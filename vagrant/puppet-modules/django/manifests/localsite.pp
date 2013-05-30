#
define django::localsite (
  $sitename,
  $projectroot = "/opt/${sitename}",
  $siteroot = "/opt/${sitename}/www",
  $vhostname = "${sitename}.local",
  $localport = "8080",
  $siteurl = "http://${sitename}.local:${localport}/",
  $djangodebug = "True",
  $sourcefolder = "src",
  $settingsmodule = "${sitename}.settings",
)
{
  $sourceroot = "${siteroot}/${sourcefolder}"
  $dbname = "$siteroot/demo-django.db"

  exec { "apt-update":
    command => "/usr/bin/apt-get update"
  }

  Exec["apt-update"] -> Package <| |>

  package {
    "build-essential": ensure => installed;
    "python": ensure => installed;
    "python-dev": ensure => installed;
    "python-setuptools": ensure => installed;
    "python-pip": ensure => installed;
    "python-virtualenv": ensure => installed;
    "git": ensure => installed;
  }

  include concat::setup

  file { 'opt':
    path => '/opt',
    mode  => 0775,
    ensure => directory,
    owner => "www-data",
    group => "www-data",
  }

  file { 'projectroot':
    path => $projectroot,
    require => File['opt'],
    mode  => 0775,
    ensure => directory,
    owner => "www-data",
    group => "www-data",
  }

  file { 'siteroot':
    path => $siteroot,
    require => File['projectroot'],
    ensure => 'link',
    target => '/project_share',
  }

  class { 'comanche::variables': htttpdwwwdir => "/opt"}
  class { 'comanche': }
  comanche::module { 'wsgi': }

  file { "${projectroot}/${sitename}.wsgi":
    require => File['projectroot'],
    mode  => 0664,
    owner => "www-data",
    group => "www-data",
    content => template("django/wsgi.erb"),
  }

  comanche::virtualhost { "${sitename}": vhostname => $vhostname}
  comanche::virtualhost::wsgi{ "${sitename}":
    vhostname => $vhostname,
    wsgipathfile => "${projectroot}/${sitename}.wsgi",
    pythonpath => "${sourceroot}:${siteroot}/env/lib/python2.7/site-packages"
  }
  comanche::virtualhost::blob{ "${sitename}":
    content=> "<Directory ${sourceroot}/media>\n\
        Order deny,allow\n\
        Allow from all\n\
    </Directory>\n\
    <Directory ${sourceroot}/static>\n\
        Order deny,allow\n\
        Allow from all\n\
    </Directory>\n\
    Alias /media ${sourceroot}/media/\n\
    Alias /static ${sourceroot}/static/"
  }

  file { "${projectroot}/settings.py":
    require => File['projectroot'],
    mode  => 0664,
    owner => "www-data",
    group => "www-data",
    content => template("django/settings.py.erb"),
  }

  file { "${projectroot}/restart.sh":
    require => File['projectroot'],
    mode  => 0770,
    owner => "www-data",
    group => "www-data",
    content => template("django/restart.sh.erb"),
  }

  file {"/etc/apache2/sites-enabled/000-default":
    ensure => absent,
  }

  user { 'vagrant':
    groups => [$comanche::variables::apachegroup],
  }
}
