 reddit-to-telegram
=======================
[![Gem Version](https://badge.fury.io/rb/reddit-to-telegram.svg)](https://badge.fury.io/rb/reddit-to-telegram)

#### Fetches hot posts from chosen subreddits and pushes them to Telegram channels.

Beware, this is remotely not production-ready, API will change, you'll see lots of bugs and it may break at any time.
Be sure to check for gem updates.

You can set this bot up absolutely for free [via AWS Lambda](https://gist.github.com/dersnek/851c32a6b45eab19f1c8748095b2a481#file-free-rtt-bot-in-aws-lambda), no ruby knowledge required.

## Installation
In your `Gemfile` add:
```
gem "reddit-to-telegram"
```
Then run `bundle install`.

Or `gem install reddit-to-telegram`. Don't forget to `require` it.

## Prerequisites
- [Obtain a telegram bot token](https://core.telegram.org/bots/tutorial#obtain-your-bot-token)
- (Optionally) You'll need an [AWS account](https://aws.amazon.com/) to host a free DynamoDB (best available storage type, also default one). I also recommend hosting the bot on AWS lambda, since it would be free.
- (Optionally) [Create a Reddit app](https://www.reddit.com/prefs/apps), which would allow more requests to reddit

It is pretty congifurable, either dynamically or via ENV variables.
To assign variables dynamically, set them via `RedditToTelegram.config.variable_name= `, e.g. `RedditToTelegram.config.aws.access_key_id = ...`.
You can also create an ENV variable with a corresponding name. Here is the full configuration explained. Required options have a * next to them.

Config variable           | Corresponding ENV Variable    | Description                                                                                                                                                                  |
| ----------------------- | ----------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
add_channel_handle        | -                             | Add channel handle to Telegram posts. Accepted values: true or false. Default is false                                                                                       |
add_reddit_link           | -                             | Add reddit link to Telegram posts. Accepted values: true or false. Default is false.                                                                                         |
logger                    | -                             | Which logger to use. You can pass your own ruby logger                                                                                                                       |
on_error                  | -                             | What to do when an error happens. Default is :log, but you can also :raise or :ignore                                                                                        |
send_errors_to_telegram   | -                             | Also log errors to telegram (besides regular logging). Accepted values: true or false, default is false                                                                      |
translate                 | -                             | Translate posts via Google Translate. Leave empty for no translation. More details below                                                                                     |
aws.access_key_id         | RTT_AWS_ACCESS_KEY_ID         | Your AWS access key ID. Needed for AWS DynamoDB storage                                                                                                                      |
aws.region                | RTT_AWS_REGION                | AWS region your DynamoDB is hosted on                                                                                                                                        |
aws.secret_access_key     | RTT_AWS_SECRET_ACCESS_KEY     | Your AWS access key ID. Needed for AWS DynamoDB storage.                                                                                                                     |
google.api_key            | RTT_GOOGLE_API_KEY            | Your Google API key to translate posts via Google Translate                                                                                                                  |
reddit.client_id          | RTT_REDDIT_CLIENT_ID          | Reddit app credentials to access API. Reddit allows more authenticated requests                                                                                              |
reddit.client_secret      | RTT_REDDIT_CLIENT_SECRET      | Reddit app credentials to access API. Reddit allows more authenticated requests                                                                                              |
store.max_stored_posts    | RTT_MAX_STORED_POSTS          | Number of posts to store in the database to avoid duplicates, default is 25                                                                                                  |
store.tmp_dir             | RTT_TEMP_DIR                  | Directory to write temp files to without trailing `/`                                                                                                                        |
store.type                | RTT_STORE_TYPE                | Choose between `aws_dynamo_db`, `memory` or `temp_file`. Default is `aws_dynamo_db`, so if you're not specifying your AWS credentials, you have to choose another store type |
telegram.bot_token *      | RTT_TELEGRAM_BOT_TOKEN        | The token you've received when you've created a telegram bot                                                                                                                 |
telegram.error_channel_id | RTT_TELEGRAM_ERROR_CHANNEL_ID | Telegram channel to send errors to (without `@`, only errors from Telegram API responses would be sent for now)                                                              |

## Usage

1. Add the bot as administrator to Telegram channels you'd like to post to.
2. To fetch latest hot post which hasn't been pushed yet:
```
RedditToTelegram.hot(
    telegram_channel_id_1: :subreddit_name_1,
    telegram_channel_id_2: :subreddit_name_2
  )
```
You can push posts from one subreddit to one telegram channel, several-to-one, one-to-several, several-to-several, whatever you like.
You can also push one specific post:
```
RedditToTelegram.from_link(telegram_channel_id: "regular_link_to_post")
```
Use `:telegram_channel_id` without the `@`.

### Translation

Translation option is supported.
You will have to set `RedditToTelegram.config.translate` to the language key you want to translate to. You can find available languages in [Google Translate docs](https://cloud.google.com/translate/docs/languages).
You will also have to set up Google Translate API key assign it to `RedditToTelegram.config.google.api_key`.
