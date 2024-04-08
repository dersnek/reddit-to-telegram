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

        def reddit_token=(val)
          @reddit_token = val
          write_file
        end

        def add_post(subreddit, id)
          @posts[subreddit] = [] if @posts[subreddit].nil?
          @posts[subreddit] << id
          @posts[subreddit].shift if @posts[subreddit].count > Store::MAX_STORED_POSTS
          write_file
        end

        def dup_post?(subreddit, id)
          return false if posts[subreddit].nil?

          posts[subreddit].include?(id)
        end

        def read_file
          return assign_default_values unless File.exist?(temp_file_path)

          file = File.read(temp_file_path)
          data = JSON.parse(file)
          @reddit_token = data["reddit_token"]
          @posts = {}
          data.each do |key, value|
            @posts[key.split("_").last.to_sym] = value if key.match?(/posts_.+/)
          end
        end

        def write_file
          data = { reddit_token: @reddit_token }
          @posts.each do |subreddit, values|
            data["posts_#{subreddit}".to_sym] = values
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
