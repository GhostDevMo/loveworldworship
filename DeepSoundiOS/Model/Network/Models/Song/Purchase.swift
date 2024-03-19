
import Foundation

struct Purchase : Codable {
	let id : Int?
	let user_id : Int?
	let event_id : Int?
	let order_hash_id : String?
	let track_id : Int?
	let track_owner_id : Int?
	let title : String?
	let final_price : Int?
	let commission : Int?
	let price : Double?
	let timestamp : String?
	let time : Int?
	let songData : Song?

    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case user_id = "user_id"
        case event_id = "event_id"
        case order_hash_id = "order_hash_id"
        case track_id = "track_id"
        case track_owner_id = "track_owner_id"
        case title = "title"
        case final_price = "final_price"
        case commission = "commission"
        case price = "price"
        case timestamp = "timestamp"
        case time = "time"
        case songData = "songData"
    }
}
