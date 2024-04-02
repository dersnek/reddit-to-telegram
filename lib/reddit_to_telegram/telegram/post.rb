# frozen_string_literal: true

require "httparty"
require_relative "prepare_request"
require_relative "video"
require_relative "../variables"
require "pry"

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
        def push(post, channel, opts = {})
          res = HTTParty.post(
            "#{BASE_URI}#{Variables.telegram.bot_token}/send#{METHOD_MAP[post[:type]]}",
            **params(post, channel, opts)
          )

          handle_response(post, channel, res, opts)
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

        def handle_response(post, channel, res, opts = {})
          push_error(post, channel, res, opts) unless res["ok"] || opts[:no_retry]
          push_gallery_caption(post, channel, res, opts) if post[:type] == :gallery
          Video.delete_file if post[:type] == :video && post.dig(:misc)&.dig(:binary)
          res
        end

        def push_gallery_caption(post, channel, res, opts = {})
          push({ type: :text, id: post[:id], text: post[:text] }, channel, opts.merge(gallery_caption_opts(res)))
        end

        def gallery_caption_opts(res)
          gallery_caption_options = { disable_link_preview: true }
          reply_to = res.dig("result", 0, "message_id")
          return gallery_caption_options if reply_to.nil?

          gallery_caption_options[:reply_to] = reply_to
          gallery_caption_options
        end

        def push_error(post, channel, res, opts = {})
          return if Variables.telegram.error_channel_id.to_s.empty?

          push(
            {
              type: :text,
              id: post[:id],
              text: "Channel: @#{channel}\n\nResponse: #{res}"
            },
            Variables.telegram.error_channel_id,
            opts.merge(
              add_reddit_link: true,
              disable_link_preview: true,
              no_retry: true
            )
          )
        end
      end
    end
  end
end
