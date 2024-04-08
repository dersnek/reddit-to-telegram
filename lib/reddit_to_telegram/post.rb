# frozen_string_literal: true

module RedditToTelegram
  class Post
    class << self
      def hot(sources)
        check_config
        return if sources.empty?

        Store.setup

        sources.each do |telegram_chat_id, subreddit|
          res = Reddit::Fetch.hot(subreddit)
          handle_res(res, subreddit, telegram_chat_id)
        end
      end

      def from_link(sources)
        check_config
        return unless check_from_link_sources(sources)

        Configuration.store.type = :memory
        Store.setup

        res = Reddit::Fetch.post(sources.values.first)
        return unless res_ok?(res)

        Telegram::Post.push(res, sources.keys.first)
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

      def check_from_link_sources(sources)
        if !sources.is_a?(Hash) || sources.keys.count != 1 || sources.values.count != 1
          Errors.new(ArgumentError, "Check documentation on usage")
          return false
        end

        true
      end
    end
  end
end
