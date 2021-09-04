require 'open-uri'
require 'uri'
require 'fileutils'
require_relative 'github_errors'

module GithubCB
  class Archive
    class << self
      def default_host
        @default_host ||= 'https://github.com'
      end
    end

    attr_reader :fqrn
    attr_reader :organization
    attr_reader :repo
    attr_reader :version
    attr_reader :host

    def initialize(fqrn, options = {})
      @fqrn                = fqrn
      @organization, @repo = fqrn.split('/')
      @version             = options[:version] ||= 'master'
      @host                = options[:host] ||= self.class.default_host
    end

    # @option options [String] :user
    # @option options [String] :token
    # @option options [Boolean] :force
    def download(options = {})
      if options[:force]
        FileUtils.rm_rf(local_archive_path)
      end

      FileUtils.mkdir_p(File.dirname(local_archive_path))
      file = ::File.open(local_archive_path, 'wb')

      URI.open(download_uri, http_basic_authentication: [options[:user], options[:token]]) do |source|
        IO.copy_stream(source, file)
      end
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

    def downloaded?
      File.exist?(local_archive_path)
    end

    def local_archive_path
      File.join(archive_cache_path, "#{repo}-#{version}.tar.gz")
    end

    alias_method :path, :local_archive_path

    private

    def archive_cache_path
      File.join(Chef::Config[:file_cache_path], 'github_deploy', 'archives')
    end

    def download_uri
      uri      = URI.parse(host)
      uri.path = "/#{fqrn}/archive/#{URI.encode_www_form_component(version)}.tar.gz"
      uri
    end
  end
end
