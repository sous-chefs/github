#
# Cookbook Name:: github
# Resource:: archive
#
# Author:: Jamie Winsor (<jamie@vialstudios.com>)
# Contributor:: John Manero (<john_manero@rapid7.com>)
#

actions :download, :extract, :delete
default_action [:download, :extract]

attribute :name, kind_of: String, name_attribute: true, required: true
attribute :version, kind_of: String, default: 'master'
attribute :github_user, kind_of: String
attribute :github_token, kind_of: String
attribute :host, kind_of: String, default: 'https://api.github.com'
attribute :extract_to, kind_of: [String, FalseClass], default: false
attribute :force, kind_of: [TrueClass, FalseClass], default: false

attr_reader :organization
attr_reader :repo

require 'net/http'
require 'uri'
require 'fileutils'

def cache_path
  ::File.join(Chef::Config[:file_cache_path], 'github/archives')
end

def archive_path
  ::File.join(cache_path, "#{ organization }-#{ repo }-#{ version }.tar.gz")
end

def archive_url
  Octokit.archive_link(name, ref: version)
rescue Octokit::ClientError => e
  case e
  when Octokit::NotAcceptable
    raise GithubCB::AuthenticationError
  when Octokit::NotFound
    raise GithubCB::AssetNotFound
  else
    raise e
  end
end

def initialize(name, run_context)
  super(name, run_context)
  @organization, @repo = name.split('/')
end

def authenticate
  require 'octokit'
  Octokit.configure do |c|
    c.login        = github_user
    c.access_token = github_token
  end
end

def download
  FileUtils.rm_rf(options[:path]) if force
  FileUtils.mkdir_p(::File.dirname(archive_path))
  archive_fh = ::File.open(archive_path, 'wb')

  open(archive_url) { |source| IO.copy_stream(source, archive_fh) }
rescue Octokit::ClientError => e
  case e
  when Octokit::NotAcceptable
    raise GithubCB::AuthenticationError
  when Octokit::NotFound
    raise GithubCB::AssetNotFound
  else
    raise e
  end
ensure
  archive_fh.close unless archive_fh.nil?
end

def extract
  require 'archive'
  FileUtils.rm_rf(extract_to) if force

  Dir.mktmpdir do |tmpdir|
    Dir.chdir(tmpdir) do
      ::Archive.new(archive_path).extract
      ::File.rename(Dir.glob("#{ tmpdir }/**").first, extract_to)
    end
  end
rescue => e
  FileUtils.rm_rf(extract_to) if ::File.exists?(extract_to)
  raise e
end

def downloaded?
  ::File.exists?(archive_path)
end

def extracted?
  ::File.exist?(extract_to)
end
