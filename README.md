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

# Author

Author:: Jamie Winsor (<jamie@vialstudios.com>)
