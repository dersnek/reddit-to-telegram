# frozen_string_literal: true

require "aws-sdk-dynamodb"
require "json"
require "pry"

module RedditToTelegram
  module Store
    class AWSDynamoDB
      ITEM_NAME = "cached_data"

      class << self
        def client
          @client ||= Aws::DynamoDB::Client.new(
            access_key_id: Configuration.aws.access_key_id,
            secret_access_key: Configuration.aws.secret_access_key,
            region: Configuration.aws.region
          )
        end

        private

        attr_reader :reddit_token

        def setup
          check_credentials
          prepare_db
          assign_default_values
        end

        def check_credentials
          return unless Configuration.store.type == :aws_dynamo_db

          return if Configuration.aws.set_up?

          Errors.new(
            MissingConfiguration,
            "Missing AWS credentials. Set them up or change store type to anything other than aws_dynamo_db"
          )
        end

        def add_post(telegram_chat_id, subreddit, id)
          assign_empty_values_to_posts(telegram_chat_id, subreddit)

          @posts[telegram_chat_id][subreddit] << id

          if @posts[telegram_chat_id][subreddit].count > Store.max_stored_posts
            @posts[telegram_chat_id][subreddit].shift
          end

          persist_posts(telegram_chat_id)
        end

        def assign_empty_values_to_posts(telegram_chat_id, subreddit)
          @posts[telegram_chat_id] = {} if @posts[telegram_chat_id].nil?
          @posts[telegram_chat_id][subreddit] = [] if @posts[telegram_chat_id][subreddit].nil?
        end

        def persist_posts(telegram_chat_id)
          res = client.put_item(
            {
              item: {
                "TelegramChannel" => telegram_chat_id.to_s,
                "Posts" => @posts[telegram_chat_id].to_json
              },
              return_consumed_capacity: "TOTAL",
              table_name: POSTS_TABLE_NAME
            }
          )

          Errors.new(FailedToPersistData, "Failed to persist data to DynamoDB") unless res.successful?
        end

        def dup_post?(telegram_chat_id, subreddit, id)
          return false if @posts.dig(telegram_chat_id, subreddit).nil?

          @posts[telegram_chat_id][subreddit].include?(id)
        end

        def load_posts(telegram_chat_id)
          res = client.get_item(
            { key: { "TelegramChannel" => telegram_chat_id.to_s },
              table_name: POSTS_TABLE_NAME }
          )
          @posts[telegram_chat_id] = JSON.parse(res.item["Posts"]).transform_keys(&:to_sym)
        rescue StandardError
          @posts[telegram_chat_id] = nil
        end

        def assign_default_values
          @reddit_token = ""
          @posts = {}
        end

        POSTS_TABLE_NAME = "Posts"
        POSTS_TABLE_ATTRIBUTES = {
          attribute_definitions: [
            { attribute_name: "TelegramChannel",
              attribute_type: "S" }
          ],
          key_schema: [
            { attribute_name: "TelegramChannel",
              key_type: "HASH" }
          ],
          provisioned_throughput: {
            read_capacity_units: 1,
            write_capacity_units: 1
          },
          table_name: POSTS_TABLE_NAME
        }.freeze

        def prepare_db
          res = client.list_tables
          return unless res.successful?

          return if res.table_names.include?(POSTS_TABLE_NAME)

          client.create_table(POSTS_TABLE_ATTRIBUTES)

          waited = 0
          while client.describe_table(table_name: POSTS_TABLE_NAME).table.table_status != "ACTIVE"
            if waited == 10
              Errors.new(FailedToCreateDatabaseTable, "Failed to create #{POSTS_TABLE_NAME} table in DynamoDB")
              break
            end
            sleep(1)
            waited += 1
          end
        end
      end
    end
  end
end
