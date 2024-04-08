# frozen_string_literal: true

require_relative "reddit_to_telegram/configuration"
require_relative "reddit_to_telegram/post"
require_relative "reddit_to_telegram/version"

module RedditToTelegram
  class << self
    extend Forwardable

    def_delegators :post, :hot, :single

    def post
      Post
    end

    def config
      Configuration
    end

    def version
      VERSION
    end
  end
end
