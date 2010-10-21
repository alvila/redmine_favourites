require 'redmine'
require 'dispatcher'
require 'query_patch_like'

Redmine::Plugin.register :redmine_favourites do
  name 'Favourites plugin'
  author 'Milan Stastny of ALVILA SYSTEMS'
  description 'Bookmarking favourite tasks by Like button with Query inclusion'
  version '0.0.1'
  author_url 'http://www.alvila.com'
end

Dispatcher.to_prepare do
  Query.send( :include, RedmineLike::RedmineExt::QueryPatch)
end

