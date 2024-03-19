import Foundation

struct Events : Codable {
	let id : Int?
	let hash_id : String?
	let user_id : Int?
	let name : String?
	let desc : String?
	let start_date : String?
	let start_time : String?
	let end_date : String?
	let end_time : String?
	let timezone : String?
	let online_url : String?
	let real_address : String?
	let available_tickets : Int?
	let ticket_price : Int?
	let image : String?
	let video : String?
	let p_240 : Int?
	let p_360 : Int?
	let p_480 : Int?
	let p_720 : Int?
	let p_1080 : Int?
	let p_2048 : Int?
	let p_4096 : Int?
	let time : Int?
	let org_image : String?
	let user_data : NullPublisherModel?
	let start_date_js : String?
	let url : String?
	let data_load : String?
	let edit_url : String?
	let edit_data_load : String?
	let is_joined : Int?
	let joined_count : Int?

	enum CodingKeys: String, CodingKey {

		case id = "id"
		case hash_id = "hash_id"
		case user_id = "user_id"
		case name = "name"
		case desc = "desc"
		case start_date = "start_date"
		case start_time = "start_time"
		case end_date = "end_date"
		case end_time = "end_time"
		case timezone = "timezone"
		case online_url = "online_url"
		case real_address = "real_address"
		case available_tickets = "available_tickets"
		case ticket_price = "ticket_price"
		case image = "image"
		case video = "video"
		case p_240 = "240p"
		case p_360 = "360p"
		case p_480 = "480p"
		case p_720 = "720p"
		case p_1080 = "1080p"
		case p_2048 = "2048p"
		case p_4096 = "4096p"
		case time = "time"
		case org_image = "org_image"
		case user_data = "user_data"
		case start_date_js = "start_date_js"
		case url = "url"
		case data_load = "data_load"
		case edit_url = "edit_url"
		case edit_data_load = "edit_data_load"
		case is_joined = "is_joined"
		case joined_count = "joined_count"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		hash_id = try values.decodeIfPresent(String.self, forKey: .hash_id)
		user_id = try values.decodeIfPresent(Int.self, forKey: .user_id)
		name = try values.decodeIfPresent(String.self, forKey: .name)
		desc = try values.decodeIfPresent(String.self, forKey: .desc)
		start_date = try values.decodeIfPresent(String.self, forKey: .start_date)
		start_time = try values.decodeIfPresent(String.self, forKey: .start_time)
		end_date = try values.decodeIfPresent(String.self, forKey: .end_date)
		end_time = try values.decodeIfPresent(String.self, forKey: .end_time)
		timezone = try values.decodeIfPresent(String.self, forKey: .timezone)
		online_url = try values.decodeIfPresent(String.self, forKey: .online_url)
		real_address = try values.decodeIfPresent(String.self, forKey: .real_address)
		available_tickets = try values.decodeIfPresent(Int.self, forKey: .available_tickets)
		ticket_price = try values.decodeIfPresent(Int.self, forKey: .ticket_price)
		image = try values.decodeIfPresent(String.self, forKey: .image)
		video = try values.decodeIfPresent(String.self, forKey: .video)
		p_240 = try values.decodeIfPresent(Int.self, forKey: .p_240)
		p_360 = try values.decodeIfPresent(Int.self, forKey: .p_360)
		p_480 = try values.decodeIfPresent(Int.self, forKey: .p_480)
		p_720 = try values.decodeIfPresent(Int.self, forKey: .p_720)
		p_1080 = try values.decodeIfPresent(Int.self, forKey: .p_1080)
		p_2048 = try values.decodeIfPresent(Int.self, forKey: .p_2048)
		p_4096 = try values.decodeIfPresent(Int.self, forKey: .p_4096)
		time = try values.decodeIfPresent(Int.self, forKey: .time)
		org_image = try values.decodeIfPresent(String.self, forKey: .org_image)
		user_data = try values.decodeIfPresent(NullPublisherModel.self, forKey: .user_data)
		start_date_js = try values.decodeIfPresent(String.self, forKey: .start_date_js)
		url = try values.decodeIfPresent(String.self, forKey: .url)
		data_load = try values.decodeIfPresent(String.self, forKey: .data_load)
		edit_url = try values.decodeIfPresent(String.self, forKey: .edit_url)
		edit_data_load = try values.decodeIfPresent(String.self, forKey: .edit_data_load)
		is_joined = try values.decodeIfPresent(Int.self, forKey: .is_joined)
		joined_count = try values.decodeIfPresent(Int.self, forKey: .joined_count)
	}
}
