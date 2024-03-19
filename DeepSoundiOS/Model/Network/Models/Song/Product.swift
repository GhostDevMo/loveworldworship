
import Foundation

struct Product : Codable {
	let id : Int?
	let hash_id : String?
	let user_id : Int?
	let title : String?
	let desc : String?
	let tags : String?
	let price : Int?
	let related_song : NullSongModel?
	let cat_id : Int?
	let units : Int?
	let active : Int?
	let time : Int?
	let images : [Images]?
	let user_data : NullPublisherModel?
	let url : String?
	let data_load : String?
	let edit_url : String?
	let edit_data_load : String?
	var added_to_cart : Int?
	let rating : MultipleValues?
	let reviews_count : Int?
	let formatted_price : String?
    
	enum CodingKeys: String, CodingKey {

		case id = "id"
		case hash_id = "hash_id"
		case user_id = "user_id"
		case title = "title"
		case desc = "desc"
		case tags = "tags"
		case price = "price"
		case related_song = "related_song"
		case cat_id = "cat_id"
		case units = "units"
		case active = "active"
		case time = "time"
		case images = "images"
		case user_data = "user_data"
		case url = "url"
		case data_load = "data_load"
		case edit_url = "edit_url"
		case edit_data_load = "edit_data_load"
		case added_to_cart = "added_to_cart"
		case rating = "rating"
		case reviews_count = "reviews_count"
		case formatted_price = "formatted_price"
	}
}
