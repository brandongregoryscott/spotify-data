require 'bundler/setup'
require 'json'
require 'rspotify'



def main()
    RSpotify.authenticate(ENV["CLIENT_ID"], ENV["CLIENT_SECRET"])

    artist_ids_file = File.read('input/artists.json')
    artist_ids = JSON.parse(artist_ids_file)

    new_artist_ids = []

    artist_ids.each_slice(50) do |artist_ids_chunk|
        artists = RSpotify::Artist.find(artist_ids_chunk)
        artists.each do |artist|
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