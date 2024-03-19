
import Foundation

class Activity : Codable {
    
	let s_price : MultipleValues?
    let userData: Publisher?
    let sTime, sName, sDuration: String?
    let sThumbnail: String?
    let sID: Int?
    let sURL: String?
    let sAudioID: String?
    let sCategory: String?
    let aID: Int?
    let aType: String?
    let aOwner: Bool?
    let activityTime: String?
    let activityTimeFormatted: String?
    let activityText: String?
    let albumText: String?
    let isSongOwner: Bool?
    let sPrice: Double?
    let album: Album?
    let trackData: Song?
    let event_data: Events?
    
	enum CodingKeys: String, CodingKey {
		case s_price = "s_price"		        
        case userData = "USER_DATA"
        case sTime = "s_time"
        case sName = "s_name"
        case sDuration = "s_duration"
        case sThumbnail = "s_thumbnail"
        case sID = "s_id"
        case sURL = "s_url"
        case sAudioID = "s_audio_id"
        case sCategory = "s_category"
        case aID = "a_id"
        case aType = "a_type"
        case aOwner = "a_owner"
        case activityTime = "activity_time"
        case activityTimeFormatted = "activity_time_formatted"
        case activityText = "activity_text"
        case albumText = "album_text"
        case sPrice = "s_Price"
        case isSongOwner
        case trackData
        case event_data
        case album
	}
}
