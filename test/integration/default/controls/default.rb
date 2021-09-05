cache_dir = inspec.file('/opt/kitchen').exist? ? '/opt/kitchen/cache' : '/tmp/kitchen/cache'

control 'github-cookbook' do
  [
    "#{cache_dir}/github_assets/elixir-lang/elixir/v1.12.2/Precompiled.zip",
    "#{cache_dir}/github_deploy/archives/elixir-master.tar.gz",
    "#{cache_dir}/github_deploy/archives/elixir-v1.12.tar.gz",
    '/tmp/test/elixir-master/README.md',
    '/tmp/deploy/releases/v1.12/elixir-1.12/README.md',
  ].each do |f|
    describe file f do
      it { should exist }
      its('size') { should > 0 }
    end
  end

  [
    "#{cache_dir}/github_assets/elixir-lang/elixir/v1.12.1/Precompiled.zip",
    "#{cache_dir}/github_deploy/archives/elixir-delete.tar.gz",
  ].each do |f|
    describe file f do
      it { should_not exist }
    end
  end

  %w(
    /tmp/test
    /tmp/deploy/releases/v1.12
  ).each do |d|
    describe directory d do
      it { should exist }
    end
  end

  describe directory '/tmp/delete' do
    it { should_not exist }
  end

  %w(
    /tmp/deploy/releases
    /tmp/deploy/shared
    /tmp/deploy/shared/pids
    /tmp/deploy/shared/log
  ).each do |d|
    describe directory d do
      it { should exist }
      its('mode') { should cmp '0770' }
    end
  end

  describe file '/tmp/deploy/current' do
    its('link_path') { should eq '/tmp/deploy/releases/v1.12' }
  end
end
