# github-cookbook

A Library Cookbook for interacting with the Github API

## Supported Platforms

* Ubuntu

## github_asset Resource/Provider

Downloads an asset from a Github release

### Actions

- **download** - downloads the asset from the Github releaseto disk. (default)

### Parameter Attributes

- **name** - name of the asset to download (name attribute)
- **release** - name of the release the asset is a part of
- **repo** - repository the release is a part of (required for private repositories)
- **github_token** - Github token to perform the download with (required for private repositories)
- **owner** - owner of the downloaded asset on disk
- **group** - group of the downloaded asset on disk
- **force** - force downloading even if the asset already exists on disk

## github_archive LWRP
Downloads and extracts a tarball of a specified `ref`

### Actions

- **download** - downloads a tarball into the chef file-cache
- **extract** - extracts the downloaded tarball and strips the redundant root directory

### Parameter Attributes

- **name** - fully qualified repository name (`org/repo`)
- **version** - git ref/tag/HEAD to fetch. Default `master`
- **github_user** - GitHub user
- **github_token** - GitHub API token
- **host** - GitHub:Enterprise endpoint. Default `https://api.github.com`
- **extract_to** - target location for extracted source
- **force** - override idempotent existance checks

## HTTP proxy support

Ensure the `HTTPS_PROXY` environment variable is set for the shell executing `chef-client` or `chef-solo`. The value should be a fully qualified URL containing the host, port, username, and password for your proxy.

# Author

Author:: Jamie Winsor (<jamie@vialstudios.com>)

# Contributors
- John Manero (john_manero@rapid7.com)
