# frozen_string_literal: true

module RedditToTelegram
  class RedditToTelegramError < StandardError; end
  class InvalidStoreType < RedditToTelegramError; end
  class MissingVariables < RedditToTelegramError; end
end
