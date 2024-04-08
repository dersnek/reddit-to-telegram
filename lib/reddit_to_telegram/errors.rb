# frozen_string_literal: true

module RedditToTelegram
  class RedditToTelegramError < StandardError; end

  class BadResponseFromTelegram < RedditToTelegramError; end
  class FailedToFetchFromReddit < RedditToTelegramError; end
  class InvalidStoreType < RedditToTelegramError; end
  class MissingConfiguration < RedditToTelegramError; end

  class Errors
    class << self
      def new(error, message = nil)
        log_message = error.to_s
        log_message += ": #{message}" unless message.nil?

        if Configuration.on_error == :raise
          raise(error.new(message))
        elsif Configuration.on_error == :log
          Configuration.logger.error(log_message)
        end

        return unless Configuration.send_errors_to_telegram

        push_error_to_telegram(log_message)

        nil
      end

      private

      def push_error_to_telegram(message)
        if Configuration.telegram.error_channel_id.to_s.empty?
          Configuration.logger.warn("Telegram Error Channel ID is not set up, can't send errors there")
          return
        end

        Telegram::Post.push(
          {
            type: :text,
            text: message,
            misc: { no_retry: true, disable_link_preview: true }
          },
          Configuration.telegram.error_channel_id
        )

        nil
      end
    end
  end
end
