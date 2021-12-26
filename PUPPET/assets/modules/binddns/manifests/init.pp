class binddns::update {
    if $facts['os']['name'] == 'Ubuntu'
    {
        exec { 'update2':     
            command => "/usr/bin/apt-get update -y"   
        }
    }
    elsif $facts['os']['name'] == 'CentOS'
    {
        exec { 'update2':     
            command => "/usr/bin/yum update -y"  
        }
    }  
}

# uniquement pour CentOS
class binddns::server_install {
    package { 'bind':
        require => Class['binddns::update'],
        ensure => installed,                
    }
}

# uniquement pour CentOS
class binddns::server_config {
    # copie du fichier named.conf
    file { '/etc/named.conf':
        ensure => file,
        source => "puppet:///modules/binddns/named.conf",
        require => Class['binddns::server_install'],
    }
    # copie du fichier omar.local.com.db
    file { '/etc/named/omar.local.com.db':
        ensure => file,
        source => "puppet:///modules/binddns/omar.local.com.db",
        require => Class['binddns::server_install'],
    }
    # copie du fichier 172.31.db
    file { '/etc/named/172.31.db':
        ensure => file,
        source => "puppet:///modules/binddns/172.31.db",
        require => Class['binddns::server_install'],
        notify => Class['binddns::service'],
    }
}

# uniquement pour CentOS
class binddns::service {
    service { 'named':
        ensure => running,
    }
}

# pour CentOS et Ubuntu
class binddns::client_install {
    package { 'bind utils':
        name => $operatingsystem ?
        {
            /(Red Hat|CentOS|Fedora)/ => "bind-utils", 
            'Ubuntu' => "dnsutils",
        },
        require => Class['binddns::update'],
        ensure => installed,                
    }
}

class binddns::client_config {
    file { '/etc/resolv.conf':
        ensure => file,
        content => 'nameserver 172.31.83.83'
    }
}

class binddns{
    include binddns::update, binddns::server_install, binddns::server_config, binddns::service, binddns::client_install, binddns::client_config
}