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
RTT_AWS_ACCESS_KEY_ID= # Your AWS access key ID. Needed for AWS SimpleDB storage.
RTT_AWS_DOMAIN_NAME= # (Optional) Domain name to use for SimpleDB
RTT_AWS_REGION= # AWS region your SimpleDB will be hosted on. Beware, it's not available in all regions.
RTT_AWS_SECRET_ACCESS_KEY= # Your AWS access key ID. Needed for AWS SimpleDB storage.
RTT_MAX_STORED_POSTS= # (Optional) Number of posts to store in the database to avoid duplicates, default is 25.
RTT_REDDIT_CLIENT_ID= # Reddit app credentials to access API. Might not be needed depending on setup, reddit allows some requests without authentication.
RTT_REDDIT_CLIENT_SECRET= # Reddit app credentials to access API. Might not be needed depending on setup, reddit allows some requests without authentication.
RTT_STORE_TYPE= # (Optional) Choose between aws_simple_db, memory or temp_file
RTT_TELEGRAM_BOT_TOKEN= # The token you've received when you've created a telegram bot.
RTT_TEMP_DIR= (Optional) # Directory to write temp files to without trailing /
```

You can also set them dynamically:
```
RedditToTelegram::Variables.aws.aws_access_key_id =
RedditToTelegram::Variables.telegram.bot_token =
```
Check out `lib/variables` for list of all available variables.

## Usage

1. Add the bot as administrator to Telegram channels you'd like to post to.
2a. To fetch latest hot post which hasn't been pushed yet:
```
RedditToTelegram.hot(
    subreddit_name_1: :telegram_channel_id_1,
    subreddit_name_2: :telegram_channel_id_2
  )
```
2b. To push one specific post:
```
RedditToTelegram.single("regular_link_to_post", :telegram_channel_id)
```
Use `:telegram_channel_id` without the `@`.

## Known bugs
- Landscape videos are uploaded as square videos to Telegram
- Gallery image order is random
- Special characters are not unescaped in text/captions
- Imgur gifv links are not uploaded as videos/gifs

## Planned features
- Error handling
