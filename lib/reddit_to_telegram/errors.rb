# frozen_string_literal: true

module RedditToTelegram
  class RedditToTelegramError < StandardError; end
  class InvalidStoreType < RedditToTelegramError; end
  class MissingConfiguration < RedditToTelegramError; end
  class CouldNotFetchRedditPost < RedditToTelegramError; end
  class CouldNotDetermineRedditPostType < RedditToTelegramError; end
end
