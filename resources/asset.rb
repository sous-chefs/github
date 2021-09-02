actions :download, :delete
default_action :download
unified_mode false

attribute :release, kind_of: String, required: true
attribute :repo, kind_of: String, required: true
attribute :github_user, kind_of: String
attribute :github_token, kind_of: String
attribute :owner, kind_of: String
attribute :group, kind_of: String
attribute :force, kind_of: [TrueClass, FalseClass], default: false

def asset_path
  GithubCB::Asset.asset_path(@repo, @release, @name)
end
