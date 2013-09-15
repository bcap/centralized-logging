define tools::startup_script (
  $name = $title,
  $user,
  $process,
  $args,
  $max_stop_wait = 10,
  $pid_file = "/var/run/${name}.pid",
  $script_path = "/etc/init.d/${name}",
  $log_path = "/var/log/${name}"
) {

  file { $script_path:
    content => template('tools/startup-script.sh'),
    mode    => 744
  }

  if $osfamily == 'RedHat' {
    exec { "chkconfig --level 345 ${name} on"
      refreshonly => true,
      subscribe   => File[$script_path]
    }
  }
}