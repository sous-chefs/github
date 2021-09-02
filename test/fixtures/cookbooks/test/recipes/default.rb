#github_asset 'Precompiled.zip' do
#  repo 'elixir-lang/elixir'
#  release 'v1.12.2'
#end

github_archive 'elixir-lang/elixir' do
  extract_to '/tmp/test'
  force true
end
