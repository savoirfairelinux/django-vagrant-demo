#
class comanche (
  $apache2_type	   = "mpm-prefork",
  $apache2_modules =[],
  $apache2_rootdir = $comanche::variables::rootdir
) {
  if ! $comanche::variables::rootdir {fail("You forgot to include comanche::variables")}
  
  #
  # configure type of MPM for apache2. It differs on ubuntu and redhat 
  #
  case "${lsbdistid}" {
    /(Ubuntu|ubuntu|Debian|debian)/ : {
      $httpdpackage="apache2-${apache2_type}"
    }
    /(CentOS|RedHatEnterpriseServer)/ : {
      $httpdpackage="httpd"
      if ($apache2_type == "mpm-event") {
        $httpdServer='/usr/sbin/httpd.event'
      } elsif ($apache2_type == "mpm-prefork") {
        $httpdServer='/usr/sbin/httpd'
      } elsif ($apache2_type == "mpm-worker") {
        $httpdServer='/usr/sbin/httpd.worker'
      } else {
        fail("comanche: apache2_type ($apache2_type) unknow")
      }
      file {'/etc/sysconfig/httpd':
        owner   => root,
        group   => root,
        mode    => 0644,
        content => template('comanche/redhat.sysconfig.httpd.erb'),
        notify    => Service[$comanche::variables::httpdservice]
      }
      package {'mod_ssl': ensure => present }
    }
    default : { fail("comanche: OS not supported") }
  }
  
  package {$httpdpackage: ensure => present }
  service{ $comanche::variables::httpdservice:
    enable     => true,
    ensure     => running,
    hasrestart => true,
    hasstatus  => true,
    require    => [Package[$httpdpackage],File["${apache2_rootdir}/apache2.conf"]]
  }
  
  file {"${apache2_rootdir}/modules":
    ensure => link,
    target => $comanche::variables::modulesdir,
  }
  
  file { "${apache2_rootdir}/mods-available":
    ensure      => directory,
    recurse     => true,
    source  => "puppet:///comanche/mods-available",
#    purge       => true,
    require => Package[$httpdpackage],
    notify      => Service[$comanche::variables::httpdservice]
  }

  file { "${apache2_rootdir}/mods-enabled":
    ensure    => directory,
    require   => Package[$httpdpackage],
  }
  
  if ($lsbdistid =~ /(CentOS|RedHatEnterpriseServer)/) {
    file { "${apache2_rootdir}/conf/httpd.conf":
      ensure  => link,
      target  => "${apache2_rootdir}/apache2.conf",
      require => Package[$httpdpackage],
    }
    file { "${apache2_rootdir}/conf.d/proxy_ajp.conf":
     ensure => absent,
    notify    => Service[$comanche::variables::httpdservice]
    }
    file { "${apache2_rootdir}/conf.d/README":
     ensure => absent,
    notify    => Service[$comanche::variables::httpdservice]
    }
    file { "${apache2_rootdir}/conf.d/php.conf":
     ensure => absent,
    notify    => Service[$comanche::variables::httpdservice]
    }
    file { "${apache2_rootdir}/conf.d/ssl.conf":
      ensure => absent,
      notify    => Service[$comanche::variables::httpdservice]
    }
  }
  
  # minimal modules to make the server working with our basic httpd.conf definition
  if (!defined(Comanche::Module['authz_host'])) { comanche::module { 'authz_host': } }
  if (!defined(Comanche::Module['alias']))      { comanche::module { 'alias': } }
  if (!defined(Comanche::Module['dir']))        { comanche::module { 'dir': conffile => true} }
  if (!defined(Comanche::Module['mime']))       { comanche::module { 'mime': conffile => true} }
  
  $apacheuser=$comanche::variables::apacheuser
  $apachegroup=$comanche::variables::apachegroup
  $apachelogdir=$comanche::variables::httpdlogdir
  $apachepidfile=$comanche::variables::pidfile
  file { "${apache2_rootdir}/apache2.conf":
    content   => template('comanche/apache2.conf.erb'),
    require   => Package[$httpdpackage],
    notify    => Service[$comanche::variables::httpdservice]
  }
  
  file { "${apache2_rootdir}/httpd.conf":
    ensure    => present,
    require   => Package[$httpdpackage],
    notify    => Service[$comanche::variables::httpdservice]
  }
  
  file { "${apache2_rootdir}/ports.conf":
    source    => 'puppet:///comanche/ports.conf',
    require   => Package[$httpdpackage],
    notify    => Service[$comanche::variables::httpdservice]
  }
  
  file { "${apache2_rootdir}/sites-available":
    ensure    => directory,
    purge     => true,
    require   => Package[$httpdpackage],
    notify    => Service[$comanche::variables::httpdservice]
  }
  file { "${apache2_rootdir}/sites-enabled":
    ensure    => directory,
    purge     => true,
    require   => Package[$httpdpackage],
    notify    => Service[$comanche::variables::httpdservice]
  }
  
  # log
  file {"$comanche::variables::httpdlogdir":
    ensure => directory,
    owner  => $comanche::variables::apacheuser,
    group  => $comanche::variables::apachegroup,
    mode   => 700
  }
  
  # lock
  file {'/var/lock/apache2':
    ensure => directory,
    owner  => $comanche::variables::apacheuser,
    group  => $comanche::variables::apachegroup,
    mode   => 755
  }
}
