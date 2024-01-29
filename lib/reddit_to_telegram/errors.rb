# frozen_string_literal: true

module RedditToTelegram
  class RedditToTelegramError < StandardError; end
  class InvalidStoreType < RedditToTelegramError; end
end
