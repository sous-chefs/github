[Back to resource list](../README.md#resources)

# github_deploy

Downloads an asset from a Github repository and then deploys it as an application

## Actions

| Action    | Description                                                     |
| --------- | --------------------------------------------------------------- |
| `:deploy` | Downloads an asset from a Github repository and then deploys it |

## Properties

| Name                 | Type            | Default              | Description                                 |
| -------------------- | --------------- | -------------------- | ------------------------------------------- |
| `repo`               | String          | Resource name        | Repository org and name                     |
| `version`            | String          |                      | Git ref (branch, tag, etc) (required)       |
| `github_user`        | String          |                      | Github user for authentication              |
| `github_token`       | String          |                      | Github token for authentication             |
| `host`               | String          | `https://github.com` | Github endpoint host                        |
| `path`               | String          |                      | Path to deploy the application              |
| `owner`              | String          |                      | Owner for extracted archive                 |
| `group`              | String          |                      | Group for extracted archive                 |
| `shared_directories` | Array           | `['pids', 'logs']`   | Shared directories to create an symlink     |
| `configure`          | Proc            |                      | Block of code to run in a configure phase   |
| `before_migrate`     | Proc            |                      | Block of code to run before migration phase |
| `after_migrate`      | Proc            |                      | Block of code to run after migration phase  |
| `migrate`            | Proc            |                      | Block of code to run during migration phase |
| `force`              | `true`, `false` | `false`              | Force downloading and extracting archive    |

## Examples

```ruby
github_deploy 'elixir-lang/elixir' do
  version 'v1.12'
  path '/tmp/deploy'
end
```
