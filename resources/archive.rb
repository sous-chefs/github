unified_mode true

default_action :extract

property :repo, kind_of: String, name_property: true
property :version, kind_of: String, default: 'master'
property :github_user, kind_of: String
property :github_token, kind_of: String
property :host, kind_of: String
property :owner, kind_of: String
property :group, kind_of: String
property :extract_to, kind_of: String, required: true
property :force, kind_of: [TrueClass, FalseClass], default: false

action :extract do
  unless new_resource.force || archive.downloaded?
    converge_by "downloading archive #{new_resource.name} to #{archive.path}" do
      archive.download(
        user: new_resource.github_user,
        token: new_resource.github_token,
        force: new_resource.force
      )
    end
  end

  unless new_resource.force || ::File.exist?(new_resource.extract_to)
    converge_by "extracting archive #{archive.path} to #{new_resource.extract_to}" do
      archive_file archive.path do
        destination new_resource.extract_to
        overwrite new_resource.force
        owner new_resource.owner
        group new_resource.group
      end
    end
  end
end

action :delete do
  file archive.path do
    action :delete
  end

  directory new_resource.extract_to do
    recursive true
    action :delete
  end
end

action_class do
  def archive
    GithubCB::Archive.new(new_resource.repo, version: new_resource.version, host: new_resource.host)
  end
end
