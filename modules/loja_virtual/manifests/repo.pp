class loja_virtual::repo($basedir, $sname) {

    package { 'reprepro':
        ensure  =>  'installed',
    }
    
    $repo_structure = [
        "$basedir",
        "$basedir/conf"
    ]
    
    file { $repo_structure:
        ensure  => 'directory',
        owner   => 'jenkins',
        group   => 'jenkins',
        require => Class['jenkins'],
    }
    
    file { "$basedir/devopspkgs.gpg":
        owner   =>  'jenkins',
        group   =>  'jenkins',
        source  =>  'puppet:///modules/loja_virtual/devopspkgs.gpg',
        require =>  File["$basedir"],
    }

    file { "$basedir/conf/distributions":
        owner   => 'jenkins',
        group   => 'jenkins',
        content => template('loja_virtual/distributions.erb'),
        require => File["$basedir/conf"],
    }
    
    class { 'apache': }
    
    apache::vhost { $sname:
        port        =>  80,
        docroot     =>  $basedir,
        servername  =>  $facts['networking']['interfaces']['enp0s8']['ip'],
    }
    
  
    
    

}

