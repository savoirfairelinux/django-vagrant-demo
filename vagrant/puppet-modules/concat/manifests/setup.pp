class concat::setup {
    $root_group = $id ? {
      root => 0,
      default => $id
    }
    $concatdir = $concat_basedir
    $majorversion = regsubst($puppetversion, '^[0-9]+[.]([0-9]+)[.][0-9]+$', '\1')

    file{"${concatdir}/bin/concatfragments.sh":
            owner  => $id,
            group  => $root_group,
            mode   => 755,
            source => $majorversion ? {
                        24      => "puppet:///concat/concatfragments.sh",
                        default => "puppet:///modules/concat/concatfragments.sh"
                      };

         [ $concatdir, "${concatdir}/bin" ]:
            ensure => directory,
            owner  => $id,
            group  => $root_group,
            mode   => '0750';
    }
}
