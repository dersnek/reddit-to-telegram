# frozen_string_literal: true

require_relative "configuration"
require_relative "errors"
require_relative "reddit/fetch"
require_relative "store"
require_relative "telegram/post"

module RedditToTelegram
  class Post
    class << self
      def hot(sources, opts = {})
        check_config
        return if sources.empty?

        Store.setup

        sources.each do |subreddit, telegram_chat_id|
          res = Reddit::Fetch.hot(subreddit)
          handle_res(res, subreddit, telegram_chat_id, opts)
        end
      end

      def from_link(link, telegram_chat_id, opts = {})
        check_config
        return if link.empty?

        Configuration.store.type = :memory
        Store.setup

        res = Reddit::Fetch.post(link)
        return unless res_ok?(res)

        Telegram::Post.push(res, telegram_chat_id, opts)
        res
      end

      private

      def check_config
        Errors.new(MissingConfiguration, "Missing Telegram bot token") if Configuration.telegram.bot_token.to_s.empty?
      end

      def handle_res(res, subreddit, telegram_chat_id, opts = {})
        return unless res_ok?(res)

        post = find_new_post(subreddit, res)
        return if post.nil?

        res = Telegram::Post.push(post, telegram_chat_id, opts)
        Store::Posts.add(subreddit, post[:id])
        res
      end

      def res_ok?(res)
        if res.nil?
          Configuration.logger.warn("Could not fetch Reddit post")
          false
        elsif res[:type].nil?
          Configuration.logger.warn("Could not determine Reddit post type")
          false
        else
          true
        end
      end

      def find_new_post(subreddit, posts)
        posts.find { |post| !Store::Posts.dup?(subreddit, post[:id]) }
      end
    end
  end
end
