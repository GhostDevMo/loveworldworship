
import Foundation

class Album : Codable {
	let id : Int?
	let album_id : String?
	let user_id : Int?
	let title : String?
	let description : String?
	let category_id : Int?
	let thumbnail : String?
	let time : Int?
	let registered : String?
	let price : MultipleValues?
	let purchases : Int?
	let thumbnail_original : String?
	let publisher : Publisher?
	let time_formatted : String?
	let url : String?
	let category_name : String?
	let is_purchased : Int?
	let isOwner : Bool?
	let count_songs : Int?
    let views : CountViews?

	enum CodingKeys: String, CodingKey {
		case id = "id"
		case album_id = "album_id"
		case user_id = "user_id"
		case title = "title"
		case description = "description"
		case category_id = "category_id"
		case thumbnail = "thumbnail"
		case time = "time"
		case registered = "registered"
		case price = "price"
		case purchases = "purchases"
		case thumbnail_original = "thumbnail_original"
		case publisher = "publisher"
		case time_formatted = "time_formatted"
		case url = "url"
		case category_name = "category_name"
		case is_purchased = "is_purchased"
		case isOwner = "IsOwner"
		case count_songs = "count_songs"
        case views = "views"
	}
}

enum MultipleValues: Codable {
    case integer(Int)
    case string(String)
    case double(Double)
    
    var stringValue : String? {
        guard case let .string(value) = self else { return nil }
        return value
    }
    
    var intValue : Int? {
        guard case let .integer(value) = self else { return nil }
        return value
    }
    
    var doubleValue : Double? {
        guard case let .double(value) = self else { return nil }
        return value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        if let x = try? container.decode(Double.self) {
            self = .double(x)
            return
        }
        throw DecodingError.typeMismatch(MultipleValues.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for CountViews"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        case .double(let x):
            try container.encode(x)
        }
    }
}
