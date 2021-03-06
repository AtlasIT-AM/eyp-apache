# puppet2sitepp @apacheredirects
define apache::redirect (
                          $url,
                          $path             = undef,
                          $match            = undef,
                          $status           = 'permanent',
                          $order            = '00',
                          $port             = '80',
                          $servername       = $name,
                        ) {

  if($path==undef and $match==undef)
  {
    fail('path and match are undef, WTF man...')
  }

  if($path!=undef and $match!=undef)
  {
    fail('path and match cannot be defined at the same time, WTF man...')
  }

  concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run redirect ${match} ${path} ${url}":
    target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run",
    content => template("${module_name}/redirects/redirects.erb"),
    order   => '04',
  }

}
