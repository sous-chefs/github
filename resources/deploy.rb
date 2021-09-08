unified_mode true

default_action :deploy

property :repo, String, name_property: true
property :version, String, required: true
property :github_user, String
property :github_token, String
property :host, String
property :path, String, required: true
property :owner, String
property :group, String
property :shared_directories, Array, default: %w(pids log)
property :force, [true, false], default: false

property :configure, Proc
property :before_migrate, Proc
property :after_migrate, Proc
property :migrate, Proc

action_class do
  def deploy_path
    ::File.join(release_path, new_resource.version)
  end

  def release_path
    ::File.join(new_resource.path, 'releases')
  end

  def shared_path
    ::File.join(new_resource.path, 'shared')
  end

  def current_path
    ::File.join(new_resource.path, 'current')
  end
end

action :deploy do
  [ release_path, shared_path ].each do |path|
    directory path do
      owner     new_resource.owner
      group     new_resource.group
      mode      '770'
      recursive true
    end
  end

  new_resource.shared_directories.each do |path|
    directory "#{shared_path}/#{path}" do
      owner     new_resource.owner
      group     new_resource.group
      mode      '770'
      recursive true
    end
  end

  github_archive new_resource.repo do
    should_force = new_resource.version == 'master' || new_resource.force

    version      new_resource.version
    github_user  new_resource.github_user
    github_token new_resource.github_token
    host         new_resource.host
    extract_to   deploy_path
    force        should_force

    if should_force
      action [ :delete, :extract ]
    else
      action :extract
    end
    notifies :run, 'ruby_block[configure]'
    notifies :run, 'ruby_block[before-migrate]'
    notifies :run, 'ruby_block[migrate]'
    notifies :run, 'ruby_block[after-migrate]'
  end

  ruby_block 'configure' do
    block do
      if new_resource.configure
        Chef::Log.info "github_deploy[#{new_resource.name}] Running configure proc"
        recipe_eval(&new_resource.configure.to_proc)
      end
    end
    action :nothing
  end

  ruby_block 'before-migrate' do
    block do
      if new_resource.before_migrate
        Chef::Log.info "github_deploy[#{new_resource.name}] Running before migrate proc"
        recipe_eval(&new_resource.before_migrate.to_proc)
      end
    end
    action :nothing
  end

  ruby_block 'migrate' do
    block do
      if new_resource.migrate
        Chef::Log.info "github_deploy[#{new_resource.name}] Running migrate proc"
        recipe_eval(&new_resource.migrate.to_proc)
      end
    end
    action :nothing
  end

  ruby_block 'after-migrate' do
    block do
      if new_resource.after_migrate
        Chef::Log.info "github_deploy[#{new_resource.name}] Running after migrate proc"
        recipe_eval(&new_resource.after_migrate.to_proc)
      end
    end
    action :nothing
  end

  link current_path do
    to    deploy_path
    owner new_resource.owner
    group new_resource.group
  end
end
