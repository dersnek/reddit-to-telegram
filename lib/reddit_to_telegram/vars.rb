# frozen_string_literal: true

module RedditToTelegram
  module Vars
    DEFAULT_TMP_DIR = "#{Dir.pwd}/tmp".freeze

    class << self
      # rubocop:disable Metrics/ParameterLists
      def assign_values(
        max_stored_posts:,
        tmp_dir:,
        aws_access_key_id:,
        aws_secret_access_key:,
        aws_region:,
        reddit_client_id:,
        reddit_client_secret:,
        telegram_bot_token:
      )

        @max_stored_posts = max_stored_posts
        @tmp_dir = tmp_dir
        AWS.instance_variable_set(:@access_key_id, aws_access_key_id)
        AWS.instance_variable_set(:@secret_access_key, aws_secret_access_key)
        AWS.instance_variable_set(:@region, aws_region)
        Reddit.instance_variable_set(:@client_id, reddit_client_id)
        Reddit.instance_variable_set(:@client_secret, reddit_client_secret)
        Telegram.instance_variable_set(:@bot_token, telegram_bot_token)
      end
      # rubocop:enable Metrics/ParameterLists

      def max_stored_posts
        @max_stored_posts ||= ENV["RTT_MAX_STORED_POSTS"].to_i || 50
      end

      def tmp_dir
        @tmp_dir ||= ENV["RTT_TEMP_DIR"] || DEFAULT_TMP_DIR
      end
    end

    class AWS
      class << self
        def access_key_id
          @access_key_id ||= ENV["RTT_AWS_ACCESS_KEY_ID"]
        end

        def secret_access_key
          @secret_access_key ||= ENV["RTT_AWS_SECRET_ACCESS_KEY"]
        end

        def region
          @region ||= ENV["RTT_AWS_REGION"]
        end
      end
    end

    class Reddit
      class << self
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
        def bot_token
          @bot_token ||= ENV["RTT_TELEGRAM_BOT_TOKEN"]
        end
      end
    end
  end
end
