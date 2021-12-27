class { 'docker':
  version      => 'latest',
  docker_users => ['centos'],
}

class {'docker::compose':
  ensure  => present,
  version => '1.29.2',
}

docker::run { 'nginx_container':
  ensure           => absent,
  image            => 'nginx',
  ports            => ['8090:80'],
  extra_parameters => [ '--restart=no' ],
}

