# frozen_string_literal: true

require 'spec_helper'
require 'octokit'
require_relative '../../libraries/github_asset'

RSpec.describe GithubCB::Asset do
  subject(:asset) { described_class.new(repository, release: 'v1.2.3', name: 'example.zip') }

  let(:repository) { 'example/project' }
  let(:client) { instance_double(Octokit::Client) }
  let(:download_url) { 'https://api.github.com/repos/example/project/releases/assets/123' }
  let(:release_asset) { double('release asset', name: 'example.zip', rels: { self: double(href: download_url) }) }
  let(:assets_response) { double(data: [release_asset]) }
  let(:release) { double('release', tag_name: 'v1.2.3', rels: { assets: double(get: assets_response) }) }
  let(:other_release) { double('other release', tag_name: 'v2.0.0') }

  before do
    allow(Octokit::Client).to receive(:new).and_return(client)
  end

  it 'returns a matching first-page asset without requesting more pages' do
    expect(Octokit::Client).to receive(:new).with(hash_including(login: 'example-user', access_token: 'example-token')).and_return(client)
    expect(client).to receive(:releases).with(repository, per_page: 100, page: 1).once.and_return([release])

    expect(asset.asset_url(user: 'example-user', token: 'example-token')).to eq(download_url)
  end

  it 'uses JSON when the embedded Sawyer default cannot provide a serializer' do
    allow(Sawyer::Serializer).to receive(:any_json).and_raise(NameError, 'Yajl does not implement dump')
    allow(Octokit).to receive(:instance_variable_get).and_call_original
    allow(Octokit).to receive(:instance_variable_get).with(:@login).and_return('other-user')
    allow(Octokit).to receive(:instance_variable_get).with(:@access_token).and_return('other-token')
    allow(Octokit::Client).to receive(:new).and_wrap_original do |constructor, options|
      real_client = constructor.call(options)
      allow(real_client).to receive(:releases) do
        expect(real_client.login).to be_falsey
        expect(real_client.access_token).to be_falsey
        expect(real_client.agent.decode_body('{"version":"v1.2.3"}')).to eq(version: 'v1.2.3')
        [release]
      end
      real_client
    end

    expect(asset.asset_url({})).to eq(download_url)
  end

  it 'finds an older release on a later page' do
    expect(client).to receive(:releases).with(repository, per_page: 100, page: 1).ordered.and_return([other_release])
    expect(client).to receive(:releases).with(repository, per_page: 100, page: 2).ordered.and_return([release])

    expect(asset.asset_url({})).to eq(download_url)
  end

  it 'raises ReleaseNotFound after reaching an empty page' do
    expect(client).to receive(:releases).with(repository, per_page: 100, page: 1).ordered.and_return([other_release])
    expect(client).to receive(:releases).with(repository, per_page: 100, page: 2).ordered.and_return([])

    expect { asset.asset_url({}) }.to raise_error(GithubCB::ReleaseNotFound, 'release not found')
  end

  it 'raises AssetNotFound when the matching release has no matching asset' do
    allow(client).to receive(:releases).and_return([release])
    allow(assets_response).to receive(:data).and_return([])

    expect { asset.asset_url({}) }.to raise_error(GithubCB::AssetNotFound, 'asset not found')
  end

  it 'propagates errors from a later release page' do
    expect(client).to receive(:releases).with(repository, per_page: 100, page: 1).ordered.and_return([other_release])
    expect(client).to receive(:releases).with(repository, per_page: 100, page: 2).ordered.and_raise(Octokit::Unauthorized)

    expect { asset.asset_url({}) }.to raise_error(Octokit::Unauthorized)
  end

  it 'does not discard an authenticated draft or prerelease returned by the API' do
    allow(release).to receive_messages(draft: true, prerelease: true)
    allow(client).to receive(:releases).and_return([release])

    expect(asset.asset_url(user: 'example-user', token: 'example-token')).to eq(download_url)
  end
end
