require 'bundler/setup'
require 'json'
require 'rspotify'
require 'date'

def main()
    clientIds = ENV["CLIENT_IDS"].split(',')
    clientSecrets = ENV["CLIENT_SECRETS"].split(',')

    hour = Integer(DateTime.now.strftime('%H'))

    secretIndex = hour % 8
    clientId = clientIds[secretIndex]
    clientSecret = clientSecrets[secretIndex]

    RSpotify.authenticate(clientId, clientSecret)

    artist_ids_file = File.read('input/artists.json')
    artist_ids = JSON.parse(artist_ids_file)
    chunk_size = (artist_ids.length / 24).floor
    chunk = artist_ids.each_slice(chunk_size).to_a()[hour - 1]

    new_artist_ids = []

    chunk.each_slice(50) do |artist_ids_chunk|
        artists = RSpotify::Artist.find(artist_ids_chunk)
        artists.each_with_index do |artist, index|
            # Manually slow down the loop every 5th iteration since we're making an additional API call per artist we track
            if index % 5 === 0
                sleep(0.5)
            end

            save_artist_json_file(artist)
            related_artists = artist.related_artists
            related_artists.each do |related_artist|
                save_artist_json_file(related_artist)

                if !artist_ids.include?(related_artist.id)
                    new_artist_ids.push(related_artist.id)
                end
            end
        end
    end

    save_artists_json_file(artist_ids.concat(new_artist_ids))
end

def save_artists_json_file(artist_ids)
    File.write("input/artists.json", JSON.pretty_generate(artist_ids))
end

def save_artist_json_file(artist)
    File.write("output/#{artist.id}.json", json_stringify_artist(artist))
end

def json_stringify_artist(artist)
    artist_object = {
        'id' => artist.id,
        'name' => artist.name,
        'uri' => artist.uri,
        'followers' => artist.followers,
        'genres' => artist.genres,
        'images' => artist.images,
        'popularity' => artist.popularity,
        'external_urls' => artist.external_urls,
    }
    return JSON.pretty_generate(artist_object)
end

main()
