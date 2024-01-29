# frozen_string_literal: true

require_relative "video"

module RedditToTelegram
  module Telegram
    class PrepareRequest
      class << self
        def body(post, chat_id)
          case post[:type]
          when :image
            { chat_id: "@#{chat_id}", photo: post[:media], caption: prepare_text(post, chat_id) }
          when :gallery
            { chat_id: "@#{chat_id}", media: prepare_gallery_media(post), caption: prepare_text(post, chat_id) }
          when :text
            { chat_id: "@#{chat_id}", text: prepare_text(post, chat_id) }
          when :video
            { chat_id: "@#{chat_id}", video: prepare_video(post), caption: prepare_text(post, chat_id) }
          end
        end

        private

        def prepare_text(post, chat_id)
          id = post[:id].split("_")[1]
          "#{post[:text]}\n\nhttps://redd.it/#{id}\n@#{chat_id}"
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
