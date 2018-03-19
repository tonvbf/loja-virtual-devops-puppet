class loja_virtual::repo($basedir, $sname) {

  package { ['reprepro', 'gnupg']:
    ensure  =>  'installed',
  }
    
  $repo_structure = [
    $basedir,
    "${basedir}/conf"
  ]
    
  file { $repo_structure:
    ensure  => 'directory',
    owner   => 'jenkins',
    group   => 'jenkins',
    require => Class['jenkins'],
  }
    
#  file { "${basedir}/devopspkgs.gpg":
#    owner   => 'jenkins',
#    group   => 'jenkins',
#    source  => 'puppet:///modules/loja_virtual/devopspkgs.gpg',
#    require => File[$basedir],
#  }

  file { "${jenkins::params::localstatedir}/${sname}.sec":
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0644',
    source  => "puppet:///modules/loja_virtual/${sname}.sec",
    require => [Package['gnupg'], File[$repo_structure]],
  }

  exec { 'import-secret-key':
    unless  => 'gpg --list-secret-keys "Loja Virtual"',
    command => "gpg --import ${sname}.sec",
    path    => '/usr/bin',
    cwd     => $jenkins::params::localstatedir,
    user    => 'jenkins',
    group   => 'jenkins',
    require => File["${jenkins::params::localstatedir}/${sname}.sec"],
  }
    
  exec { 'export-public-key':
    command => "gpg --export --armor 'Loja Virtual' > ${basedir}/${sname}.gpg",
    path    => '/usr/bin',
    cwd     => $jenkins::params::localstatedir,
    user    => 'jenkins',
    group   => 'jenkins',
    creates => "${basedir}/${sname}.gpg",
    require => Exec['import-secret-key'],
  }
    

  file { "${basedir}/conf/distributions":
    owner   => 'jenkins',
    group   => 'jenkins',
    content => template('loja_virtual/distributions.erb'),
    require => File["${basedir}/conf"],
  }
    
  class { 'apache': }
  
  if $facts['networking']['interfaces']['enp0s8']['ip'] {
    $servername = $facts['networking']['interfaces']['enp0s8']['ip'],
  } else {
    $servername = $facts['networking']['interfaces']['eth0']['ip']
  }
    
  apache::vhost { $sname:
    port       => 80,
    docroot    => $basedir,
    servername => $servername,
  }

}

