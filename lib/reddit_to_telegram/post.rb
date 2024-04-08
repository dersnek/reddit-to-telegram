# frozen_string_literal: true

module RedditToTelegram
  class Post
    class << self
      def hot(sources)
        check_config
        return if sources.empty?

        Store.setup

        sources.each do |subreddit, telegram_chat_id|
          res = Reddit::Fetch.hot(subreddit)
          handle_res(res, subreddit, telegram_chat_id)
        end
      end

      def from_link(link, telegram_chat_id)
        check_config
        return if link.empty?

        Configuration.store.type = :memory
        Store.setup

        res = Reddit::Fetch.post(link)
        return unless res_ok?(res)

        Telegram::Post.push(res, telegram_chat_id)
        res
      end

      private

      def check_config
        Errors.new(MissingConfiguration, "Missing Telegram bot token") if Configuration.telegram.bot_token.to_s.empty?
      end

      def handle_res(res, subreddit, telegram_chat_id)
        return unless res_ok?(res)

        post = find_new_post(subreddit, res)

        if post.nil?
          Configuration.logger.info("Could not find a new post to push")
          return
        end

        res = Telegram::Post.push(post, telegram_chat_id)
        Store::Posts.add(subreddit, post[:id])
        res
      end

      def res_ok?(res)
        if res.nil?
          Configuration.logger.warn("Could not fetch Reddit post")
          false
        elsif res.is_a?(Hash) && res[:type].nil?
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
