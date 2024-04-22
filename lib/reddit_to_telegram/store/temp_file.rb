# frozen_string_literal: true

require "json"

module RedditToTelegram
  module Store
    class TempFile
      class << self
        private

        attr_reader :reddit_token, :posts

        @reddit_token = nil
        @posts = {}

        def setup
          read_file
        end

        def load_posts(_); end

        def reddit_token=(val)
          @reddit_token = val
          write_file
        end

        def add_post(telegram_chat_id, subreddit, id)
          assign_empty_values_to_posts(telegram_chat_id, subreddit)

          @posts[telegram_chat_id][subreddit] << id

          if @posts[telegram_chat_id][subreddit].count > Store.max_stored_posts
            @posts[telegram_chat_id][subreddit].shift
          end

          write_file
        end

        def assign_empty_values_to_posts(telegram_chat_id, subreddit)
          @posts[telegram_chat_id] = {} if @posts[telegram_chat_id].nil?
          @posts[telegram_chat_id][subreddit] = [] if @posts[telegram_chat_id][subreddit].nil?
        end

        def dup_post?(telegram_channel, subreddit, id)
          return false if posts.dig(telegram_channel, subreddit).nil?

          posts[telegram_channel][subreddit].include?(id)
        end

        def read_file
          return assign_default_values unless File.exist?(temp_file_path)

          file = File.read(temp_file_path)
          data = JSON.parse(file)
          @reddit_token = data["reddit_token"]
          @posts = {}
          data.each do |key, value|
            @posts[key.split("_").last.to_sym] = value.transform_keys(&:to_sym) if key.match?(/posts_.+/)
          end
        end

        def write_file
          data = { reddit_token: @reddit_token }
          @posts.each do |telegram_chat_id, values|
            data["posts_#{telegram_chat_id}"] = values
          end
          File.open(temp_file_path, "w") { |f| f.write(data.to_json) }
        end

        def assign_default_values
          @reddit_token = nil
          @posts = {}
        end

        def temp_file_path
          "#{Configuration.store.tmp_dir}/store.json"
        end
      end
    end
  end
end
