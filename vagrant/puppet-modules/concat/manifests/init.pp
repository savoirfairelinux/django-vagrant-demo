define concat($mode = 0644, $owner = $id, $group = $concat::setup::root_group, $warn = "false", $force = "false", $backup = "puppet", $gnu = "true", $order="alpha") {
    $safe_name   = regsubst($name, '/', '_', 'G')
    $concatdir   = $concat::setup::concatdir
    $version     = $concat::setup::majorversion
    $fragdir     = "${concatdir}/${safe_name}"
    $concat_name = "fragments.concat.out"
    $default_warn_message = '# This file is managed by Puppet. DO NOT EDIT.'

    case $warn {
        'true',true,yes,on:   { $warnmsg = "$default_warn_message" }
        'false',false,no,off: { $warnmsg = "" }
        default:              { $warnmsg = "$warn" }
    }

    $warnmsg_escaped = regsubst($warnmsg, "'", "'\\\\''", 'G')
    $warnflag = $warnmsg_escaped ? {
        ''      => '',
        default => "-w '$warnmsg_escaped'"
    }

    case $force {
        'true',true,yes,on: { $forceflag = "-f" }
        'false',false,no,off: { $forceflag = "" }
        default: { fail("Improper 'force' value given to concat: $force") }
    }

    case $gnu {
        'true',true,yes,on: { $gnuflag = "" }
        'false',false,no,off: { $gnuflag = "-g" }
        default: { fail("Improper 'gnu' value given to concat: $gnu") }
    }

    case $order {
        numeric: { $orderflag = "-n" }
        alpha: { $orderflag = "" }
        default: { fail("Improper 'order' value given to concat: $order") }
    }

    File{
        owner  => $id,
        group  => $group,
        mode   => $mode,
        backup => $backup
    }

    file{$fragdir:
            ensure   => directory;

         "${fragdir}/fragments":
            ensure   => directory,
            recurse  => true,
            purge    => true,
            force    => true,
            ignore   => [".svn", ".git", ".gitignore"],
            source   => $version ? {
                            24      => "puppet:///concat/null",
                            default => undef,
                        },
            notify   => Exec["concat_${name}"];

         "${fragdir}/fragments.concat":
            ensure   => present;

         "${fragdir}/${concat_name}":
            ensure   => present;

         $name:
            source   => "${fragdir}/${concat_name}",
            owner    => $owner,
            group    => $group,
            checksum => md5,
            mode     => $mode,
            ensure   => present,
            alias    => "concat_${name}";
    }

    exec{"concat_${name}":
        notify    => File[$name],
        subscribe => File[$fragdir],
        alias     => "concat_${fragdir}",
        require   => [ File[$fragdir], File["${fragdir}/fragments"], File["${fragdir}/fragments.concat"] ],
        unless    => "${concat::setup::concatdir}/bin/concatfragments.sh -o ${fragdir}/${concat_name} -d ${fragdir} -t ${warnflag} ${forceflag} ${orderflag} ${gnuflag}",
        command   => "${concat::setup::concatdir}/bin/concatfragments.sh -o ${fragdir}/${concat_name} -d ${fragdir} ${warnflag} ${forceflag} ${orderflag} ${gnuflag}",
    }
    if $id == 'root' {
      Exec["concat_${name}"]{
        user      => root,
        group     => $group,
      }
    }
}
