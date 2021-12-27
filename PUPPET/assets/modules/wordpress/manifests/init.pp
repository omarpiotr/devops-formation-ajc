class wordpress {
  file { '/tmp/docker-compose.yml':
    ensure => file,
    source => 'puppet:///modules/wordpress/docker-compose_wordpress.yml',
  }

  docker_compose { 'test':
    compose_files => ['/tmp/docker-compose.yml'],
    ensure        => present,
  }
}

