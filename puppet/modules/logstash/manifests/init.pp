class logstash (
  $user = "logstash",
  $version = "1.2.1",
) {

  realize Package["java"]

  exec { "download logstash $version":
    command => "wget https://logstash.objects.dreamhost.com/release/logstash-$version-flatjar.jar \
                -O $downloads_dir/logstash-$version-flatjar.jar.tmp && \
                mv $downloads_dir/logstash-$version-flatjar.jar.tmp $downloads_dir/logstash-$version-flatjar.jar",
    creates => "$downloads_dir/logstash-$version-flatjar.jar",
    require => File[$downloads_dir]
  }

  file { "/opt/logstash-$version":
    ensure => directory,
  }

  exec { "install logstash $version":
    command => "cp -r $downloads_dir/logstash-$version-flatjar.jar /opt/logstash-$version",
    creates => "/opt/logstash-$version/logstash-$version-flatjar.jar",
    require => [File["/opt/logstash-$version"], Exec["download logstash $version"]]
  }

  user { $user :
    system  => true,
    home    => "/opt/logstash-$version",
    require => Exec["install logstash $version"]
  }

}