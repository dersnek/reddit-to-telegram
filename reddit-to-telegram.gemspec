# frozen_string_literal: true

$:.push File.expand_path("../lib", __FILE__)
require "reddit_to_telegram/version"

Gem::Specification.new do |s|
  s.name        = "reddit-to-telegram"
  s.version     = RedditToTelegram::VERSION
  s.summary     = "Fetches hot posts from reddit and pushes them to telegram"
  s.description = "This gem makes simple reddit-to-telegram ruby bots easy to create"
  s.authors     = ["Mark Tityuk"]
  s.email       = "mark.tityuk@gmail.com"
  s.files       = `git ls-files`.split("\n")
  s.homepage    = "https://github.com/dersnek/reddit-to-telegram"
  s.license     = "MIT"

  s.add_dependency "aws-sdk-simpledb"
  s.add_dependency "httparty"

  s.add_development_dependency "rubocop"
end
