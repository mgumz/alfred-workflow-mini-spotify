#!/bin/bash
#
# about: helper to collect current state of spotify and
# present it to Alfred.app so it can be shown. it tries
# to fetch the album artwork (only ones, it is cached
# in $cache_dir).

app_dir="/Applications/Spotify.app/Contents/Resources"
cache_dir=~/.cache/alfred-workflow-mini-spotify/album-artwork

mkdir -p "$cache_dir"

play_state=$(osascript -e 'tell application "Spotify" to player state as string')
icon_next="${app_dir}/Touchbar Forward.pdf"
icon_prev="${app_dir}/Touchbar Back.pdf"
icon_toggle="${app_dir}/Touchbar Pause.pdf"
[ "$play_state" == "playing" ] || icon_toggle="${app_dir}/Touchbar Play.pdf"

track_name=$(osascript -e 'tell app "Spotify" to name of current track as string')
album_name=$(osascript -e 'tell app "Spotify" to album of current track as string')
artist_name=$(osascript -e 'tell app "Spotify" to artist of current track as string')

aa_url=$(osascript -e 'tell app "Spotify" to artwork url of current track as string')
aa_cache_key=$(echo -n $aa_url | md5)
aa_cache_path="${cache_dir}/${aa_cache_key:0:2}/${aa_cache_key:2:6}/${aa_cache_key}.jpg"


# cache album artwork
[[ -f "$aa_cache_path" ]] || ( mkdir -p $(dirname "$aa_cache_path"); curl -sq -L -o "$aa_cache_path" "$aa_url" )

# create json formatted item list for Alfred.app
cat << EOB
{
	"items": [
		{
			"arg": "open spotify",
			"title": "$track_name",
			"subtitle": "$album_name - $artist_name",
			"icon": {
				"path": "$aa_cache_path"
			}
		},
		{
			"arg": "p",
			"title": "$track_name",
			"subtitle": "$album_name - $artist_name",
			"icon": {
				"path": "${icon_toggle}"
			}
		},
		{
			"arg": "next",
			"title": "next track",
			"subtitle": "$album_name - $artist_name",
			"icon": {
				"path": "${icon_next}"
			}
		},
		{
			"arg": "prev",
			"title": "previous track",
			"subtitle": "$album_name - $artist_name",
			"icon": {
				"path": "${icon_prev}"
			}
		}
	]
}
EOB

