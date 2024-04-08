# frozen_string_literal: true

require_relative "configuration"
require_relative "errors"
require_relative "store/aws_simple_db"
require_relative "store/memory"
require_relative "store/temp_file"

module RedditToTelegram
  module Store
    MAX_STORED_POSTS = Configuration.store.max_stored_posts - 1
    CLASS_MAP = {
      aws_simple_db: "RedditToTelegram::Store::AWSSimpleDB",
      memory: "RedditToTelegram::Store::Memory",
      temp_file: "RedditToTelegram::Store::TempFile"
    }.freeze

    STORE = Object.const_get("RedditToTelegram::Store::AWSSimpleDB")

    class << self
      attr_accessor :active

      def setup
        Errors.new(InvalidStoreType) unless CLASS_MAP.keys.include?(Configuration.store.type)

        self.active = Object.const_get(CLASS_MAP[Configuration.store.type])
        active.send(:setup)
      end
    end

    class Reddit
      class << self
        def token
          Store.active.send(:reddit_token)
        end

        def token=(val)
          Store.active.send(:reddit_token=, val)
        end
      end
    end

    class Posts
      class << self
        def add(subreddit, id)
          Store.active.send(:add_post, subreddit, id)
        end

        def dup?(subreddit, id)
          Store.active.send(:dup_post?, subreddit, id)
        end
      end
    end
  end
end
