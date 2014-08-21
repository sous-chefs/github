# github-cookbook

A Library Cookbook for interacting with the Github API

## Supported Platforms

* Ubuntu

## github_asset Resource/Provider

Downloads an asset from a Github release. This resource *only* downloads the file (does not copy it), and its information (including the path to the downloaded file) is returned.

It is up to you to provide commands that make use of the file. See example below.

### Actions

- **download** - downloads the asset from the Github release to disk. (default)

### Parameter Attributes

- **name** - name of the asset to download (name attribute)
- **release** - name of the release the asset is a part of (the git tag of the release)
- **repo** - repository the release is a part of (required for private repositories)
- **github_token** - Github token to perform the download with (required for private repositories)
- **owner** - owner of the downloaded asset on disk
- **group** - group of the downloaded asset on disk
- **force** - force downloading even if the asset already exists on disk

## Example

```ruby
asset = github_asset "berkshelf-api.tar.gz" do
  repo "berkshelf/berkshelf-api"
  release "v1.2.1"
end

execute "Copy #{asset.asset_path} to output folder" do
  command "cp #{asset.asset_path} #{node["myapp"]["outputfolder"]}"
end

```

## HTTP proxy support

Ensure the `HTTPS_PROXY` environment variable is set for the shell executing `chef-client` or `chef-solo`. The value should be a fully qualified URL containing the host, port, username, and password for your proxy.

# Author

Author:: Jamie Winsor (<jamie@vialstudios.com>)
