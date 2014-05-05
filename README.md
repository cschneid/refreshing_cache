# RefreshingCache

*Motivation:* We have a background job that unpredictably sets a database row
that the application needs to be aware of on a regular, but delayed basis.  We
can't afford to check for an update every request, and the processing the app
needs to do when it does change is substantial, so we don't want to toss the
cache unnecessarily.

*What this is:* A hash wrapper that lets you set a timeout, a checking proc, and
a refresh proc.

* When a value isn't present, the refersh proc runs to populate the cache
* When the timeout gets hit, the check_proc runs to see if a refresh is
  actually required (just because it timed out doesn't mean the cache needs to be
  tossed)


## Installation

Add this line to your application's Gemfile:

    gem 'refreshing_cache'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install refreshing_cache

## Usage

```ruby
cache = RefreshingCache.new(timeout: 60,
                            check_proc: ->(key, last_refreshed) { Post.find_by_key(key).updated_at > last_refreshed },
                            value_proc: ->(key, last_refreshed) { Post.find_by_key(key).expensive_render } )

cache["post1"] # => Cache miss - calls expensive_render to generate a value

cache["post1"] # => Hasn't hit 60 seconds yet, no db hit

sleep 60
cache["post1"] # => 60 second timer is up, hits db to check if the post has been updated. It hasn't. Serves cached value

update_post!
cache["post1"] # => Hasn't hit 60 seconds since last check, so no db hit. Our cache is unfortunately stale.

sleep 60
cache["post1"] # => Hits the db, finds the post has changed, and calls the expensive_render call and serves that result.
```

## Contributing

1. Fork it ( http://github.com/cschneid/refreshing_cache/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

