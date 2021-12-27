docker::run { 'mario':
  ensure           => absent,
  image            => 'pengbai/docker-supermario',
  ports            => ['8600:8080'],
  extra_parameters => [ '--restart=no' ],
}
