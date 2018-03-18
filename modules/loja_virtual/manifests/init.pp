class loja_virtual { 
    class { 'apt':
 #       always_apt_update   => true,
         update => { 'frequency' => 'always' }
    }
    
    Class['apt'] -> Package <||>
}
