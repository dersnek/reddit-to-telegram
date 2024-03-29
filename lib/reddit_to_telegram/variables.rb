# frozen_string_literal: true

module RedditToTelegram
  module Variables
    class << self
      def aws
        RedditToTelegram::Variables::AWS
      end

      def google
        RedditToTelegram::Variables::Google
      end

      def reddit
        RedditToTelegram::Variables::Reddit
      end

      def store
        RedditToTelegram::Variables::Store
      end

      def telegram
        RedditToTelegram::Variables::Telegram
      end
    end

    class Store
      DEFAULT_TMP_DIR = "#{Dir.pwd}/tmp".freeze
      DEFAULT_TYPE = :aws_simple_db

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
      ATTRS = %i[access_key_id secret_access_key region domain_name].freeze
      DEFAULT_DOMAIN_NAME = "reddit_to_telegram"

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

        def domain_name
          @domain_name ||= ENV["RTT_AWS_DOMAIN_NAME"] || DEFAULT_DOMAIN_NAME
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
  end
end
