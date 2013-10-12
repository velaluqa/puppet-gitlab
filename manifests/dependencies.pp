# Class:: gitlab::dependencies
#
#
class gitlab::dependencies {
  include gitlab

  $git_home       = $gitlab::git_home
  $git_user       = $gitlab::git_user
  $git_comment    = $gitlab::git_comment
  $gitlab_dbtype  = $gitlab::gitlab_dbtype

  if !defined(Package['bundler']) { package { 'bundler': ensure => present, provider => gem; } }
  if !defined(Package['charlock_holmes']) { package { 'charlock_holmes': ensure => '0.6.9.4', provider => gem; } }

  user {
    $git_user:
      ensure     => present,
      shell      => '/bin/bash',
      password   => '*',
      home       => $git_home,
      comment    => $git_comment,
      system     => true;
  }

  file {
    $git_home:
      ensure  => directory,
      owner   => $git_user,
      group   => $git_user,
      require => User[$git_user],
      mode    => '0755',
  }

  class { 'redis': }

  # try and decide about the family here,
  # deal with version/dist specifics within the class
  case $::osfamily {
    'Debian': {

      case $gitlab_dbtype {
        'mysql': {
          if !defined(Package['libmysql++-dev']) { package { 'libmysql++-dev': ensure => present; } }
          if !defined(Package['libmysqlclient-dev']) { package { 'libmysqlclient-dev': ensure => present; } }
        }
        'pgsql': {
          if !defined(Package['libpq-dev']) { package { 'libpq-dev': ensure => present; } }
          if !defined(Package['postgresql-client']) { package { 'postgresql-client': ensure => present; } }
        }
      }

      if !defined(Package['libv8-dev']) { package { 'libv8-dev': ensure => present; } }
      if !defined(Package['zlib1g-dev']) { package { 'zlib1g-dev': ensure => present; } }
      if !defined(Package['libyaml-dev']) { package { 'libyaml-dev': ensure => present; } }
      if !defined(Package['libssl-dev']) { package { 'libssl-dev': ensure => present; } }
      if !defined(Package['libgdbm-dev']) { package { 'libgdbm-dev': ensure => present; } }
      if !defined(Package['libreadline-dev']) { package { 'libreadline-dev': ensure => present; } }
      if !defined(Package['libncurses5-dev']) { package { 'libncurses5-dev': ensure => present; } }
      if !defined(Package['libffi-dev']) { package { 'libffi-dev': ensure => present; } }
      if !defined(Package['checkinstall']) { package { 'checkinstall': ensure => present; } }
      if !defined(Package['libxml2-dev']) { package { 'libxml2-dev': ensure => present; } }
      if !defined(Package['libxslt1-dev']) { package { 'libxslt1-dev': ensure => present; } }
      if !defined(Package['libcurl4-openssl-dev']) { package { 'libcurl4-openssl-dev': ensure => present; } }
      if !defined(Package['libicu-dev']) { package { 'libicu-dev': ensure => present; } }
      if !defined(Package['python2.7']) { package { 'python2.7': ensure => present; } }
      if !defined(Package['python-dev']) { package { 'python-dev': ensure => present; } }
      if !defined(Package['build-essential']) { package { 'build-essential': ensure => present; } }
      if !defined(Package['git-core']) { package { 'git-core': ensure => present; } }
      if !defined(Package['postfix']) { package { 'postfix': ensure => present; } }

      file {
        '/usr/bin/python2':
          ensure => link,
          target => '/usr/bin/python',
          require => Package['python2.7']
      }
    } # Debian pre-requists
    'Redhat': {
      case $gitlab_dbtype {
        'mysql': {
          if !defined(Package['mysql-devel']) { package { 'mysql-devel': ensure => present; } }
        }
        'pgsql': {
          if !defined(Package['postgresql-devel']) { package { 'postgresql-devel': ensure => present; } }
        }
      }

      if !defined(Package['perl-Time-HiRes']) { package { 'perl-Time-HiRes': ensure => present; } }
      if !defined(Package['libicu-devel']) { package { 'libicu-devel': ensure => present; } }
      if !defined(Package['libxml2-devel']) { package { 'libxml2-devel': ensure => present; } }
      if !defined(Package['libxslt-devel']) { package { 'libxslt-devel': ensure => present; } }
      if !defined(Package['python-devel']) { package { 'python-devel': ensure => present; } }
      if !defined(Package['libcurl-devel']) { package { 'libcurl-devel': ensure => present; } }
      if !defined(Package['readline-devel']) { package { 'readline-devel': ensure => present; } }
      if !defined(Package['openssl-devel']) { package { 'openssl-devel': ensure => present; } }
      if !defined(Package['zlib-devel']) { package { 'zlib-devel': ensure => present; } }
      if !defined(Package['libyaml-devel']) { package { 'libyaml-devel': ensure => present; } }
    } # Redhat pre-requists
    default: {
      err "${::osfamily} not supported yet"
    }
  }

  if !defined(Package['openssh-server']) {
    package { 'openssh-server': ensure => present; }
  }
  if !defined(Package['git']) {
    package { 'git': ensure => present; }
  }
  if !defined(Package['curl']) {
    package { 'curl': ensure => present; }
  }
} # Class:: gitlab::dependencies
