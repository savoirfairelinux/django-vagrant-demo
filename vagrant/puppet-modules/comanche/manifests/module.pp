# to enable a module
#  $apache2_rootdir      = $comanche::variables::rootdir,
define comanche::module(
  $apache2_rootdir	= $comanche::variables::rootdir,
  $ensure               = 'present',
  $required_package     = false,
  $conffile             = false,
  $template_conffile    = false
) {
  file { "${apache2_rootdir}/mods-enabled/${name}.load":
    ensure => link,
    target => "../mods-available/${name}.load",
    notify => Service[$comanche::variables::httpdservice]
  }
  if $required_package { realize Package[$required_package] }
  
  if ($conffile) {
    file { "${apache2_rootdir}/mods-enabled/${name}.conf":
      source => "puppet:///comanche/mods-available/${name}.conf"
    }
  }
  if ($template_conffile) {
    file { "${apache2_rootdir}/mods-enabled/${name}.conf":
      content => template ("comanche/${template_conffile}.conf.erb")
    }
  }
}
