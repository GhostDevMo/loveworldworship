
import Foundation

struct Playlist : Codable {
    
    let id : Int?
    let name : String?
    let user_id : Int?
    let privacy : Int?
    let thumbnail : String?
    let uid : String?
    let time : Int?
    let isOwner : Bool?
    let thumbnail_ready : String?
    let privacy_text : String?
    let url : String?
    let ajax_url : String?
    let songs : Int?
    let publisher : Publisher?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case user_id = "user_id"
        case privacy = "privacy"
        case thumbnail = "thumbnail"
        case uid = "uid"
        case time = "time"
        case isOwner = "IsOwner"
        case thumbnail_ready = "thumbnail_ready"
        case privacy_text = "privacy_text"
        case url = "url"
        case ajax_url = "ajax_url"
        case songs = "songs"
        case publisher = "publisher"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        user_id = try values.decodeIfPresent(Int.self, forKey: .user_id)
        privacy = try values.decodeIfPresent(Int.self, forKey: .privacy)
        thumbnail = try values.decodeIfPresent(String.self, forKey: .thumbnail)
        uid = try values.decodeIfPresent(String.self, forKey: .uid)
        time = try values.decodeIfPresent(Int.self, forKey: .time)
        isOwner = try values.decodeIfPresent(Bool.self, forKey: .isOwner)
        thumbnail_ready = try values.decodeIfPresent(String.self, forKey: .thumbnail_ready)
        privacy_text = try values.decodeIfPresent(String.self, forKey: .privacy_text)
        url = try values.decodeIfPresent(String.self, forKey: .url)
        ajax_url = try values.decodeIfPresent(String.self, forKey: .ajax_url)
        songs = try values.decodeIfPresent(Int.self, forKey: .songs)
        publisher = try values.decodeIfPresent(Publisher.self, forKey: .publisher)
    }
    
}
