define concat::fragment($target, $content='', $source='', $order=10, $ensure = "present", $mode = 0644, $owner = $id, $group = $concat::setup::root_group, $backup = "puppet") {
    $safe_name = regsubst($name, '/', '_', 'G')
    $safe_target_name = regsubst($target, '/', '_', 'G')
    $concatdir = $concat::setup::concatdir
    $fragdir = "${concatdir}/${safe_target_name}"

    # if content is passed, use that, else if source is passed use that
    # if neither passed, but $ensure is in symlink form, make a symlink
    case $content {
        "": {
                case $source {
                        "": {
                                case $ensure {
                                    "", "absent", "present", "file", "directory": {
                                        crit("No content, source or symlink specified")
                                    }
                                }
                            }
                   default: { File{ source => $source } }
                }
            }
        default: { File{ content => $content } }
    }

    file{"${fragdir}/fragments/${order}_${safe_name}":
        mode   => $mode,
        owner  => $owner,
        group  => $group,
        ensure => $ensure,
        backup => $backup,
        alias  => "concat_fragment_${name}",
        notify => Exec["concat_${target}"]
    }
}
