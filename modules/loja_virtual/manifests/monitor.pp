class loja_virtual::monitor {
    include loja_virtual
    include loja_virtual::params

#    file { "/etc/apt/preferences.d/nagios":
#        mode     => "0644",
#        source   => "puppet:///modules/loja_virtual/nagios",
#    } 

#    file { "/etc/apt/sources.list.d/raring.list":
#        mode     => "0644",
#        source   => "puppet:///modules/loja_virtual/raring.list",
#        require => File["/etc/apt/preferences.d/nagios"]
#    }

    package { "nagios3":
        ensure  => installed,
#        require => File["/etc/apt/sources.list.d/raring.list"]
    }

    exec { "SetNagiosAdminPassword":
        command  => "htpasswd -cb /etc/nagios3/htpasswd.users nagiosadmin $loja_virtual::params::nagios_pwd",
        path     => "/usr/bin/",
        creates  => "/etc/nagios3/htpasswd.users",
        require  => Package["nagios3"],
        notify   => Service["nagios3"],
    }

    file { "/etc/nagios3/conf.d/loja_virtual.cfg":
        mode     => "0644",
        source   => "puppet:///modules/loja_virtual/loja_virtual.cfg",
        require  => Package["nagios3"],
        notify   => Service["nagios3"],
    }

    service { "nagios3":
        ensure       => running,
        enable       => true,
        hasstatus    => true,
        hasrestart   => true,
        require      => Package["nagios3"], 
    }
}
