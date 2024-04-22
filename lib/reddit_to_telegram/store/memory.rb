# frozen_string_literal: true

module RedditToTelegram
  module Store
    class Memory
      class << self
        private

        attr_accessor :reddit_token

        @posts = {}

        def setup; end
        def load_posts(_); end

        def add_post(telegram_chat_id, subreddit, id)
          assign_empty_values_to_posts(telegram_chat_id, subreddit)

          posts[telegram_chat_id][subreddit] << id
          return unless posts[telegram_chat_id][subreddit].count > Store.max_stored_posts

          posts[telegram_chat_id][subreddit].shift
        end

        def assign_empty_values_to_posts(telegram_chat_id, subreddit)
          posts[telegram_chat_id] = {} if posts[telegram_chat_id].nil?
          posts[telegram_chat_id][subreddit] = [] if posts[telegram_chat_id][subreddit].nil?
        end

        def dup_post?(telegram_channel, subreddit, id)
          return false if posts.dig(telegram_channel, subreddit).nil?

          posts[telegram_channel][subreddit].include?(id)
        end

        def posts
          @posts ||= {}
        end
      end
    end
  end
end
