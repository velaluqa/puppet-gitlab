class gitlab::config {
  include gitlab

  $gitlab_dbtype      = $gitlab::gitlab_dbtype
  $gitlab_dbname      = $gitlab::gitlab_dbname
  $gitlab_dbuser      = $gitlab::gitlab_dbuser
  $gitlab_dbpwd       = $gitlab::gitlab_dbpwd
  $gitlab_dbhost      = $gitlab::gitlab_dbhost
  $gitlab_dbport      = $gitlab::gitlab_dbport
  $gitlab_domain      = $gitlab::gitlab_domain
  $gitlab_repodir     = $gitlab::gitlab_repodir
  $gitlab_branch      = $gitlab::gitlab_branch
  $gitlab_sources     = $gitlab::gitlab_sources
  $git_home           = $gitlab::git_home
  $git_user           = $gitlab::git_user
  $git_email          = $gitlab::git_email
  $ldap_enabled       = $gitlab::ldap_enabled
  $ldap_host          = $gitlab::ldap_host
  $ldap_base          = $gitlab::ldap_base
  $ldap_uid           = $gitlab::ldap_uid
  $ldap_port          = $gitlab::ldap_port
  $ldap_method        = $gitlab::ldap_method
  $ldap_bind_dn       = $gitlab::ldap_bind_dn
  $ldap_bind_password = $gitlab::ldap_bind_password

  file { "${git_home}/gitlab/config/database.yml":
    content => template("gitlab/database.yml.erb"),
    owner => $git_user,
    group => $git_user,
  }

  # We do not use the `gitlab:setup` task because we want to update easily.
  # The database is created by the postgres/mysql puppet modules.
  exec { "gitlab-migrate":
    path => "/bin:/usr/bin",
    unless => "bash -c 'cd ${git_home}/gitlab; RAILS_ENV=production bundle exec rake db:abort_if_pending_migrations'",
    command => "bash -c 'cd ${git_home}/gitlab; RAILS_ENV=production bundle exec rake db:migrate'",
    require => File["${git_home}/gitlab/config/database.yml"],
    notify => Service["gitlab"],
    user => $git_user,
    group => $git_user,
    timeout => 600,
  }

  exec { "gitlab-seed":
    path => "/bin:/usr/bin",
    command => "echo",
    onlyif => "bash -c 'cd ${git_home}/gitlab; bundle exec rake db:seed_fu RAILS_ENV=production | grep -q \": migrating\"'",
    require => Exec["gitlab-migrate"],
    creates => "${git_home}/.gitlab_setup_done",
    unless   => "/usr/bin/test -f ${git_home}/.gitlab_setup_done",
    user => $git_user,
    group => $git_user,
    timeout => 600,
  }

  file { "${git_home}/gitlab/config/unicorn.rb":
    content => template("gitlab/unicorn.rb.erb"),
    owner => $git_user,
    group => $git_user,
  }

  file { "${git_home}/gitlab/config/gitlab.yml":
    content => template("gitlab/gitlab.yml.erb"),
    owner => $git_user,
    group => $git_user,
  }

  file { "/etc/init.d/gitlab":
    ensure => link,
    target => "${git_home}/gitlab/lib/support/init.d/gitlab",
    owner => "root",
    group => "root",
    mode => 0755,
  }

  file { "${git_home}/.gitconfig":
    content => template('gitlab/git.gitconfig.erb'),
    mode    => '0644',
    owner => $git_user,
    group => $git_user,
  }

  file { [ "${git_home}/gitlab-satellites",
           "${git_home}/gitlab/log",
           "${git_home}/gitlab/tmp" ]:
    ensure => "directory",
    owner => $git_user,
    group => $git_user,
    mode => 0755,
  }

  file { ["${git_home}/gitlab/tmp/pids","${git_home}/gitlab/tmp/sockets"]:
    ensure => "directory",
    owner => $git_user,
    group => $git_user,
    mode => 0755,
    require => File["${git_home}/gitlab/tmp"],
  }
}
