#
# Cookbook Name:: github
# Library:: github_asset
#
# Author:: Jamie Winsor (<jamie@vialstudios.com>)
#

require 'net/http'
require 'open-uri'
require 'uri'
require 'fileutils'
require_relative 'github_errors'

module GithubCB
  class Asset
    class << self
      def asset_cache
        ::File.join(Chef::Config[:file_cache_path], "github_assets")
      end

      def asset_path(fqrn, tag, name)
        ::File.join(asset_cache, fqrn, tag, name)
      end
    end

    DEFAULT_HOST = "https://github.com".freeze

    attr_reader :fqrn
    attr_reader :organization
    attr_reader :repo
    attr_reader :tag_name
    attr_reader :name
    attr_reader :host

    def initialize(fqrn, options = {})
      @fqrn                = fqrn
      @organization, @repo = fqrn.split('/')
      @tag_name            = options[:release]
      @name                = options[:name]
      @host                = options[:host] ||= DEFAULT_HOST
    end

    def asset_url(options)
      require 'octokit'

      Octokit.configure do |c|
        c.login        = options[:user]
        c.access_token = options[:token]
      end

      release = Octokit.releases(fqrn).find do |release|
        release.tag_name == tag_name
      end

      raise GithubCB::ReleaseNotFound, "release not found" if release.nil?

      asset = release.rels[:assets].get.data.find do |asset|
        asset.name == name
      end

      raise GithubCB::AssetNotFound, "asset not found" if asset.nil?

      asset.rels[:self].href
    end

    # @option options [String] :path
    # @option options [String] :user
    # @option options [String] :token
    # @option options [Boolean] :force
    def download(options = {})
      if options[:force]
        FileUtils.rm_rf(options[:path])
      end

      return false if downloaded?(options[:path])

      uri = URI(asset_url(options))
      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        req                  = Net::HTTP::Get.new(uri.to_s)
        req['Authorization'] = "token #{options[:token]}" unless options[:token].nil?
        req['Accept']        = "application/octet-stream"

        http.request(req)
      end

      FileUtils.mkdir_p(::File.dirname(options[:path]))
      file = ::File.open(options[:path], "wb")

      open(res['location']) { |source| IO.copy_stream(source, file) }
      true
    rescue OpenURI::HTTPError => ex
      case ex.message
      when /406 Not Acceptable/
        raise GithubCB::AuthenticationError
      else
        raise ex
      end
    ensure
      file.close unless file.nil?
    end

    def downloaded?(path)
      ::File.exist?(path)
    end
  end
end
