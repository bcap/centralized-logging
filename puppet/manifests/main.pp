# defaults

Exec {
  path => "/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin",
}

File {
  ensure => file,
  owner  => root,
  group  => $user,
  mode   => 644,
}

Package {
  ensure => present,
}

Service {
  ensure => running,
}

User {
  ensure => present,
  shell  => '/bin/bash',
}

# variables

$downloads_dir = '/var/lib/puppet-downloads'
$pool = regsubst($hostname,'^(.+)-\d+$','\1')


# general configs

file { $downloads_dir :
  ensure => directory,
}

yumrepo { 'epel-x86_64':
  baseurl    => "http://s3-mirror-us-east-1.fedoraproject.org/pub/epel/6/x86_64/",
  descr      => "EPEL x86_64 repository",
  enabled    => 1,
  gpgcheck   => 0,
  mirrorlist => "http://mirrors.fedoraproject.org/mirrorlist?repo=epel-6&arch=x86_64"
}

# Repo setup comes before any package installation
Yumrepo['epel-x86_64'] -> Package <| |>

# required packages
package { [
  'screen', 'zsh', 'vim-enhanced', 'pv', 'tmux', 'byobu', 'nc', 'telnet',
  'iftop', 'htop', 'man', 'rsync', 'tcpick'
]: }


# optional packages
@package { 'java':
  name => 'java-1.7.0-openjdk'
}

# specific node configs

node /^elasticsearch-\d+$/ {
  include centralizedlogging::elasticsearch
}

node /^logstash-\d+$/ {
  include centralizedlogging::logstash
}

node default {}


# specific vagrant configs
if $virtual == 'virtualbox' {

  service {'iptables': ensure => stopped }

  user {'vagrant': shell => '/bin/zsh', require => Package['zsh']}

  file {'/etc/hosts': ensure => link, target => '/vagrant/hosts'}

  file {'/home/vagrant/.oh-my-zsh':
    ensure => directory,
    recurse => true,
    source => '/host/Users/polaco/.oh-my-zsh',
    owner => 'vagrant'
  }

  file {'/home/vagrant/.zshrc':
    ensure => link,
    target => '.oh-my-zsh/.zshrc',
    owner => 'vagrant'
  }
}