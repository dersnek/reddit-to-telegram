# frozen_string_literal: true

require_relative "video"
require_relative "../services/translate"

module RedditToTelegram
  module Telegram
    class PrepareRequest
      class << self
        def body(post, chat_id, opts = {})
          case post[:type]
          when :image
            { chat_id: "@#{chat_id}", photo: post[:media], caption: prepare_text(post, chat_id, opts) }
          when :gallery
            { chat_id: "@#{chat_id}", media: prepare_gallery_media(post), caption: prepare_text(post, chat_id, opts) }
          when :text
            { chat_id: "@#{chat_id}", text: prepare_text(post, chat_id, opts) }
          when :video
            {
              chat_id: "@#{chat_id}",
              video: prepare_video(post),
              height: post[:misc][:video_height],
              width: post[:misc][:video_width],
              caption: prepare_text(post, chat_id, opts)
            }
          end
        end

        private

        def prepare_text(post, chat_id, opts = {})
          text = post[:text]

          text = Services::Translate.text(text, opts[:translate]) if opts[:translate]

          if opts[:add_reddit_link]
            id = post[:id].split("_")[1]
            text += "\n\nhttps://redd.it/#{id}"
          end

          text += "\n\n@#{chat_id}" if opts[:add_channel_handle]
          text
        end

        def prepare_gallery_media(post)
          Array(post[:media]).map { |link| { type: "photo", media: link } }
        end

        def prepare_video(post)
          return post[:media] unless post[:misc][:binary]

          Video.from_link(post[:media])
          File.open(Video.temp_video_path)
        end
      end
    end
  end
end
