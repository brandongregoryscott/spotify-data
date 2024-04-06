require 'json'

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