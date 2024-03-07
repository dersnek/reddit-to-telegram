# frozen_string_literal: true

require_relative "reddit/fetch"
require_relative "services/translate"
require_relative "store"
require_relative "telegram/post"
require_relative "variables"

module RedditToTelegram
  class Post
    class << self
      def hot(sources, opts = {})
        return if sources.empty?

        Store.setup

        sources.each do |subreddit, telegram_chat_id|
          res = Reddit::Fetch.hot(subreddit)
          handle_res(res, subreddit, telegram_chat_id, opts)
        end
      end

      def single(link, telegram_chat_id, opts = {})
        return if link.empty?

        Variables.store.type = :memory
        Store.setup

        res = Reddit::Fetch.post(link)
        res = translate(res, opts[:translate]) if opts[:translate]
        Telegram::Post.push(res, telegram_chat_id)
      end

      private

      def handle_res(res, subreddit, telegram_chat_id, opts = {})
        return if res.nil?

        post = find_new_post(subreddit, res)
        return if post.nil?

        post = translate(post, opts[:translate]) if opts[:translate]
        res = Telegram::Post.push(post, telegram_chat_id)
        Store::Posts.add(subreddit, post[:id])
        res
      end

      def find_new_post(subreddit, posts)
        posts.find { |post| !Store::Posts.dup?(subreddit, post[:id]) }
      end

      def translate(post, target_language)
        post[:text] = Services::Translate.text(post[:text], target_language)
        post
      end
    end
  end
end
