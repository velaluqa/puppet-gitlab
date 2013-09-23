class gitlab::checkout {

  include gitlab

  $git_user         = $gitlab::git_user
  $git_home         = $gitlab::git_home
  $gitlab_dbtype    = $gitlab::gitlab_dbtype
  $gitlab_branch    = $gitlab::gitlab_branch
  $gitlab_domain    = $gitlab::gitlab_domain
  $gitlab_repodir   = $gitlab::gitlab_repodir
  $rvm_ruby         = $gitlab::rvm_ruby

  if $rvm_ruby != '' {
    $rvm_prefix     = "source /usr/local/rvm/scripts/rvm; rvm use ${rvm_ruby}; "
  } else {
    $rvm_prefix     = ''
  }

  $without_gems = $gitlab_dbtype ? {
    mysql => "development test postgres",
    pgsql => "development test mysql"
  }

  exec { "gitlab-checkout":
    path => "/bin:/usr/bin",
    creates => "${git_home}/gitlab",
    command => "git clone ${gitlab_sources} ${git_home}/gitlab",
    require => [ File[$git_home] ],
    user => $git_user,
    group => $git_user
  }

  exec { "gitlab-update":
    path => "/bin:/usr/bin",
    command => "bash -c 'cd ${git_home}/gitlab; git fetch'",
    require => Exec["gitlab-checkout"],
    user => $git_user,
    group => $git_user
  }

  exec { "gitlab-upgrade":
    path => "/bin:/usr/bin",
    onlyif => "bash -c 'cd ${git_home}/gitlab; git diff HEAD..origin/${gitlab_branch} | grep -q ^---'",
    command => "bash -c 'cd ${git_home}/gitlab; git checkout db/schema.rb; git checkout origin/${gitlab_branch}'",
    require => Exec["gitlab-update"],
    user => $git_user,
    group => $git_user
  }

  exec { "gitlab-bundle":
    path => "/bin:/usr/bin",
    command => "bash -c '${rvm_prefix}cd ${git_home}/gitlab; bundle install --deployment --without ${without_gems}'",
    unless => "bash -c '${rvm_prefix}cd ${git_home}/gitlab; bundle check --path=vendor/bundle'",
    require => Exec["gitlab-upgrade"],
    notify => Service["gitlab"],
    user => $git_user,
    group => $git_user,
    timeout => 600,
  }
}
