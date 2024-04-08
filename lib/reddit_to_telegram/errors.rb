# frozen_string_literal: true

require_relative "configuration"

module RedditToTelegram
  class RedditToTelegramError < StandardError; end

  class InvalidStoreType < RedditToTelegramError; end
  class MissingConfiguration < RedditToTelegramError; end

  class Errors
    class << self
      def new(error, message = nil)
        if Configuration.on_error == :raise
          raise(error.new(message))
        elsif Configuration.on_error == :log
          log_message = error.to_s
          log_message += ": #{message}" unless message.nil?
          Configuration.logger.error(log_message)
        end
      end
    end
  end
end
