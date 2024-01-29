# frozen_string_literal: true

require "aws-sdk-simpledb"
require "json"
require_relative "../variables"

module RedditToTelegram
  module Store
    class AWSSimpleDB
      ITEM_NAME = "cached_data"

      class << self
        def client
          @client ||= Aws::SimpleDB::Client.new(
            access_key_id: Variables.aws.access_key_id,
            secret_access_key: Variables.aws.secret_access_key,
            region: Variables.aws.region
          )
        end

        private

        attr_reader :reddit_token

        def setup
          create_domain unless client.list_domains.domain_names.include?(Variables.aws.domain_name)
          read_db
        end

        def reddit_token=(val)
          @reddit_token = val
          write_db
        end

        def add_post(subreddit, id)
          @posts[subreddit] = [] if @posts[subreddit].nil?
          @posts[subreddit] << id
          @posts[subreddit].shift if @posts[subreddit].count > Store::MAX_STORED_POSTS
          write_db
        end

        def dup_post?(subreddit, id)
          return false if @posts[subreddit].nil?

          @posts[subreddit].include?(id)
        end

        def read_db
          res = client.get_attributes(
            {
              domain_name: Variables.aws.domain_name,
              item_name: "cached_data",
              consistent_read: true
            }
          )

          return assign_default_values if res.attributes.empty?

          assign_values_from_db(res)
        end

        def assign_values_from_db(data)
          @reddit_token = data.attributes.find { |a| a.name == "reddit_token" }.value || ""
          @posts = {}
          data.attributes.each do |attr|
            @posts[attr.name.split("_").last.to_sym] = JSON.parse(attr.value) if attr.name.match?(/posts_.+/)
          end
        end

        def write_db
          client.put_attributes(
            {
              domain_name: Variables.aws.domain_name,
              item_name: ITEM_NAME,
              attributes: prepare_db_attrs
            }
          )
        end

        def prepare_db_attrs
          attrs = [
            {
              name: "reddit_token",
              value: @reddit_token,
              replace: true
            }
          ]

          @posts.each do |subreddit, values|
            attrs << { name: "posts_#{subreddit}", value: values.to_json, replace: true }
          end

          attrs
        end

        def assign_default_values
          @reddit_token = ""
          @posts = {}
        end

        def create_domain
          res = client.list_domains
          return unless res.successful?

          return if res.domain_names.include?(Variables.aws.domain_name)

          client.create_domain({ domain_name: Variables.aws.domain_name })
        end
      end
    end
  end
end
