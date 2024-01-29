# frozen_string_literal: true

module RedditToTelegram
  module Store
    class Memory
      class << self
        private

        attr_accessor :reddit_token

        @posts = {}

        def setup; end

        def add_post(subreddit, id)
          @posts[subreddit] = [] if @posts[subreddit].nil?
          @posts[subreddit] << id
          @posts[subreddit].shift if @posts[subreddit].count > Store::MAX_STORED_POSTS
        end

        def dup_post?(subreddit, id)
          return false if posts[subreddit].nil?

          posts[subreddit].include?(id)
        end

        def posts
          @posts ||= {}
        end
      end
    end
  end
end
