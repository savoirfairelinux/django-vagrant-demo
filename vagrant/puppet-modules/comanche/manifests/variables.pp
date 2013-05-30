class comanche::variables (
  $htttpdwwwdir="/var/www",
  $logdir="/var/log/apache2"
) {

  $libdir = $architecture ? {
    /(i386)/ => 'lib',
    /(x86_64)/ => 'lib64',
    /(amd64)/ => 'lib64',
  }
  $rootdir = $lsbdistid ? {
    /(Ubuntu|ubuntu|Debian|debian)/ => '/etc/apache2',
    /(CentOS|RedHatEnterpriseServer)/ => '/etc/httpd',
  }
  $modulesdir = $lsbdistid ? {
    # lib64 is just a symlink in ubuntu and doesn't exist starting at Precise
    # sduchesneau
    /(Ubuntu|ubuntu|Debian|debian)/ => "/usr/lib/apache2/modules",
    /(CentOS|RedHatEnterpriseServer)/ => "/usr/$libdir/httpd/modules",
  }
  $wwwrootdir=$htttpdwwwdir
  
  $httpdservice = $lsbdistid ? {
    /(Ubuntu|ubuntu|Debian|debian)/ => 'apache2',
    /(CentOS|RedHatEnterpriseServer)/ => 'httpd',
  }

  $apacheuser= $lsbdistid ? {
    /(Ubuntu|ubuntu|Debian|debian)/ => 'www-data',
    /(CentOS|RedHatEnterpriseServer)/ => 'apache',
  }
  $apachegroup= $lsbdistid ? {
    /(Ubuntu|ubuntu|Debian|debian)/ => 'www-data',
    /(CentOS|RedHatEnterpriseServer)/ => 'apache',
  }
  $pidfile= $lsbdistid ? {
    /(Ubuntu|ubuntu|Debian|debian)/ => '/var/run/apache2.pid',
    /(CentOS|RedHatEnterpriseServer)/ => '/var/run/httpd.pid',
  }
  
  $httpdlogdir=$logdir
}
