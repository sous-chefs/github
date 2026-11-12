require 'octokit'
require_relative '../../libraries/github_asset'

RSpec.describe GithubCB::Asset do
  subject(:asset) { described_class.new(repository, release: 'v1.2.3', name: 'example.zip') }

  let(:repository) { 'example/project' }
  let(:configuration) { Struct.new(:login, :access_token).new }
  let(:download_url) { 'https://api.github.com/repos/example/project/releases/assets/123' }
  let(:release_asset) { double('release asset', name: 'example.zip', rels: { self: double(href: download_url) }) }
  let(:assets_response) { double(data: [release_asset]) }
  let(:release) { double('release', tag_name: 'v1.2.3', rels: { assets: double(get: assets_response) }) }
  let(:other_release) { double('other release', tag_name: 'v2.0.0') }

  before do
    allow(Octokit).to receive(:configure).and_yield(configuration)
  end

  it 'returns a matching first-page asset without requesting more pages' do
    expect(Octokit).to receive(:releases).with(repository, per_page: 100, page: 1).once.and_return([release])

    expect(asset.asset_url(user: 'example-user', token: 'example-token')).to eq(download_url)
    expect(configuration.login).to eq('example-user')
    expect(configuration.access_token).to eq('example-token')
  end

  it 'finds an older release on a later page' do
    expect(Octokit).to receive(:releases).with(repository, per_page: 100, page: 1).ordered.and_return([other_release])
    expect(Octokit).to receive(:releases).with(repository, per_page: 100, page: 2).ordered.and_return([release])

    expect(asset.asset_url({})).to eq(download_url)
  end

  it 'raises ReleaseNotFound after reaching an empty page' do
    expect(Octokit).to receive(:releases).with(repository, per_page: 100, page: 1).ordered.and_return([other_release])
    expect(Octokit).to receive(:releases).with(repository, per_page: 100, page: 2).ordered.and_return([])

    expect { asset.asset_url({}) }.to raise_error(GithubCB::ReleaseNotFound, 'release not found')
  end

  it 'raises AssetNotFound when the matching release has no matching asset' do
    allow(Octokit).to receive(:releases).and_return([release])
    allow(assets_response).to receive(:data).and_return([])

    expect { asset.asset_url({}) }.to raise_error(GithubCB::AssetNotFound, 'asset not found')
  end

  it 'propagates errors from a later release page' do
    expect(Octokit).to receive(:releases).with(repository, per_page: 100, page: 1).ordered.and_return([other_release])
    expect(Octokit).to receive(:releases).with(repository, per_page: 100, page: 2).ordered.and_raise(Octokit::Unauthorized)

    expect { asset.asset_url({}) }.to raise_error(Octokit::Unauthorized)
  end

  it 'does not discard an authenticated draft or prerelease returned by the API' do
    allow(release).to receive_messages(draft: true, prerelease: true)
    allow(Octokit).to receive(:releases).and_return([release])

    expect(asset.asset_url(user: 'example-user', token: 'example-token')).to eq(download_url)
  end
end
