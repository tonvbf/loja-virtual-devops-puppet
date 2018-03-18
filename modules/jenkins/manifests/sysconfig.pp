# Class: jenkins::sysconfig
#
define jenkins::sysconfig(
  Variant[Stdlib::Compat::String, String] $value,
) {
  validate_legacy(String, 'validate_string', $value)

  $path = $::osfamily ? {
    'RedHat' => '/etc/sysconfig',
    'Suse'   => '/etc/sysconfig',
    'Debian' => '/etc/default',
    default  => fail( "Unsupported OSFamily ${::osfamily}" )
  }

  file_line { "Jenkins sysconfig setting ${name}":
    path   => "${path}/jenkins",
    line   => "${name}=\"${value}\"",
    match  => "^${name}=",
    notify => Service['jenkins'],
  }

}
