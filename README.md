# arthistory

A repository for tracking Spotify artist changes over time.

## How it works

Every day the [`Sync`](./.github/workflows/sync.yml) workflow will run a Ruby script that hits the [Spotify API](https://developer.spotify.com/documentation/web-api/tutorials/getting-started) with the artist ids in the [`artists.json`](./input/artists.json) file. The data is saved by id in the [`output`](./output) directory, committed and pushed to the repository.

## Adding artists

Artist ids can be found by copying & pasting a link to the artist's profile from the Spotify web or desktop applications, which will be in the format: `https://open.spotify.com/artist/:artistId`. This id can then be added to the array in the [`artists.json`](./input/artists.json) file.

## Development

To run the script locally, you'll need [Ruby](https://www.ruby-lang.org/) installed. You'll also need a [Spotify Web API key](https://developer.spotify.com/documentation/web-api/tutorials/getting-started).

```sh
bundle install
CLIENT_ID=abc123 CLIENT_SECRET=xyz456 ruby src/main.rb
```

### Reference

This repository was inspired by a project for tracking Spotify changes that I didn't end up finishing. A few years later, [_Git scraping: track changes over time by scraping to a Git repository_](https://simonwillison.net/2020/Oct/9/git-scraping/) by Simon Willison showed up on HackerNews and inspired me to implement the core of my idea.
