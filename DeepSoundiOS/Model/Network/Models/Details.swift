
import Foundation

struct Details : Codable {
	let followers : Int?
	let following : Int?
	let albums : Int?
	let playlists : Int?
	let blocks : Int?
	let favourites : Int?
	let recently_played : Int?
	let liked : Int?
	let activities : Int?
	let latest_songs : Int?
	let top_songs : Int?
	let store : Int?
	let stations : Int?

	enum CodingKeys: String, CodingKey {

		case followers = "followers"
		case following = "following"
		case albums = "albums"
		case playlists = "playlists"
		case blocks = "blocks"
		case favourites = "favourites"
		case recently_played = "recently_played"
		case liked = "liked"
		case activities = "activities"
		case latest_songs = "latest_songs"
		case top_songs = "top_songs"
		case store = "store"
		case stations = "stations"
	}
}
