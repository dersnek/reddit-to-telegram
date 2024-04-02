# frozen_string_literal: true

require_relative "../post"

module RedditToTelegram
  module Telegram
    class Post
      class Gallery
        class << self
          def push_remaining_gallery_data(post, channel, res, opts = {})
            if post[:additional_media]
              push_remaining_gallery_images(post, channel, opts)
            else
              push_gallery_caption(post, channel, res, opts)
            end
          end

          private

          def push_remaining_gallery_images(post, channel,opts = {})
            post[:media] = post[:additional_media].first(10)
            remaining = post.delete(:additional_media).drop(10)
            post[:additional_media] = remaining unless remaining.empty?
            Post.push(post, channel, opts)
          end

          def push_gallery_caption(post, channel, res, opts = {})
            Post.push(
              { type: :text,
                id: post[:id],
                text: post[:text] },
              channel,
              opts.merge(gallery_caption_opts(res, opts))
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
