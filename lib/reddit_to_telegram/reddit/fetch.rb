# frozen_string_literal: true

require "httparty"
require_relative "auth"
require_relative "output"
require_relative "../store"
require_relative "../variables"

module RedditToTelegram
  module Reddit
    class Fetch
      include HTTParty

      BASE_URI = "https://oauth.reddit.com/r"
      WEBSITE_URI = "https://www.reddit.com/r"
      QUERY_FOR_POST = { g: "GLOBAL" }.freeze
      QUERY_FOR_SUBREDDIT = QUERY_FOR_POST.merge(limit: Variables.store.max_stored_posts).freeze
      BASE_HEADERS = {
        "Content-Type" => "application/json",
        "Accept" => "application/json"
      }.freeze

      class << self
        def hot(subreddit, retries_left = 5)
          headers = BASE_HEADERS.merge("Authorization" => "Bearer #{Store::Reddit.token}")
          res = HTTParty.get(
            "#{BASE_URI}/#{subreddit}/hot.json",
            query: QUERY_FOR_SUBREDDIT,
            headers:
          )
          handle_response(res, hot: [subreddit, retries_left])
        end

        def post(link, retries_left = 5)
          headers = BASE_HEADERS.merge("Authorization" => "Bearer #{Store::Reddit.token}")
          link = link.gsub("www", "oauth") if link.match?(/www.reddit.com/)
          link += ".json" unless link.match?(/.json/)

          res = HTTParty.get(
            link,
            query: QUERY_FOR_POST,
            headers:
          )
          handle_response(res, post: retries_left)
        end

        private

        def handle_response(res, func)
          func_name = func.keys.first
          func_args = Array(func.values.first)

          case res.code
          when 401
            handle_401(func_name, func_args)
          when 429
            handle_429(func_name, func_args)
          when 200
            Output.format_response(res)
          end
        end

        def handle_401(func_name, func_args)
          Store::Reddit.token = Auth.token
          send(func_name, *func_args) if func_args.last > 0
        end

        def handle_429(func_name, func_args)
          retries_left = func_args.last

          sleep(10 / retries_left) if retries_left > 0
          func_args[func_args.length - 1] = retries_left - 1
          send(func_name, *func_args) if retries_left > 0
        end
      end
    end
  end
end
