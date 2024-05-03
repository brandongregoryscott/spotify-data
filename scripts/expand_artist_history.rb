# frozen_string_literal: true

require 'bundler/setup'
require 'git'
require 'json'
require 'date'

def main
  repo = Git.open('.')

  artist_id = '6lcwlkAjBPSKnFBZjjZFJs'
  input_path = "output/#{artist_id}.json"
  output_path = "output/history_#{artist_id}.json"

  history = repo.log(1000).path(input_path).map do |item|
    historical_object = JSON.parse(repo.show(item.sha, input_path))

    timestamp = time_to_date(item.date)
    historical_object[:timestamp] = timestamp.iso8601

    historical_object
  end

  File.write(output_path, JSON.pretty_generate(history))
  puts("Saved history for #{artist_id} to #{output_path}")
end

def time_to_date(time)
  DateTime.new(time.year, time.month, time.day, time.hour, time.min, time.sec,
               Rational(time.gmt_offset / 3600, 24))
end

main
