# frozen_string_literal: true

require "open-uri"
require_relative "../configuration"

module RedditToTelegram
  module Telegram
    class Video
      class << self
        def from_link(link)
          download = URI.parse(link).open
          File.open(temp_video_path, "w+b") do |file|
            download.respond_to?(:read) ? IO.copy_stream(download, file) : file.write(download)
          end
        end

        def delete_file
          return unless File.exist?(temp_video_path)

          f = File.open(temp_video_path, "r")
          f.close unless f.nil? || f.closed?
          File.delete(temp_video_path)
        end

        def temp_video_path
          "#{Configuration.store.tmp_dir}/video.mp4"
        end
      end
    end
  end
end
