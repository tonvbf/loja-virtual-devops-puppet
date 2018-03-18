class tomcat::server($connectors = [], $data_sources = []) {

    $tomcat_base = '/var/lib/tomcat7'
    $tomcat_home = '/usr/share/tomcat7'
    $mysql_cvrs  = "5.1.45-bin"
    $mysql_conn  = "mysql-connector-java-${mysql_cvrs}.jar"

    package { 'tomcat7':
        ensure   => installed,
    }

    file { '/etc/default/tomcat7':
        owner    => root,
        group    => root,
        mode     => '0644',
        source   => "puppet:///modules/tomcat/tomcat7",
        require  => Package['tomcat7'],
        notify   => Service['tomcat7'],
    }

    file { "${tomcat_home}/common":
        ensure  => 'link',
        target  => "${tomcat_base}/common",
        require => Package['tomcat7'],
        notify  => Service['tomcat7'],
    }
    
    file { "${tomcat_base}/conf/server.xml":
        owner   => root,
        group   => tomcat7,
        mode    => '0644',
        content => template("tomcat/server.xml"),
        require => Package['tomcat7'],
        notify  => Service['tomcat7'],
    }

    file { "${tomcat_base}/common/${mysql_conn}":
        owner   => root,
        group   => root,
        mode    => '0644',
        source  => "puppet:///modules/tomcat/${mysql_conn}",
        require => Package['tomcat7'],
        notify  => Service['tomcat7'],
    }
    
    file { "${tomcat_base}/conf/context.xml":
        owner    => root,
        group    => 'tomcat7',
        mode     => '0644',
        content  => template("tomcat/context.xml"),
        require  => File["${tomcat_base}/common/${mysql_conn}"],
        notify   => Service['tomcat7'],
    }

    service { 'tomcat7':
        ensure       => running,
        enable       => true,
        hasstatus    => true,
        hasrestart   => true,
        require      => Package['tomcat7'], 
    }
}




