# frozen_string_literal: true

require "httparty"
require_relative "../variables"

module RedditToTelegram
  module Reddit
    class Auth
      include HTTParty

      URI = "https://www.reddit.com/api/v1/access_token"
      PARAMS = { grant_type: "client_credentials" }.freeze
      HEADERS = { "Content-Type" => "application/x-www-form-urlencoded" }.freeze

      class << self
        def token
          HTTParty.post(
            URI,
            body: PARAMS,
            headers: HEADERS,
            basic_auth: { username: Variables.reddit.client_id, password: Variables.reddit.client_secret }
          )["access_token"]
        end
      end
    end
  end
end
