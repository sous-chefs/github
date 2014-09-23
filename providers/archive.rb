#
# Cookbook Name:: github
# Provider:: archive
#
# Author:: Jamie Winsor (<jamie@vialstudios.com>)
# Contributor:: John Manero (<john_manero@rapid7.com>)
#

use_inline_resources

action :download do
  chef_gem 'octokit'
  new_resource.authenticate

  Chef::Log.info "Download github_archive[#{ new_resource.name }] version "\
    "#{ new_resource.version }"

  if !new_resource.downloaded? || new_resource.force
    Chef::Log.info("github_archive[#{ new_resource.name }] "\
      "downloading archive")

    new_resource.download
    new_resource.updated_by_last_action(true)
  end
end

action :extract do
  Chef::Log.info "Extracting github_archive[#{ new_resource.name }]"

  if !new_resource.extracted? || new_resource.force
    Chef::Log.info("github_archive[#{ new_resource.name }] "\
      "extracting archive")

    new_resource.extract
    new_resource.updated_by_last_action(true)
  end
end

action :delete do
  file new_resource.asset_path do
    action :delete
  end
end
