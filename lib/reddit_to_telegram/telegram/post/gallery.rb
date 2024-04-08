# frozen_string_literal: true

module RedditToTelegram
  module Telegram
    class Post
      class Gallery
        class << self
          def push_remaining_gallery_data(post, channel, res)
            if post[:additional_media]
              push_remaining_gallery_images(post, channel)
            else
              push_gallery_caption(post, channel, res)
            end
          end

          private

          def push_remaining_gallery_images(post, channel)
            post[:media] = post[:additional_media].first(10)
            remaining = post.delete(:additional_media).drop(10)
            post[:additional_media] = remaining unless remaining.empty?
            Post.push(post, channel)
          end

          def push_gallery_caption(post, channel, res)
            Telegram::Post.push(
              { type: :text,
                id: post[:id],
                text: post[:text],
                misc: gallery_caption_opts(res) },
              channel
            )
          end

          def gallery_caption_opts(res)
            gallery_caption_options = { disable_link_preview: true }
            reply_to = res.dig("result", 0, "message_id")
            return gallery_caption_options if reply_to.nil?

            gallery_caption_options[:reply_to] = reply_to
            gallery_caption_options
          end
        end
      end
    end
  end
end
