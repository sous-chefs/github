module GithubCB
  class GHError < StandardError; end

  class AuthenticationError < GHError
    def initialize
      super('Unable to authenticate with Github API. Check your username/password and try again.')
    end
  end

  class ReleaseNotFound < GHError; end
  class AssetNotFound < GHError; end
end
