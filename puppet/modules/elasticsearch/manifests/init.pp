class elasticsearch (
  $elasticsearch_config_template = "",
  $logging_config_template = "",
  $user = "elasticsearch",
  $version = "0.90.3",
  $log_dir = "/var/log/elasticsearch",
  $data_dir = "/var/lib/elasticsearch/data",
  $tmp_dir = "/var/lib/elasticsearch/tmp",
) {

  realize Package["java"]

  exec { "download elasticsearch $version":
    command => "wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-$version.tar.gz \
                -O $downloads_dir/elasticsearch-$version.tar.gz.tmp && \
                mv $downloads_dir/elasticsearch-$version.tar.gz.tmp $downloads_dir/elasticsearch-$version.tar.gz",
    creates => "$downloads_dir/elasticsearch-$version.tar.gz",
    require => File[$downloads_dir]
  }

  exec { "extract elasticsearch $version":
    command => "tar -xvzf elasticsearch-$version.tar.gz",
    cwd => "$downloads_dir",
    refreshonly => true,
    subscribe => Exec["download elasticsearch $version"]
  }

  exec { "install elasticsearch $version":
    command => "cp -r $downloads_dir/elasticsearch-$version /opt",
    creates => "/opt/elasticsearch-$version",
    require => Exec["extract elasticsearch $version"]
  }

  user { $user :
    system  => true,
    home    => "/opt/elasticsearch-$version",
    require => Exec["install elasticsearch $version"]
  }

  exec { "create dirs" :
    command => "mkdir -p $log_dir $data_dir $tmp_dir",
    unless  => "test -d $log_dir && test -d $data_dir && test -d $tmp_dir"
  }

  file { [$log_dir, $data_dir, $tmp_dir] :
    ensure => directory,
    owner => $user,
    require => [User[$user], Exec["create dirs"]]
  }

  if ($elasticsearch_config_template != '') {
    file { "/opt/elasticsearch-$version/config/elasticsearch.yml" :
      content => template("$elasticsearch_config_template"),
      require => Exec["install elasticsearch $version"]
    }
  }

  if ($logging_config_template != '') {
    file { "/opt/elasticsearch-$version/config/logging.yml" :
      content => template("$logging_config_template"),
      require => Exec["install elasticsearch $version"]
    }
  }

}