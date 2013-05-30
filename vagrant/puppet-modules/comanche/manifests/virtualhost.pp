#
# virtualhost definition
#
define comanche::virtualhost(
  $apache2_rootdir      = $comanche::variables::rootdir,
  $vhostname  = $name,
  $vhostalias = [],
  $listenip   = '*',
  $documentroot="$comanche::variables::wwwrootdir/$vhostname",
  ssl = false,
  sslkey=false,  # used if ssl ==true
  sslcrt=false,  # used if ssl ==true
  sslchain=false # optional used if ssl ==true
) {
  include concat::setup
  if (!defined(File[$documentroot])) {
    file {$documentroot:
      ensure => directory
    }
#    file {"${documentroot}/cgi-bin":
#      ensure => directory
#    }
#    file {"${documentroot}/html":
#      ensure => directory
#    }
  }
  concat { "${apache2_rootdir}/sites-available/${name}.conf":
    owner   => 'root',
    group   => 'root',
    mode    => 644,
    notify  => Service[$comanche::variables::httpdservice]
  }
  file { "${apache2_rootdir}/sites-enabled/${name}.conf":
    target => "${apache2_rootdir}/sites-available/${name}.conf",
    ensure => link,
    notify  => Service[$comanche::variables::httpdservice]
  }
  $apachelogdir=$comanche::variables::httpdlogdir
  $apachewwwdir="${documentroot}"
  if ($ssl==false) {
    concat::fragment {"apache2vhost_${name}_begin":
      target  => "${apache2_rootdir}/sites-available/${name}.conf",
      content => template('comanche/virtualhost.conf.erb'),
      order   => 01
    }
  } else {
    concat::fragment {"apache2vhost_${name}_begin":
      target  => "${apache2_rootdir}/sites-available/${name}.conf",
      content => template('comanche/virtualhostssl.conf.erb'),
      order   => 01
    }
  }
  concat::fragment {"apache2vhost_${name}_end":
    target  => "${apache2_rootdir}/sites-available/${name}.conf",
    content => template('comanche/virtualhostEnd.conf.erb'),
    order   => 99
  }
}



