# Class: ntp::ntpdate
#
# This module manages ntpdate.
#
# Parameters:
#   [*server_list*]
#     List of NTP servers to use.
#     Default: [
#       '0.pool.ntp.org',
#       '1.pool.ntp.org',
#       '2.pool.ntp.org',
#       '3.pool.ntp.org',
#       ],
#
#   [*ensure*]
#     Ensure if package is present or absent.
#     Default: present
#
#   [*autoupgrade*]
#     Upgrade package automatically, if there is a newer version.
#     Default: false
#
#   [*package*]
#     Name of the package.
#     Only set this, if your platform is not supported or you know, what you're doing.
#     Default: auto-set, platform specific
#
#   [*config_file*]
#     Main configuration file.
#     Only set this, if your platform is not supported or you know, what you're doing.
#     Default: auto-set, platform specific
#
#   [*defaults_file*]
#     Init script configuration file.
#     Default: auto-set, platform specific
#
#   [*ntpdate_options*]
#     Options to pass to the ntpdate command.
#     Default: '-U ntp -s -b'
#
#   [*sync_hwclock*]
#     Whether or not to sync the hardware clock to the current time.
#     Default: false
#
# Actions:
#   Installs ntpdate package and configures it
#
# Requires:
#   Nothing
#
# Sample Usage:
#   class { 'ntp::ntpdate':
#     server_enabled = true,
#   }
#
# [Remember: No empty lines between comments and class definition]
class ntp::ntpdate(
  # TODO: get $server_list from Class["ntp"]
  $server_list = [
    '0.pool.ntp.org',
    '1.pool.ntp.org',
    '2.pool.ntp.org',
    '3.pool.ntp.org',
  ],
  $ensure = 'present',
  $autoupgrade = false,
  $package = $ntp::params::ntpdate_package,
  $config_file = $ntp::params::ntpdate_config_file,
  $defaults_file = $ntp::params::ntpdate_defaults_file,
  $ntpdate_options = '-U ntp -s -b',
  $sync_hwclock = false
) inherits ntp::params {

  case $ensure {
    /(present)/: {
      if $autoupgrade == true {
        $package_ensure = 'latest'
      } else {
        $package_ensure = 'present'
      }
    }

    /(absent)/: {
      $package_ensure = 'absent'
    }
    default: {
      fail('ensure parameter must be present or absent')
    }
  }

  package { $package:
    ensure => $package_ensure,
  }

  file { $config_file:
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('ntp/step-tickers.erb'),
    require => Package[$package],
    notify  => Service[$service_name],
  }

  file { $defaults_file:
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('ntp/ntpdate.defaults.erb'),
    require => Package[$package],
    notify  => Service[$service_name],
  }

}
