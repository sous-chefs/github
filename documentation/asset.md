[Back to resource list](../README.md#resources)

# github_asset

Downloads an asset from a Github repository

## Actions

| Action      | Description                                              |
| ----------- | -------------------------------------------------------- |
| `:download` | Downloads an asset from a Github repository              |
| `:extract`  | Downloads and extracts an asset from a Github repository |
| `:delete`   | Deletes a local asset from a Github repository           |

## Properties

| Name           | Type            | Default       | Description                              |
| -------------- | --------------- | ------------- | ---------------------------------------- |
| `file`         | String          | Resource name | File name of the asset                   |
| `release`      | String          |               | Release name of the asset (required)     |
| `repo`         | String          |               | Repository org and name                  |
| `github_user`  | String          |               | Github user for authentication           |
| `github_token` | String          |               | Github token for authentication          |
| `owner`        | String          |               | Owner for extracted archive              |
| `group`        | String          |               | Group for extracted archive              |
| `force`        | `true`, `false` | `false`       | Force downloading and extracting archive |
| `extract_to`   | String          |               | Path to extract asset to                 |

## Examples

```ruby
github_asset 'Precompiled.zip' do
  repo 'elixir-lang/elixir'
  release 'v1.12.2'
end

github_asset 'Precompiled.zip' do
  repo 'elixir-lang/elixir'
  release 'v1.12.2'
  action :delete
end

github_asset 'Precompiled.zip' do
  repo 'elixir-lang/elixir'
  release 'v1.12.2'
  extract_to '/opt/elixir'
  action :extract
end
```
