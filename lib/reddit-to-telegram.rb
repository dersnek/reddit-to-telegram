# frozen_string_literal: true

Dir["#{File.dirname(__FILE__)}/reddit_to_telegram/**/*.rb"].each { |file| require file }

module RedditToTelegram
  class << self
    extend Forwardable

    def_delegators :post, :hot, :from_link

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
