# frozen_string_literal: true

require "httparty"
require_relative "auth"
require_relative "output"
require_relative "../store"
require_relative "../vars"

module RedditToTelegram
  module Reddit
    class Fetch
      include HTTParty

      BASE_URI = "https://oauth.reddit.com/r"
      QUERY = { g: "GLOBAL", limit: Vars.max_stored_posts }.freeze
      BASE_HEADERS = {
        "Content-Type" => "application/json",
        "Accept" => "application/json"
      }.freeze

      class << self
        def hot(subreddit, retries_left = 5)
          headers = BASE_HEADERS.merge("Authorization" => "Bearer #{Store::Reddit.token}")
          res = HTTParty.get(
            "#{BASE_URI}/#{subreddit}/hot.json",
            query: QUERY,
            headers:
          )
          handle_response(res, subreddit, retries_left)
        end

        private

        def handle_response(res, subreddit, retries_left)
          case res.code
          when 401
            Store::Reddit.token = Auth.token
            hot(subreddit, retries_left) if retries_left > 0
          when 429
            sleep(10 / retries_left) if retries_left > 0
            hot(subreddit, retries_left - 1) if retries_left > 0
          when 200
            Output.format_response(res)
          end
        end
      end
    end
  end
end
