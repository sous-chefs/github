github_asset 'Precompiled.zip' do
  repo 'elixir-lang/elixir'
  release 'v1.12.2'
end

github_asset 'Precompiled.zip-delete' do
  file 'Precompiled.zip'
  repo 'elixir-lang/elixir'
  release 'v1.12.1'
  action :delete
end

github_asset 'Precompiled.zip-extract' do
  file 'Precompiled.zip'
  repo 'elixir-lang/elixir'
  release 'v1.13.0'
  extract_to '/tmp/extract'
  action :extract
end

github_archive 'elixir-lang/elixir' do
  extract_to '/tmp/test'
end

github_archive 'elixir-lang/elixir-delete' do
  repo 'elixir-lang/elixir'
  version 'delete'
  extract_to '/tmp/delete'
  action :delete
end

github_deploy 'elixir-lang/elixir' do
  version 'v1.12'
  path '/tmp/deploy'
end
