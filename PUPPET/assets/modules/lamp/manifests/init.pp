class lamp::update {
    if $facts['os']['name'] == 'Ubuntu'
    {
        exec { 'update':     
            command => "/usr/bin/apt-get update -y"   
        }
    }
    elsif $facts['os']['name'] == 'CentOS'
    {
        exec { 'update':     
            command => "/usr/bin/yum update -y"  
        }
    }   
}

class lamp::epel_release {
    if $facts['os']['family'] == 'RedHat'
    {
        package { 'epel-release':
            require => Class['lamp::update'],
            ensure => installed,      
        }
    }
}

class lamp::apache {
    $web = $operatingsystem ? 
    {
        /(Red Hat|CentOS|Fedora)/ => "httpd", 
        'Ubuntu' => "apache2",
        default => "httpd",
    }
    package { "apache lamp":
        name => $web,
        require => Class['lamp::update'],
        ensure => installed,        
    }
}

class lamp::apache_service {
    service { 'apache lamp':
        name => $operatingsystem ?
        {
            /(Red Hat|CentOS|Fedora)/ => "httpd", 
            'Ubuntu' => "apache2",
            default => "httpd",
        },
        ensure => running,
    }
}

class lamp::mysql { 
    package { 'mysql lamp':
    name => $operatingsystem ?
        {
            /(Red Hat|CentOS|Fedora)/ => "mariadb", 
            'Ubuntu' => "mysql-server",
        },
        ensure => installed,      
    }
}

class lamp::mysql_service {
    service { 'mysql lamp':
        name => $operatingsystem ?
        {
            /(Red Hat|CentOS|Fedora)/ => "mariadb", 
            'Ubuntu' => "mysql",
        },
        ensure => running,
    }
}

class lamp::php {
    package { 'php':
        require => Class['lamp::update'],
        ensure => installed,                
    }
}

class lamp::php_init {
    file { '/var/www/html/index.php':
        ensure => file,
        source => "puppet:///modules/lamp/index.php",
        require => Class['lamp::apache'],
        notify => Class['lamp::apache_service'],
    }

    if $facts['os']['family'] == 'RedHat'
    {
        file { '/etc/httpd/conf.d/welcome.conf':
            ensure => absent,
            notify => Class['lamp::apache_service'],       
        }
    }

    if $facts['os']['name'] == 'Ubuntu'
    {
        file { '/var/www/html/index.html':
            ensure => absent,
            notify => Class['lamp::apache_service'],       
        }
    } 
}

class lamp {
    include lamp::update, lamp::epel_release, lamp::apache, lamp::apache_service, lamp::mysql, lamp::mysql_service, lamp::php, lamp::php_init
}
