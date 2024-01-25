# frozen_string_literal: true

require "open-uri"

module RedditToTelegram
  module Telegram
    class Video
      TEMP_VIDEO_PATH = "#{Dir.pwd}/tmp/video.mp4".freeze

      class << self
        def from_link(link)
          download = URI.parse(link).open
          IO.copy_stream(download, TEMP_VIDEO_PATH)
        end

        def delete_file
          f = File.open(TEMP_VIDEO_PATH, "r")
        ensure
          f.close unless f.nil? || f.closed?
          File.delete(TEMP_VIDEO_PATH) if File.exist?(TEMP_VIDEO_PATH)
        end
      end
    end
  end
end
