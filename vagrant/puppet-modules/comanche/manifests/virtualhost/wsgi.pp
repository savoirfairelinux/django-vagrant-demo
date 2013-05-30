#
# virtualhost definition
#
define comanche::virtualhost::wsgi(
  $apache2_rootdir = $comanche::variables::rootdir,
  $vhostname       = $name,
  $documentroot    = $comanche::variables::wwwrootdir,
  $wsgipathfile    = false,
  $pythonpath      = false,
) {
  if (!defined(Package['libapache2-mod-wsgi'])) {
    package { 'libapache2-mod-wsgi': }
  }
  if (!defined(Comanche::Module['wsgi'])) {
    comanche::module { 'wsgi': }
  }
  concat::fragment {"apache2vhost_${name}_wsgi":
    target  => "${apache2_rootdir}/sites-available/${name}.conf",
    content => template('comanche/virtualhostWsgi.conf.erb'),
    order   => 15
  }
}
