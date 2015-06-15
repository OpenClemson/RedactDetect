# RedactDetect

Given a list of Tweet IDs, detect which ones have been deleted or made private.

```Shell
./redact_detect.rb [file ...]
```

Each input file to redact_detect.rb should contain one Tweet ID per line. redact_detect.rb reads
the files in order and queries the [Twitter API](https://dev.twitter.com/rest/reference/get/statuses/lookup)
for the specified Tweet. If the Tweet is not found, its ID will be printed to standard output.
If file is a single dash ('-') or absent, redact_detect.rb will read from standard input.

NOTE: This script has no way of checking if a Tweet with the given ID did exist at some point in the
past. So it is dependent on receiving correct input from a past collection of Tweets.

## Requirements

This script requires the [Twitter gem](https://github.com/sferik/twitter).

It also requires a [Twitter OAuth application](https://apps.twitter.com/). Enter the client key and secret
and access tokens in the `Twitter::REST::Client.new` block on lines 33-36.
