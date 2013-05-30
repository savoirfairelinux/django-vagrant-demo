#
# virtualhost definition
#
define comanche::virtualhost::blob(
  $apache2_rootdir      = $comanche::variables::rootdir,
  $order                = 30,
  $content
) {
  concat::fragment {"apache2vhost_${name}_blob":
    target  => "${apache2_rootdir}/sites-available/${name}.conf",
    content => "\n${content}\n",
    order   => $order
  }
}
