#
# LoadModule auth_kerb_module modules/mod_auth_kerb.so
#
# <Location /secured>
# AuthType Kerberos
# AuthName "Kerberos Login"
# KrbMethodNegotiate On
# KrbMethodK5Passwd On
# KrbAuthRealms EXAMPLE.COM
# Krb5KeyTab /etc/httpd/conf/httpd.keytab
# require valid-user
# </Location>
#
# puppet2sitepp @apachekerberosauth
#
define apache::kerberosauth(
                              $url,
                              $krb_authrealms,
                              $krb_keytab_source,
                              $vhost_order       = '00',
                              $port              = '80',
                              $servername        = $name,
                              $authname          = undef,
                              $method_negotiate  = true,
                              $method_k5_passwd  = true,
                            ) {

  if(! defined(Package[$apache::params::kerberos_auth_package]))
  {
    package { $apache::params::kerberos_auth_package:
      ensure => 'installed',
    }
  }

  if(!defined(Apache::Module['auth_kerb_module']))
  {
    #LoadModule auth_kerb_module modules/mod_auth_kerb.so
    apache::module { 'auth_kerb_module':
      sofile  => "${apache::params::modulesdir}/mod_auth_kerb.so",
      require => Package[$apache::params::kerberos_auth_package],
    }
  }

  $url_cleanup = regsubst($url, '[^a-zA-Z]+', '')

  validate_array($krb_authrealms)

  concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run kerberosauth ${url}":
    target  => "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run",
    content => template("${module_name}/location/kerberosauth.erb"),
    order   => '03',
  }

  file { "${apache::params::baseconf}/conf.d/keytabs/${vhost_order}-${servername}-${port}-${url_cleanup}.keytab":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => [
                Package[$apache::params::kerberos_auth_package],
                File["${apache::params::baseconf}/conf.d/keytabs"]
                ],
    notify  => Class['apache::service'],
    source  => $krb_keytab_source,
  }

  if(! defined(File["${apache::params::baseconf}/conf.d/keytabs"]))
  {
    file { "${apache::params::baseconf}/conf.d/keytabs":
      ensure  => 'directory',
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      recurse => true,
      purge   => true,
      require => File["${apache::params::baseconf}/conf.d"],
    }
  }
}
