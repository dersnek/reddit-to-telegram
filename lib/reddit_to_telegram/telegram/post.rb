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
        def push(post, channel, opts = {})
          res = HTTParty.post(
            "#{BASE_URI}#{Variables.telegram.bot_token}/send#{METHOD_MAP[post[:type]]}",
            **params(post, channel, opts)
          )

          if post[:type] == :gallery
            push({ type: :text, id: post[:id], text: post[:text] }, channel, opts.merge(disable_link_preview: true))
          end

          Video.delete_file if post[:type] == :video && post.dig(:misc)&.dig(:binary)
          res
        end

        private

        def params(post, channel, opts = {})
          binary = post.dig(:misc)&.dig(:binary)
          body = PrepareRequest.body(post, channel, opts)

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
