
import Foundation

struct Blog : Codable {
    
	let id : String?
	let title : String?
	let content : String?
	let description : String?
	let posted : String?
	let category : String?
	let thumbnail : String?
	let view : String?
	let shared : String?
	let tags : String?
	let created_at : String?
	let created_by : String?
	let url : String?

	enum CodingKeys: String, CodingKey {
		case id = "id"
		case title = "title"
		case content = "content"
		case description = "description"
		case posted = "posted"
		case category = "category"
		case thumbnail = "thumbnail"
		case view = "view"
		case shared = "shared"
		case tags = "tags"
		case created_at = "created_at"
		case created_by = "created_by"
		case url = "url"
	}
}
