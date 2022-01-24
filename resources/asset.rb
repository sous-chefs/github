unified_mode true

default_action :download

property :file, String, name_property: true
property :release, String, required: true
property :repo, String, required: true
property :github_user, String
property :github_token, String
property :owner, String
property :group, String
property :force, [true, false], default: false
property :extract_to, String, required: [:extract]

action :download do
  do_download
end

action :extract do
  do_download

  unless new_resource.force || ::File.exist?(new_resource.extract_to)
    converge_by "extracting #{new_resource.file} to #{new_resource.extract_to}" do
      archive_file asset_path do
        destination new_resource.extract_to
        overwrite new_resource.force
        owner new_resource.owner
        group new_resource.group
      end
    end
  end
end

action :delete do
  file asset_path do
    action :delete
  end

  directory ::File.dirname(asset_path) do
    recursive true
    action :delete
  end
end

action_class do
  def do_download
    chef_gem 'octokit' do
      compile_time true
    end

    unless asset.downloaded?(asset_path)
      converge_by "downloading #{new_resource.file} to #{asset_path}" do
        asset.download(
          user: new_resource.github_user,
          token: new_resource.github_token,
          force: new_resource.force,
          path: asset_path
        )
      end
    end
  end

  def asset
    GithubCB::Asset.new(new_resource.repo, name: new_resource.file, release: new_resource.release)
  end

  def asset_path
    GithubCB::Asset.asset_path(new_resource.repo, new_resource.release, new_resource.file)
  end
end
