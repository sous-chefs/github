#
# Cookbook Name:: github
# Resource:: archive
#
# Author:: Jamie Winsor (<jamie@vialstudios.com>)
#

actions :extract, :delete
default_action :extract

attribute :repo, kind_of: String, name_attribute: true, required: true
attribute :version, kind_of: String, default: "master"
attribute :user, kind_of: String
attribute :password, kind_of: String
attribute :host, kind_of: String
attribute :owner, kind_of: String
attribute :group, kind_of: String
attribute :extract_to, kind_of: String, required: true
attribute :force, kind_of: [TrueClass, FalseClass], default: false
