# Class: ioncubeloader
#
# This module manages ioncubeloader
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
class ioncubeloader (
  $ensure  = 'present',
  $phpvers = '5.4',
  $inifile = '/etc/php5/conf.d/ioncube.ini') inherits ioncubeloader::params {
  if $ensure == 'present' {
    file { $ioncubeloader::params::destdir: ensure => 'directory' }

    # Download ioncube for proper arch
    $arch = $::architecture ? {
      'amd64' => 'x86-64',
      default => 'x86',
    }

    exec {
      'get-ioncube-installer':
        command => "wget -c \'http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_${arch}.tar.bz2\'",
        creates => "${ioncubeloader::params::destdir}/ioncube_loaders_lin_${arch}.tar.bz2",
        cwd     => $ioncubeloader::params::destdir,
        notify  => Exec['unpack-ioncubeloader'];

      'unpack-ioncubeloader':
        command     => "tar -C ${ioncubeloader::params::basedir} -xf ${ioncubeloader::params::destdir}/ioncube_loaders_lin_${arch}.tar.bz2",
        creates     => "${ioncubeloader::params::destdir}/README.txt",
        refreshonly => true;
    }

    php::config { 'ioncubeloader':
      inifile  => $inifile,
      settings => {
        set => {
          '.anon/zend_extension' => "${ioncubeloader::params::destdir}/ioncube_loader_lin_${phpvers}.so"
        }
      }
      ,
      require  => Exec['unpack-ioncubeloader'],
    }
  } elsif $ensure == 'absent' {
    file {
      $inifile:
        ensure => 'absent';

      $ioncubeloader::params::destdir:
        ensure  => 'absent',
        recurse => true,
    }

  }

}