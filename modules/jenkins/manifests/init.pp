# Parameters:
#
# version = 'installed' (Default)
#   Will NOT update jenkins to the most recent version.
#
# version = 'latest'
#    Will automatically update the version of jenkins to the current version available via your package manager.
#
# lts = false
#   Use the most up to date version of jenkins
#
# lts = true (Default)
#   Use LTS verison of jenkins
#
# port = 8080 (default)
#   Sets firewall port to 8080 if puppetlabs-firewall module is installed
#
# repo = true (Default)
#   install the jenkins repo.
#
# repo = 0
#   Do NOT install a repo. This means you'll manage a repo manually outside
#   this module.
#   This is for folks that use a custom repo, or the like.
#
# package_name = 'jenkins'
#   Optionally override the package name
#
# direct_download = 'http://...'
#   Ignore repostory based package installation and download and install
#   package directly.  Leave as `undef` (the default) to download using your
#   OS package manager
#
# package_cache_dir  = '/var/cache/jenkins_pkgs'
#   Optionally specify an alternate location to download packages to when using
#   direct_download
#
# service_enable = true (default)
#   Enable (or not) the jenkins service
#
# service_ensure = 'running' (default)
#   Status of the jenkins service.  running, stopped
#
# config_hash = undef (Default)
#   Hash with config options to set in sysconfig/jenkins defaults/jenkins
#
# manage_datadirs = true (default)
#   true if this module should manage the local state dir, plugins dir and jobs dir
#
# localstatedir = '/var/lib/jenkins' (default)
#   base path, in the autoconf sense, for jenkins local data including jobs and
#   plugins
#
# executors = undef (Default)
#   Integer number of executors on the Jenkin's master.
#
# slaveagentport = undef (Default)
#   Integer number of portnumber for the slave agent.
#
# manage_user = true (default)
#
# user = 'jenkins' (default)
#`  system user that owns the jenkins master's files
#
# manage_group = true (default)
#
# group = 'jenkins' (default)
#`  system group that owns the jenkins master's files
#
# Example use
#
# class{ 'jenkins':
#   config_hash => {
#     'HTTP_PORT' => { 'value' => '9090' }, 'AJP_PORT' => { 'value' => '9009' }
#   }
# }
#
# plugin_hash = undef (Default)
# Hash with config plugins to install
#
# Example use
#
# class{ 'jenkins::plugins':
#   plugin_hash => {
#     'git' => { version => '1.1.1' },
#     'parameterized-trigger' => {},
#     'multiple-scms' => {},
#     'git-client' => {},
#     'token-macro' => {},
#   }
# }
#
# OR in Hiera
#
# jenkins::plugin_hash:
#    'git':
#       version: 1.1.1
#    'parameterized-trigger': {}
#    'multiple-scms': {}
#    'git-client': {}
#    'token-macro': {}
#
#
# user_hash = {} (Default)
# Hash with users to create in jenkins
#
# Example use
#
# class{ 'jenkins':
#   user_hash => {
#     'user1' => { 'password' => 'pass1',
#                     'email' => 'user1@example.com'}
#
# Or in Hiera
#
# jenkins::user_hash:
#     'user1':
#       password: 'pass1'
#       email: 'user1@example.com'
#
# configure_firewall = false (default)
#   For folks that want to manage the puppetlabs firewall module.
#    - If it's not present in the catalog, nothing happens.
#    - If it is, you need to explicitly set this true / false.
#       - We didn't want you to have a service opened automatically, or unreachable inexplicably.
#    - This default changed in v1.0 to be undef.
#
#
# install_java = true (default)
#   - use puppetlabs-java module to install the correct version of a JDK.
#   - Jenkins requires a JRE
#
#
# cli = true (default)
#   - force installation of the jenkins CLI jar to $libdir/cli/jenkins-cli.jar
#   - the cli is automatically installed when needed by components that use it,
#     such as the user and credentials types, and the security class
#   - CLI installation (both implicit and explicit) requires the unzip command
#
#
# cli_ssh_keyfile = undef (default)
#   Provides the location of an ssh private key file to make authenticated
#   connections to the Jenkins CLI.
#
#
# cli_tries = 10 (default)
#   Retries until giving up talking to jenkins API
#
#
# cli_try_sleep = 10 (default)
#   Seconds between tries to contact jenkins API
#
# repo_proxy = undef (default)
#   If you environment requires a proxy to download packages
#
# proxy_host = undef (default)
# proxy_port = undef (default)
#   If your environment requires a proxy host to download plugins it can be configured here
#
#
# no_proxy_list = undef (default)
#   List of hostname patterns to skip using the proxy.
#   - Accepts input as array only.
#   - Only effective if "proxy_host" and "proxy_port" are set.
#
# user = 'jenkins' (default)
#
# group = 'jenkins' (default)
#
#
class jenkins(
  Variant[Stdlib::Compat::String, String]             $version            = $jenkins::params::version,
  Variant[Stdlib::Compat::Bool, Boolean]              $lts                = $jenkins::params::lts,
  Variant[Stdlib::Compat::Bool, Boolean]              $repo               = $jenkins::params::repo,
  Variant[Stdlib::Compat::String, String]             $package_name       = $jenkins::params::package_name,
  Optional[Variant[Stdlib::Compat::String, String]]   $direct_download    = $::jenkins::params::direct_download,
  Stdlib::Absolutepath                                $package_cache_dir  = $jenkins::params::package_cache_dir,
  Variant[Stdlib::Compat::String, String]             $package_provider   = $jenkins::params::package_provider,
  Variant[Stdlib::Compat::Bool, Boolean]              $service_enable     = $jenkins::params::service_enable,
  Variant[Stdlib::Compat::String, String]             $service_ensure     = $jenkins::params::service_ensure,
  Optional[Variant[Stdlib::Compat::String, String]]   $service_provider   = $jenkins::params::service_provider,
  Variant[Stdlib::Compat::Hash, Hash]                 $config_hash        = {},
  Variant[Stdlib::Compat::Hash, Hash]                 $plugin_hash        = {},
  Variant[Stdlib::Compat::Hash, Hash]                 $job_hash           = {},
  Variant[Stdlib::Compat::Hash, Hash]                 $user_hash          = {},
  Variant[Stdlib::Compat::Bool, Boolean]              $configure_firewall = false,
  Variant[Stdlib::Compat::Bool, Boolean]              $install_java       = $jenkins::params::install_java,
  Optional[Variant[Stdlib::Compat::String, String]]   $repo_proxy         = undef,
  Optional[Variant[Stdlib::Compat::String, String]]   $proxy_host         = undef,
  Optional[Variant[Stdlib::Compat::Integer, Integer]] $proxy_port         = undef,
  Optional[Variant[Stdlib::Compat::Array, Array]]     $no_proxy_list      = undef,
  Variant[Stdlib::Compat::Bool, Boolean]              $cli                = true,
  Optional[Stdlib::Absolutepath]                      $cli_ssh_keyfile    = undef,
  Variant[Stdlib::Compat::Integer, Integer]           $cli_tries          = $jenkins::params::cli_tries,
  Variant[Stdlib::Compat::Integer, Integer]           $cli_try_sleep      = $jenkins::params::cli_try_sleep,
  Variant[Stdlib::Compat::Integer, Integer]           $port               = $jenkins::params::port,
  Optional[Stdlib::Absolutepath]                      $libdir             = $jenkins::params::libdir,
  Variant[Stdlib::Compat::Bool, Boolean]              $manage_datadirs    = $jenkins::params::manage_datadirs,
  Stdlib::Absolutepath                                $localstatedir      = $::jenkins::params::localstatedir,
  Optional[Variant[Stdlib::Compat::Integer, Integer]] $executors          = undef,
  Optional[Variant[Stdlib::Compat::Integer, Integer]] $slaveagentport     = undef,
  Variant[Stdlib::Compat::Bool, Boolean]              $manage_user        = $::jenkins::params::manage_user,
  Variant[Stdlib::Compat::String, String]             $user               = $::jenkins::params::user,
  Variant[Stdlib::Compat::Bool, Boolean]              $manage_group       = $::jenkins::params::manage_group,
  Variant[Stdlib::Compat::String, String]             $group              = $::jenkins::params::group,
) inherits jenkins::params {

  validate_legacy(String, 'validate_string', $version)
  validate_legacy(Boolean, 'validate_bool', $lts)
  validate_legacy(Boolean, 'validate_bool', $repo)
  validate_legacy(String, 'validate_string', $package_name)
  validate_legacy(Optional[String], 'validate_string', $direct_download)
  validate_legacy(Stdlib::Absolutepath, 'validate_absolute_path', $package_cache_dir)
  validate_legacy(String, 'validate_string', $package_provider)
  validate_legacy(Boolean, 'validate_bool', $service_enable)
  validate_legacy(String, 'validate_re', $service_ensure, '^running$|^stopped$')
  validate_legacy(Optional[String], 'validate_string', $service_provider)
  validate_legacy(Hash, 'validate_hash', $config_hash)
  validate_legacy(Hash, 'validate_hash', $plugin_hash)
  validate_legacy(Hash, 'validate_hash', $job_hash)
  validate_legacy(Hash, 'validate_hash', $user_hash)
  validate_legacy(Boolean, 'validate_bool', $configure_firewall)
  validate_legacy(Boolean, 'validate_bool', $install_java)
  validate_legacy(Optional[String], 'validate_string', $repo_proxy)
  validate_legacy(Optional[String], 'validate_string', $proxy_host)
  if $proxy_port { validate_legacy(Integer, 'validate_integer', $proxy_port) }
  if $no_proxy_list { validate_legacy(Array, 'validate_array', $no_proxy_list) }
  validate_legacy(Boolean, 'validate_bool', $cli)
  if $cli_ssh_keyfile { validate_legacy(Stdlib::Absolutepath, 'validate_absolute_path', $cli_ssh_keyfile) }
  validate_legacy(Integer, 'validate_integer', $cli_tries)
  validate_legacy(Integer, 'validate_integer', $cli_try_sleep)
  validate_legacy(Integer, 'validate_integer', $port)
  validate_legacy(Stdlib::Absolutepath, 'validate_absolute_path', $libdir)
  validate_legacy(Boolean, 'validate_bool', $manage_datadirs)
  validate_legacy(Stdlib::Absolutepath, 'validate_absolute_path', $localstatedir)
  if $executors { validate_legacy(Integer, 'validate_integer', $executors) }
  if $slaveagentport { validate_legacy(Integer, 'validate_integer', $slaveagentport) }
  validate_legacy(Boolean, 'validate_bool', $manage_user)
  validate_legacy(String, 'validate_string', $user)
  validate_legacy(Boolean, 'validate_bool', $manage_group)
  validate_legacy(String, 'validate_string', $group)

  $plugin_dir = "${localstatedir}/plugins"
  $job_dir = "${localstatedir}/jobs"

  anchor {'jenkins::begin':}
  anchor {'jenkins::end':}

  if $install_java {
    include ::java
  }

  if $direct_download {
    $repo_ = false
    $jenkins_package_class = 'jenkins::direct_download'
  } else {
    $jenkins_package_class = 'jenkins::package'
    if $repo {
      $repo_ = true
      include jenkins::repo
    } else {
      $repo_ = false
    }
  }
  include $jenkins_package_class

  include jenkins::config
  include jenkins::plugins
  include jenkins::jobs
  include jenkins::users

  if $proxy_host and $proxy_port {
    class { 'jenkins::proxy':
      require => Package['jenkins'],
      notify  => Service['jenkins']
    }

    # param format needed by puppet/archive
    $proxy_server = "http://${jenkins::proxy_host}:${jenkins::proxy_port}"
  } else {
    $proxy_server = undef
  }


  include jenkins::service

  if defined('::firewall') {
    if $configure_firewall == undef {
      fail('The firewall module is included in your manifests, please configure $configure_firewall in the jenkins module')
    } elsif $configure_firewall {
      include jenkins::firewall
    }
  }

  if $cli {
    include jenkins::cli
    include jenkins::cli_helper
  }

  if $executors {
    jenkins::cli::exec { 'set_num_executors':
      command => ['set_num_executors', $executors],
      unless  => "[ \$(\$HELPER_CMD get_num_executors) -eq ${executors} ]"
    }

    Class['jenkins::cli'] ->
      Jenkins::Cli::Exec['set_num_executors'] ->
        Class['jenkins::jobs']
  }

  if ($slaveagentport != undef) {
    jenkins::cli::exec { 'set_slaveagent_port':
      command => ['set_slaveagent_port', $slaveagentport],
      unless  => "[ \$(\$HELPER_CMD get_slaveagent_port) -eq ${slaveagentport} ]"
    }

    Class['jenkins::cli'] ->
      Jenkins::Cli::Exec['set_slaveagent_port'] ->
        Class['jenkins::jobs']
  }

  Anchor['jenkins::begin'] ->
    Class[$jenkins_package_class] ->
      Class['jenkins::config'] ->
        Class['jenkins::plugins'] ~>
          Class['jenkins::service'] ->
            Class['jenkins::jobs'] ->
              Anchor['jenkins::end']

  if $install_java {
    Anchor['jenkins::begin'] ->
      Class['java'] ->
        Class[$jenkins_package_class] ->
          Anchor['jenkins::end']
  }

  if $repo_ {
    Anchor['jenkins::begin'] ->
      Class['jenkins::repo'] ->
        Class['jenkins::package'] ->
          Anchor['jenkins::end']
  }

  if $configure_firewall {
    Class['jenkins::service'] ->
      Class['jenkins::firewall'] ->
        Anchor['jenkins::end']
  }
}
# vim: ts=2 et sw=2 autoindent
