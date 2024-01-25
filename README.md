 reddit-to-telegram
=======================
[![Gem Version](https://badge.fury.io/rb/reddit-to-telegram.svg)](https://badge.fury.io/rb/reddit-to-telegram)

#### Fetches hot posts from chosen subreddits and pushes them to Telegram channels.

Beware, this is remotely not production-ready and you'll see lots of bugs. Be sure to check for gem updates.

## Installation
In your `Gemfile` add:
```
gem "reddit-to-telegram"
```
Then run `bundle install`.

Or `gem install reddit-to-telegram`, but don't forget to `require` it first then.

## Prerequisites
- You need an AWS account to host a free SimpleDB (memory and local file storage options are available, but now way to switch for now)
- (Optionally) Create a Reddit app, which would allow more requests to reddit
- [Obtain](https://core.telegram.org/bots/tutorial#create-your-project) a telegram bot token

## Installation
To run it, you'll need some env variables set.
```
RTT_AWS_ACCESS_KEY_ID= # Your AWS access key ID. Needed for AWS SimpleDB storage.
RTT_AWS_REGION= # AWS region your SimpleDB will be hosted on. Beware, it's on available in all regions.
RTT_AWS_SECRET_ACCESS_KEY= # Your AWS access key ID. Needed for AWS SimpleDB storage.
RTT_MAX_STORED_POSTS= # Number of posts to store in the database to avoid duplicates, optional, default is 25.
RTT_REDDIT_CLIENT_ID= # Reddit app credentials to access API. Might not be needed depending on setup, reddit allows some requests without authentication.
RTT_REDDIT_CLIENT_SECRET= # Reddit app credentials to access API. Might not be needed depending on setup, reddit allows some requests without authentication.
RTT_TELEGRAM_BOT_TOKEN= # The token you've received when you've created a telegram bot.
```

You can also set them dynamically:
```
RedditToTelegram::Vars.assign_values(
  max_stored_posts:,
  aws_access_key_id:,
  aws_secret_access_key:,
  aws_region:,
  reddit_client_id:,
  reddit_client_secret:,
  telegram_bot_token:
)
```
## Usage

1. Add the bot you've created as administrator to Telegram channels you'd like to post to.
2.
```
RedditToTelegram.post(
    subreddit_name_1: :telegram_channel_id_1,
    subreddit_name_2: :telegram_channel_id_2
  )

```
Use `:telegram_channel_id` without the `@`.

## TODO
- Storage options
- Error handling (maybe send them to another channel in Telegram)
