#!/usr/bin/env ruby
#
# RedactDetect
# Copyright (C) 2015 Clemson University Social Analytics Institute
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
# USA
#
#
# http://www.clemson.edu/centers-institutes/social-analytics/
#

require "twitter"

if ARGF.filename == "-" and (STDIN.tty? or STDIN.closed?)
    STDERR.puts "Usage: redact_detect.rb [file ...]"
    exit 1
end

twitter_client = Twitter::REST::Client.new do |config|
    config.consumer_key        = ""
    config.consumer_secret     = ""
    config.access_token        = ""
    config.access_token_secret = ""
end

def lookup_ids(client, ids)
    begin
        response = client.statuses(ids)
        return response.map { |tweet| tweet.to_h }
    rescue Twitter::Error::TooManyRequests => error
        STDERR.puts "Received rate limit, sleeping for #{error.rate_limit.reset_in + 5} seconds..."
        sleep error.rate_limit.reset_in + 5
        STDERR.puts "Retrying..."
        retry
    end
end

num_redacted = 0
num_total = 0

tweet_ids = []
ARGF.each_line do |line|

    tweet_ids.push(line.chomp)

    if tweet_ids.count == 100
        num_total += 100
        response = lookup_ids(twitter_client, tweet_ids)
        response_ids = response.map { |t| t[:id_str] }
        tweet_ids.each do |id|
            unless response_ids.include?(id)
                puts id
                num_redacted += 1
            end
        end
        tweet_ids = []
    end
end

unless tweet_ids.empty?
    num_total += tweet_ids.count
    response = lookup_ids(twitter_client, tweet_ids)
    response_ids = response.map { |t| t[:id_str] }
    tweet_ids.each do |id|
        unless response_ids.include?(id)
            puts id
            num_redacted += 1
        end
    end
end

STDERR.puts "Summary: #{num_redacted} / #{num_total} Tweets redacted"

