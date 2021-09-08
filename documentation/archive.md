[Back to resource list](../README.md#resources)

# github_archive

Downloads and extracts an archive from a Github repository

## Actions

| Action     | Description                                                |
| ---------- | ---------------------------------------------------------- |
| `:extract` | Downloads and extracts an archive from a Github repository |
| `:delete`  | Deletes an extracted archive from a Github repository      |

## Properties

| Name           | Type            | Default              | Description                              |
| -------------- | --------------- | -------------------- | ---------------------------------------- |
| `repo`         | String          | Resource name        | Repository org and name                  |
| `version`      | String          | `master`             | Git ref (branch, tag, etc)               |
| `github_user`  | String          |                      | Github user for authentication           |
| `github_token` | String          |                      | Github token for authentication          |
| `host`         | String          | `https://github.com` | Github endpoint host                     |
| `owner`        | String          |                      | Owner for extracted archive              |
| `group`        | String          |                      | Group for extracted archive              |
| `extract_to`   | String          |                      | Path to extract archive to (required)    |
| `force`        | `true`, `false` | `false`              | Force downloading and extracting archive |

## Examples

```ruby
github_archive 'elixir-lang/elixir' do
  extract_to '/tmp/test'
end

github_archive 'elixir-lang/elixir' do
  extract_to '/tmp/test'
  action :delete
end
```
