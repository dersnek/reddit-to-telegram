# frozen_string_literal: true

module RedditToTelegram
  module Store
    CLASS_MAP = {
      aws_dynamo_db: "RedditToTelegram::Store::AWSDynamoDB",
      memory: "RedditToTelegram::Store::Memory",
      temp_file: "RedditToTelegram::Store::TempFile"
    }.freeze

    class << self
      attr_accessor :active

      def setup
        Errors.new(InvalidStoreType) unless CLASS_MAP.keys.include?(Configuration.store.type)

        self.active = Object.const_get(CLASS_MAP[Configuration.store.type])
        active.send(:setup)
      end

      def max_stored_posts
        Configuration.store.max_stored_posts - 1
      end

      def posts
        Posts
      end
    end

    class Posts
      class << self
        def add(telegram_chat_id, subreddit, id)
          Store.active.send(:add_post, telegram_chat_id, subreddit, id)
        end

        def dup?(telegram_chat_id, subreddit, id)
          Store.active.send(:dup_post?, telegram_chat_id, subreddit, id)
        end

        def next(telegram_chat_id, subreddit, posts)
          Store.active.send(:load_posts, telegram_chat_id)
          new_post = posts.find { |post| !dup?(telegram_chat_id, subreddit, post[:id]) }
          add(telegram_chat_id, subreddit, new_post[:id]) unless new_post.nil?
          new_post
        end
      end
    end
  end
end
