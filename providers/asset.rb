#
# Cookbook Name:: github
# Provider:: asset
#
# Author:: Jamie Winsor (<jamie@vialstudios.com>)
#

use_inline_resources

attr_reader :asset

def load_current_resource
  @asset = GithubCB::Asset.new(new_resource.repo, name: new_resource.name,
    release: new_resource.release)
end

action :download do
  chef_gem "octokit"

  Chef::Log.info "github_asset[#{new_resource.name}] downloading asset"
  updated = asset.download(user: new_resource.github_user, token: new_resource.github_token,
    force: new_resource.force, path: new_resource.asset_path)
  new_resource.updated_by_last_action(updated)
end

action :delete do
  file @asset.asset_path do
    action :delete
  end

  directory new_resource.extract_to do
    recursive true
    action :delete
  end
end
