require 'bundler/setup'
require 'json'
require 'rspotify'
require_relative './json_stringifier'

RSpotify.authenticate(ENV["CLIENT_ID"], ENV["CLIENT_SECRET"])

artist_ids_file = File.read('./artists.json')
artist_ids = JSON.parse(artist_ids_file)

artist_ids.each_slice(50) do |artist_ids_chunk|
    artists = RSpotify::Artist.find(artist_ids_chunk)
    artists.each do |artist|
        File.write("out/#{artist.id}.json", json_stringify_artist(artist))
    end
end
