class loja_virtual::ci inherits loja_virtual {

  package { [ 'git', 'maven', 'ruby-dev' ]:
    ensure  =>  installed,
  }

  package { ['fpm', 'bundler']:
    ensure   => 'installed',
    provider => 'gem',
    require  => Package['ruby-dev'],
  }
    
  class { 'jenkins':
    config_hash =>  {
      'JAVA_ARGS' =>  { 'value' => '-Xmx256m' }
    },
  }

  $plugins = [
    'apache-httpcomponents-client-4-api',
    'bouncycastle-api',
    'command-launcher',
    'display-url-api',
    'durable-task',
    'git',
    'git-client',
    'greenballs',
    'javadoc',
    'jsch',
    'junit',
    'mailer',
    'matrix-project',
    'maven-plugin',
    'resource-disposer',
    'scm-api',
    'script-security',
    'ssh-credentials',
    'structs',
    'workflow-api',
    'workflow-durable-task-step',
    'workflow-scm-step',
    'workflow-step-api',
    'workflow-support',
    'ws-cleanup'
  ]

  jenkins::plugin { $plugins: }
    
  file { "${jenkins::params::localstatedir}/hudson.tasks.Maven.xml":
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0644',
    source  => 'puppet:///modules/loja_virtual/hudson.tasks.Maven.xml',
    require => Class['jenkins::package'],
    notify  => Service['jenkins'],
  }
  
  $git_repository     = 'https://github.com/tonvbf'
  $git_poll_interval  = '* * * * *'
  $maven_goal         = 'install'
  $archive_artifacts  = 'combined/target/*.war'
  $repo_dir           = '/var/lib/apt/repo'
  $repo_name          = 'devopspkgs'
  
  jenkins::job { 'loja-virtual-devops':
    config  => template('loja_virtual/loja-virtual-devops-config.xml'),
    require => File["${jenkins::params::localstatedir}/hudson.tasks.Maven.xml"],
  }
    
  jenkins::job { 'loja-virtual-puppet':
    config  => template('loja_virtual/loja-virtual-puppet-config.xml'),
    require => File["${jenkins::params::localstatedir}/hudson.tasks.Maven.xml"],
  }
    
  class { 'loja_virtual::repo':
    basedir => $repo_dir,
    sname   => $repo_name,
  }
}
