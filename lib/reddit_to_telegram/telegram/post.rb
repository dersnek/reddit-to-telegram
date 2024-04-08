# frozen_string_literal: true

require "httparty"

module RedditToTelegram
  module Telegram
    class Post
      include HTTParty

      BASE_URI = "https://api.telegram.org/bot"
      JSON_HEADERS = { "Content-Type" => "application/json", "Accept" => "application/json" }.freeze
      FORM_HEADERS = { "Content-Type" => "multipart/form-data", "Accept" => "application/json" }.freeze
      METHOD_MAP = {
        image: :photo,
        gallery: :mediagroup,
        gif: :animation,
        text: :message,
        video: :video
      }.freeze

      class << self
        def push(post, channel)
          res = HTTParty.post(
            "#{BASE_URI}#{Configuration.telegram.bot_token}/send#{METHOD_MAP[post[:type]]}",
            **params(post, channel)
          )

          handle_response(post, channel, res)
        end

        private

        def params(post, channel)
          binary = post.dig(:misc)&.dig(:binary)
          body = PrepareRequest.body(post, channel)

          pars = {
            body: binary ? body : body.to_json,
            headers: binary ? FORM_HEADERS : JSON_HEADERS
          }
          pars[:multipart] = true if binary
          pars
        end

        def handle_response(post, channel, res)
          log_error(post, channel, res) unless res["ok"]
          Gallery.push_remaining_gallery_data(post, channel, res) if post[:type] == :gallery
          Video.delete_file if post[:type] == :video && post.dig(:misc, :binary)
          res
        end

        def log_error(post, channel, res)
          message = "\n\nChannel: #{channel}\n\nPost data: #{post}\n\nResponse: #{res}"
          Errors.new(BadResponseFromTelegram, message)
        end
      end
    end
  end
end
