class loja_virtual {
  class { 'apt':
    update => {'frequency' => 'always'}
  }
    
  Class['apt'] -> Package <||>
}
