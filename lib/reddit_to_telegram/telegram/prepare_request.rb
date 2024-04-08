# frozen_string_literal: true

module RedditToTelegram
  module Telegram
    class PrepareRequest
      class << self
        def body(post, chat_id)
          body = prepare_body(post, chat_id)
          body[:link_preview_options] = { is_disabled: true } if post.dig(:misc, :disable_link_preview)
          body[:reply_parameters] = { message_id: post[:misc][:reply_to] } if post.dig(:misc, :reply_to)
          body
        end

        private

        def prepare_body(post, chat_id)
          case post[:type]
          when :image
            { chat_id: "@#{chat_id}", photo: post[:media], caption: prepare_text(post, chat_id) }
          when :gallery
            { chat_id: "@#{chat_id}", media: prepare_gallery_media(post), caption: prepare_text(post, chat_id) }
          when :gif
            { chat_id: "@#{chat_id}", animation: post[:media], caption: prepare_text(post, chat_id) }
          when :text
            { chat_id: "@#{chat_id}", text: prepare_text(post, chat_id) }
          when :video
            {
              chat_id: "@#{chat_id}",
              video: prepare_video(post),
              height: post[:misc][:video_height],
              width: post[:misc][:video_width],
              caption: prepare_text(post, chat_id)
            }
          end
        end

        def prepare_text(post, chat_id)
          text = post[:text]

          text = translate(text)
          text = add_reddit_link(text, post)
          add_channel_handle(text, chat_id)
        end

        def translate(text)
          return text unless Configuration.translate

          Services::Translate.text(text, Configuration.translate)
        end

        def add_reddit_link(text, post)
          return text unless Configuration.add_reddit_link

          id = post[:id]&.split("_")&.dig(1)
          text += "\n\nhttps://redd.it/#{id}" if id
          text
        end

        def add_channel_handle(text, chat_id)
          return text unless Configuration.add_channel_handle

          text += Configuration.add_reddit_link ? "\n" : "\n\n"
          text + "@#{chat_id}"
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
