class loja_virtual::monitor {
  include loja_virtual
  include loja_virtual::params

  package { 'nagios3':
    ensure  => installed,
  }

  exec { 'SetNagiosAdminPassword':
    command => "htpasswd -cb /etc/nagios3/htpasswd.users nagiosadmin ${loja_virtual::params::nagios_pwd}",
    path    => '/usr/bin/',
    creates => '/etc/nagios3/htpasswd.users',
    require => Package['nagios3'],
    notify  => Service['nagios3'],
  }

  file { '/etc/nagios3/conf.d/loja_virtual.cfg':
    mode    => '0644',
    source  => 'puppet:///modules/loja_virtual/loja_virtual.cfg',
    require => Package['nagios3'],
    notify  => Service['nagios3'],
  }

  service { 'nagios3':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['nagios3'],
  }
}
