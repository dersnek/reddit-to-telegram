# frozen_string_literal: true

require "cgi"
require_relative "output/imgur"

module RedditToTelegram
  module Reddit
    class Output
      class << self
        def format_response(res)
          return format_post(res[0]["data"]["children"][0]) if single_post?(res)

          posts = res["data"]["children"]
          posts.reject! { |post| post["data"]["stickied"] == true }
          posts.map { |post| format_post(post) }.compact
        end

        private

        def single_post?(res)
          res.parsed_response.is_a?(Array) && res[0]["data"]["dist"] == 1
        end

        def format_post(post)
          data = post["data"]
          if data["post_hint"] == "image"
            format_image_post(data)
          elsif data["post_hint"] == "link"
            format_link_post(data)
          elsif data["is_gallery"]
            format_gallery_post(data)
          elsif data["is_video"]
            format_video_post(data)
          end
        end

        def format_image_post(data)
          post_type = data["url"]&.split(".")&.last == "gif" ? :gif : :image

          base_post_format_attrs(data).merge(
            { type: post_type,
              media: data["url"] }
          )
        end

        def format_link_post(data)
          res = Imgur.try_extract(data) if data["domain"] == "imgur.com"
          return res unless res.nil?

          base_post_format_attrs(data).merge(
            { type: :text,
              text: "#{data['title']}\n\n#{data['url']}" }
          )
        end

        def format_gallery_post(data)
          base_post_format_attrs(data).merge(
            { type: :gallery,
              media: prepare_gallery_links(data) }
          )
        end

        def format_video_post(data)
          video_data = data["secure_media"]["reddit_video"]
          video_url = video_data["fallback_url"]
          if video_data["has_audio"]
            audio_url = "#{video_url.split('_')[0]}_AUDIO_128.mp4"
            video_url = "https://sd.rapidsave.com/download.php"\
                        "?permalink=https://reddit.com#{data['permalink']}"\
                        "&video_url=#{video_url}&audio_url=#{audio_url}"
          end

          base_post_format_attrs(data).merge(
            {
              type: :video,
              media: video_url,
              misc: {
                binary: video_data["has_audio"] || false,
                video_height: video_data["height"],
                video_width: video_data["width"]
              }
            }
          )
        end

        def base_post_format_attrs(data)
          { id: data["name"],
            text: CGI.unescapeHTML(data["title"]) }
        end

        def prepare_gallery_links(data)
          data["gallery_data"]["items"].map do |image|
            data["media_metadata"].find do |key, _|
              key == image["media_id"]
            end[1]["s"]["u"].split("?").first.gsub("preview", "i")
          end
        end
      end
    end
  end
end
