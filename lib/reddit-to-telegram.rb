# frozen_string_literal: true

require_relative "reddit_to_telegram/reddit/fetch"
require_relative "reddit_to_telegram/store"
require_relative "reddit_to_telegram/telegram/post"
require_relative "reddit_to_telegram/version"

module RedditToTelegram
  class << self
    def post(sources)
      return if sources.empty?

      Store.setup

      sources.each do |subreddit, telegram_chat_id|
        res = Reddit::Fetch.hot(subreddit)
        handle_res(res, subreddit, telegram_chat_id)
      end
    end

    def handle_res(res, subreddit, telegram_chat_id)
      return if res.nil?

      post = find_new_post(subreddit, res)
      return if post.nil?

      Telegram::Post.push(post, telegram_chat_id)
      Store::Posts.add(subreddit, post[:id])
    end

    def find_new_post(subreddit, posts)
      posts.find { |post| !Store::Posts.dup?(subreddit, post[:id]) }
    end
  end
end
