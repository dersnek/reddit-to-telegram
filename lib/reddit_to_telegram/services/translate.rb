# frozen_string_literal: true

require "httparty"
require_relative "../errors"
require_relative "../store"

module RedditToTelegram
  module Services
    class Translate
      include HTTParty

      BASE_URI = "https://translation.googleapis.com/language/translate/v2"
      HEADERS = { "Content-Type" => "application/json; charset=utf-8", "Accept" => "application/json" }.freeze

      class << self
        def text(string, target_language)
          check

          res = HTTParty.post(
            BASE_URI,
            body: body(string, target_language),
            headers: HEADERS.merge(
              "X-goog-api-key" => Configuration.google.api_key
            )
          )
          res.dig("data", "translations")&.first&.dig("translatedText")
        end

        private

        def check
          return if Configuration.google.set_up?

          Errors.new(MissingConfiguration, "Missing Google credentials. Set them up or disable translation")
        end

        def body(string, target_language)
          {
            "q" => [string],
            "source" => "en",
            "target" => target_language,
            "format" => "text"
          }.to_json
        end
      end
    end
  end
end
