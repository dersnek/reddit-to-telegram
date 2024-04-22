# frozen_string_literal: true

require "logger"

module RedditToTelegram
  module Configuration
    class << self
      attr_writer :add_channel_handle, :add_reddit_link, :logger,
                  :on_error, :send_errors_to_telegram, :translate

      def add_channel_handle
        @add_channel_handle ||= false
      end

      def add_reddit_link
        @add_reddit_link ||= false
      end

      def logger
        @logger ||= Logger.new($stdout).tap do |log|
          log.progname = "RedditToTelegram"
        end
      end

      def on_error
        @on_error ||= :log
      end

      def send_errors_to_telegram
        @send_errors_to_telegram ||= false
      end

      def translate
        @translate ||= nil
      end
    end

    class Store
      DEFAULT_TMP_DIR = "#{Dir.pwd}/tmp".freeze
      DEFAULT_TYPE = :aws_dynamo_db

      class << self
        attr_writer :max_stored_posts, :tmp_dir, :type

        def max_stored_posts
          @max_stored_posts ||= ENV["RTT_MAX_STORED_POSTS"].to_i || 50
        end

        def tmp_dir
          @tmp_dir ||= ENV["RTT_TEMP_DIR"] || DEFAULT_TMP_DIR
        end

        def type
          @type ||= ENV["RTT_STORE_TYPE"]&.to_sym || DEFAULT_TYPE
        end
      end
    end

    class AWS
      ATTRS = %i[access_key_id secret_access_key region].freeze

      class << self
        attr_writer(*ATTRS)

        def access_key_id
          @access_key_id ||= ENV["RTT_AWS_ACCESS_KEY_ID"]
        end

        def secret_access_key
          @secret_access_key ||= ENV["RTT_AWS_SECRET_ACCESS_KEY"]
        end

        def region
          @region ||= ENV["RTT_AWS_REGION"]
        end

        def set_up?
          ATTRS.all? { |a| !a.to_s.empty? }
        end
      end
    end

    class Google
      class << self
        attr_writer :api_key

        def api_key
          @api_key ||= ENV["RTT_GOOGLE_API_KEY"]
        end

        def set_up?
          !api_key.to_s.empty?
        end
      end
    end

    class Reddit
      class << self
        attr_writer :client_id, :client_secret

        def client_id
          @client_id ||= ENV["RTT_REDDIT_CLIENT_ID"]
        end

        def client_secret
          @client_secret ||= ENV["RTT_REDDIT_CLIENT_SECRET"]
        end
      end
    end

    class Telegram
      class << self
        attr_writer :bot_token, :error_channel_id

        def bot_token
          @bot_token ||= ENV["RTT_TELEGRAM_BOT_TOKEN"]
        end

        def error_channel_id
          @error_channel_id ||= ENV["RTT_TELEGRAM_ERROR_CHANNEL_ID"]
        end
      end
    end

    class << self
      NESTED_CONFIG = {
        aws: AWS,
        google: Google,
        reddit: Reddit,
        store: Store,
        telegram: Telegram
      }.freeze

      NESTED_CONFIG.each do |key, value|
        define_method(key) { value }
      end
    end
  end
end
