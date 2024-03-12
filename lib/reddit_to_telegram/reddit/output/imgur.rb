# frozen_string_literal: true

require "cgi"

module RedditToTelegram
  module Reddit
    class Output
      class Imgur
        class << self
          def try_extract(data)
            full_url = decode_imgur_url(data)
            return unless full_url

            video_url = extract_video_url(full_url)
            width = extract_video_width(full_url)
            return if video_url.nil? || width.nil?

            format_imgur_post(data, video_url, width)
          end

          private

          def decode_imgur_url(data)
            encoded_url = data
                          .dig("media_embed", "content")
                          &.match(/src=\"\S+schema=imgur\"/)&.to_s
                          &.gsub(/src=\"|\"/, 'src=\"' => "", '\"' => "")
            return unless encoded_url

            CGI.unescape(encoded_url)
          end

          def extract_video_url(full_url)
            video_url_arr = full_url&.match(/image=(\S+\?|&)/)&.to_s&.send(:[], 6..-2)&.split(".")
            return if Array(video_url_arr).empty?

            video_url_arr[video_url_arr.length - 1] = "mp4"
            video_url_arr.join(".")
          end

          def extract_video_width(full_url)
            full_url&.match(/w=(\w+)/)&.to_s&.send(:[], 2..)
          end

          def format_imgur_post(data, video_url, width)
            RedditToTelegram::Reddit::Output.send(
              :base_post_format_attrs, data
            ).merge(
              {
                type: :video,
                media: video_url,
                misc: {
                  binary: false,
                  video_width: width
                }
              }
            )
          end
        end
      end
    end
  end
end
