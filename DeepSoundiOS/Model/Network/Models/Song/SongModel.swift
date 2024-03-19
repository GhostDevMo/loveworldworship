
import Foundation
class Song : Codable {
	let id : Int?
	let user_id : Int?
	let audio_id : String?
	let title : String?
	let description : String?
	let tags : String?
	let thumbnail : String?
	let availability : Int?
	let age_restriction : Int?
	let time : Int?
	let views : Int?
	let artist_id : Int?
	let album_id : Int?
	let price : Double?
	let duration : String?
	let demo_duration : String?
	let audio_location : String?
	let demo_track : String?
	let category_id : Int?
	let registered : String?
	let size : Int?
	let dark_wave : String?
	let light_wave : String?
	let shares : Int?
	let spotlight : Int?
	let ffmpeg : Int?
	let lyrics : String?
	let allow_downloads : Int?
	let display_embed : Int?
	let sort_order : Int?
	let src : String?
	let converted : Int?
	let itunes_token : String?
	let itunes_affiliate_url : String?
	let thumbnail_original : String?
	let audio_location_original : String?
	let publisher : Publisher?
	let org_description : String?
	let time_formatted : String?
	let tags_default : String?
	let tags_array : [String]?
	let tagsFiltered : [String]?
	let url : String?
	let category_name : String?
	let secure_url : String?
	let songArray : Activity?
	let count_likes : CountViews?
	let count_dislikes : CountViews?
	let count_views : CountViews?
	let count_shares : CountViews?
	let count_comment : CountViews?
	let count_favorite : CountViews?
	let isDisLiked : LikeBoolORInt?
	let isOwner : Bool?
	var isLiked : Bool?
	var is_favoriated : Bool?
	let can_listen : Bool?
	let album_name : String?
	let itunes_token_url : String?
	let youtube_url : String?
	let deezer_url : String?
	let tagged_artists : [String]?
	let is_reported : Int?
	let is_purchased : Bool?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case user_id = "user_id"
        case audio_id = "audio_id"
        case title = "title"
        case description = "description"
        case tags = "tags"
        case thumbnail = "thumbnail"
        case availability = "availability"
        case age_restriction = "age_restriction"
        case time = "time"
        case views = "views"
        case artist_id = "artist_id"
        case album_id = "album_id"
        case price = "price"
        case duration = "duration"
        case demo_duration = "demo_duration"
        case audio_location = "audio_location"
        case demo_track = "demo_track"
        case category_id = "category_id"
        case registered = "registered"
        case size = "size"
        case dark_wave = "dark_wave"
        case light_wave = "light_wave"
        case shares = "shares"
        case spotlight = "spotlight"
        case ffmpeg = "ffmpeg"
        case lyrics = "lyrics"
        case allow_downloads = "allow_downloads"
        case display_embed = "display_embed"
        case sort_order = "sort_order"
        case src = "src"
        case converted = "converted"
        case itunes_token = "itunes_token"
        case itunes_affiliate_url = "itunes_affiliate_url"
        case thumbnail_original = "thumbnail_original"
        case audio_location_original = "audio_location_original"
        case publisher = "publisher"
        case org_description = "org_description"
        case time_formatted = "time_formatted"
        case tags_default = "tags_default"
        case tags_array = "tags_array"
        case tagsFiltered = "tagsFiltered"
        case url = "url"
        case category_name = "category_name"
        case secure_url = "secure_url"
        case songArray = "songArray"
        case count_likes = "count_likes"
        case count_dislikes = "count_dislikes"
        case count_views = "count_views"
        case count_shares = "count_shares"
        case count_comment = "count_comment"
        case count_favorite = "count_favorite"
        case isDisLiked = "isDisLiked"
        case isOwner = "IsOwner"
        case isLiked = "IsLiked"
        case is_favoriated = "is_favoriated"
        case can_listen = "can_listen"
        case album_name = "album_name"
        case itunes_token_url = "itunes_token_url"
        case youtube_url = "youtube_url"
        case deezer_url = "deezer_url"
        case tagged_artists = "tagged_artists"
        case is_reported = "is_reported"
        case is_purchased = "is_purchased"
    }
}

enum CountViews: Codable {
    case integer(Int)
    case string(String)
    
    var stringValue : String? {
        guard case let .string(value) = self else { return nil }
        return value
    }
    
    var intValue : Int? {
        guard case let .integer(value) = self else { return nil }
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
        throw DecodingError.typeMismatch(CountViews.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for CountViews"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}

enum LikeBoolORInt: Codable {
    case integer(Int)
    case bool(Bool)
    
    var boolValue : Bool? {
        guard case let .bool(value) = self else { return nil }
        return value
    }
    
    var intValue : Int? {
        guard case let .integer(value) = self else { return nil }
        return value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        if let x = try? container.decode(Bool.self) {
            self = .bool(x)
            return
        }
        throw DecodingError.typeMismatch(LikeBoolORInt.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for CountViews"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let x):
            try container.encode(x)
        case .bool(let x):
            try container.encode(x)
        }
    }
}
