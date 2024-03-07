 reddit-to-telegram
=======================
[![Gem Version](https://badge.fury.io/rb/reddit-to-telegram.svg)](https://badge.fury.io/rb/reddit-to-telegram)

#### Fetches hot posts from chosen subreddits and pushes them to Telegram channels.

Beware, this is remotely not production-ready, API will change, you'll see lots of bugs and it may break at any time.
Be sure to check for gem updates.

## Installation
In your `Gemfile` add:
```
gem "reddit-to-telegram"
```
Then run `bundle install`.

Or `gem install reddit-to-telegram`. Don't forget to `require` it.

## Prerequisites
- (Optionally) You'll need an [AWS account](https://aws.amazon.com/) to host a free SimpleDB (best available storage type, also default one). I also recommend hosting the bot on AWS lambda, since it would be free.
- (Optionally) [Create a Reddit app](https://www.reddit.com/prefs/apps), which would allow more requests to reddit
- [Obtain a telegram bot token](https://core.telegram.org/bots/tutorial#obtain-your-bot-token)

To run it, you'll need some env variables set.
```
RTT_AWS_ACCESS_KEY_ID= # (Optional) Your AWS access key ID. Needed for AWS SimpleDB storage.
RTT_AWS_DOMAIN_NAME= # (Optional) Domain name to use for SimpleDB
RTT_AWS_REGION= # (Optional) AWS region your SimpleDB will be hosted on. Beware, it's not available in all regions.
RTT_AWS_SECRET_ACCESS_KEY= # (Optional) Your AWS access key ID. Needed for AWS SimpleDB storage.
RTT_GOOGLE_API_KEY= # (Optional) Your Google API key to translate posts via Google Translate.
RTT_MAX_STORED_POSTS= # (Optional) Number of posts to store in the database to avoid duplicates, default is 25.
RTT_REDDIT_CLIENT_ID= # Reddit app credentials to access API. Might not be needed depending on setup, reddit allows some requests without authentication.
RTT_REDDIT_CLIENT_SECRET= # Reddit app credentials to access API. Might not be needed depending on setup, reddit allows some requests without authentication.
RTT_STORE_TYPE= # (Optional) Choose between aws_simple_db, memory or temp_file. Default is aws_simple_db, so if you're not specifying your AWS credentials, you have to specify another store type.
RTT_TELEGRAM_BOT_TOKEN= # The token you've received when you've created a telegram bot.
RTT_TEMP_DIR= (Optional) # Directory to write temp files to without trailing /
```

You can also set them dynamically:
```
RedditToTelegram::Variables.aws.access_key_id =
RedditToTelegram::Variables.telegram.bot_token =
```
Check out `lib/variables` for list of all available variables.

## Usage

1. Add the bot as administrator to Telegram channels you'd like to post to.
2. To fetch latest hot post which hasn't been pushed yet:
```
RedditToTelegram.hot(
    subreddit_name_1: :telegram_channel_id_1,
    subreddit_name_2: :telegram_channel_id_2
  )
```
Or to push one specific post (the only thing you need to set up for this is your telegram bot token):
```
RedditToTelegram.single("regular_link_to_post", :telegram_channel_id)
```
Use `:telegram_channel_id` without the `@`.

### Options

Translate option is supported. You will have to set up Google Translate API key and add it to env. You can find available languages in [Google Translate docs](https://cloud.google.com/translate/docs/languages).
```
RedditToTelegram.hot(
    { subreddit_name_1: :telegram_channel_id_1 },
    translate: :ja
  )
```
You can also specify if you want to add reddit link or telegram channel handle to the post text. By default they won't be added.
```
RedditToTelegram.hot(
    { subreddit_name_1: :telegram_channel_id_1 },
    add_reddit_link: true,
    add_channel_handle: true
  )
```
