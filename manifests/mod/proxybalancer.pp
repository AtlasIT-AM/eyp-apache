class apache::mod::proxybalancer ($ensure='installed') inherits apache::params {

  if($apache::params::modproxybalancer_so==undef)
  {
    fail('Unsupported')
  }

  if($ensure=='installed')
  {
    $ensure_conf_file='present'
  }
  elsif($ensure=='purged')
  {
    $ensure_conf_file='absent'
  }
  else
  {
    fail("unsupported ensure: ${ensure}")
  }

  if($ensure=='installed')
  {
    apache::module { 'proxy_balancer_module':
      sofile  => "${apache::params::modulesdir}/${apache::params::modproxybalancer_so}",
    }
  }
}
