# frozen_string_literal: true

require 'bundler/setup'
require 'json'
require 'rspotify'
require 'rest-client'

MAX_RETRIES = 50

def main
  authenticate

  artist_ids = read_artists_json_file
  sample_count = ARGV.first && !ARGV.first.empty? ? Integer(ARGV.first) : 50

  sampled_artist_ids = artist_ids.sample(sample_count)
  sampled_artist_ids.each_slice(50) do |artist_ids_chunk|
    artists = RSpotify::Artist.find(artist_ids_chunk)

    artists.each do |artist|
      related_artist_ids = find_related_artists(artist)
      artist_ids.concat(related_artist_ids)
    end
    save_artists_json_file(artist_ids.uniq.sort)
  end
end

def find_related_artists(artist, attempt = 1)
  related_artists = artist.related_artists
  related_artists.map(&:id)
rescue RestClient::TooManyRequests, RestClient::ServiceUnavailable, RestClient::InternalServerError
  max_sleep_seconds = Float(2**attempt)
  sleep rand(0..max_sleep_seconds)
  authenticate
  find_related_artists(artist, attempt + 1) if attempt < MAX_RETRIES
end

def authenticate
  client_ids = ENV['CLIENT_IDS'].split(',')
  client_secrets = ENV['CLIENT_SECRETS'].split(',')

  select_first_key = rand < 0.5
  client_id = select_first_key ? client_ids.first : client_ids.last
  client_secret = select_first_key ? client_secrets.first : client_secrets.last

  RSpotify.authenticate(client_id, client_secret)
end

def read_artists_json_file
  artist_ids_file = File.read('input/artists.json')
  JSON.parse(artist_ids_file)
end

def save_artists_json_file(artist_ids)
  File.write('input/artists.json', JSON.pretty_generate(artist_ids))
end

main
