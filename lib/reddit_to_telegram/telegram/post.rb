# frozen_string_literal: true

require "httparty"
require_relative "prepare_request"
require_relative "video"
require_relative "../variables"

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
        text: :message,
        video: :video
      }.freeze

      class << self
        def push(post, channel)
          HTTParty.post(
            "#{BASE_URI}#{Variables.telegram.bot_token}/send#{METHOD_MAP[post[:type]]}",
            **params(post, channel)
          )

          push({ type: :text, id: post[:id], text: post[:text] }, channel) if post[:type] == :gallery
          Video.delete_file if post[:type] == :video
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
      end
    end
  end
end
