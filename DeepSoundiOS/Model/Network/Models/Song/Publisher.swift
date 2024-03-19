/* 
Copyright (c) 2023 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation

struct Publisher : Codable {
    let id : Int?
    let username : String?
    let email : String?
    let ip_address : String?
    let password : String?
    let name : String?
    let gender : String?
    let email_code : String?
    let language : String?
    let avatar : String?
    let cover : String?
    let src : String?
    let country_id : Int?
    let age : Int?
    let about : String?
    let google : String?
    let facebook : String?
    let twitter : String?
    let instagram : String?
    let linkedIn : String?
    let vk : String?
    let qq : String?
    let wechat : String?
    let discord : String?
    let mailru : String?
    let active : Int?
    let admin : Int?
    let verified : Int?
    let last_active : Int?
    let registered : String?
    let uploads : MultipleValues?
    let wallet : String?
    let balance : String?
    let website : String?
    let artist : Int?
    let is_pro : Int?
    let pro_type : Int?
    let pro_time : Int?
    let last_follow_id : Int?
    let ios_device_id : String?
    let android_device_id : String?
    let web_device_id : String?
    let two_factor : Int?
    let two_factor_hash : String?
    let new_email : String?
    let two_factor_verified : Int?
    let new_phone : String?
    let phone_number : String?
    let last_login_data : String?
    let referrer : Int?
    let ref_user_id : Int?
    let upload_import : Int?
    let paypal_email : String?
    let info_file : String?
    let time_code_sent : Int?
    let time : Int?
    let permission : String?
    let email_privacy : Email_privacy?
    let or_avatar : String?
    let or_cover : String?
    let url : String?
    let about_decoded : String?
    let org_wallet : String?
    let wallet_format : String?
    let or_balance : MultipleValues?
    let name_v : String?
    let country_name : String?
    var is_following : Bool
    let email_on_follow_user : MultipleValues?
    let email_on_liked_track : MultipleValues?
    let email_on_liked_comment : MultipleValues?
    let email_on_artist_status_changed : MultipleValues?
    let email_on_receipt_status_changed : MultipleValues?
    let email_on_new_track : MultipleValues?
    let email_on_reviewed_track : MultipleValues?
    let email_on_comment_replay_mention : MultipleValues?
    let email_on_comment_mention : MultipleValues?
    let gender_text : String?
    let is_blocked: Bool?
    let followers: [[Publisher]]?
    let following: [[Publisher]]?
    let albums: [[Album]]?
    let playlists: [[Playlist]]?
    let recently_played: [[Song]]?
    let liked: [[Song]]?
    var activities: [[Activity]]?
    var latestsongs: [[Song]]?
    var top_songs: [[Song]]?
    var store: [[Song]]?
    var stations: [[Song]]?
    var events: [Events]?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case username = "username"
        case email = "email"
        case ip_address = "ip_address"
        case password = "password"
        case name = "name"
        case gender = "gender"
        case email_code = "email_code"
        case language = "language"
        case avatar = "avatar"
        case cover = "cover"
        case src = "src"
        case country_id = "country_id"
        case age = "age"
        case about = "about"
        case google = "google"
        case facebook = "facebook"
        case twitter = "twitter"
        case instagram = "instagram"
        case linkedIn = "linkedIn"
        case vk = "vk"
        case qq = "qq"
        case wechat = "wechat"
        case discord = "discord"
        case mailru = "mailru"
        case active = "active"
        case admin = "admin"
        case verified = "verified"
        case last_active = "last_active"
        case registered = "registered"
        case uploads = "uploads"
        case wallet = "wallet"
        case balance = "balance"
        case website = "website"
        case artist = "artist"
        case is_pro = "is_pro"
        case pro_type = "pro_type"
        case pro_time = "pro_time"
        case last_follow_id = "last_follow_id"
        case ios_device_id = "ios_device_id"
        case android_device_id = "android_device_id"
        case web_device_id = "web_device_id"
        case two_factor = "two_factor"
        case two_factor_hash = "two_factor_hash"
        case new_email = "new_email"
        case two_factor_verified = "two_factor_verified"
        case new_phone = "new_phone"
        case phone_number = "phone_number"
        case last_login_data = "last_login_data"
        case referrer = "referrer"
        case ref_user_id = "ref_user_id"
        case upload_import = "upload_import"
        case paypal_email = "paypal_email"
        case info_file = "info_file"
        case time_code_sent = "time_code_sent"
        case time = "time"
        case permission = "permission"
        case email_privacy = "email_privacy"
        case or_avatar = "or_avatar"
        case or_cover = "or_cover"
        case url = "url"
        case about_decoded = "about_decoded"
        case org_wallet = "org_wallet"
        case wallet_format = "wallet_format"
        case or_balance = "or_balance"
        case name_v = "name_v"
        case country_name = "country_name"
        case is_following = "is_following"
        case email_on_follow_user = "email_on_follow_user"
        case email_on_liked_track = "email_on_liked_track"
        case email_on_liked_comment = "email_on_liked_comment"
        case email_on_artist_status_changed = "email_on_artist_status_changed"
        case email_on_receipt_status_changed = "email_on_receipt_status_changed"
        case email_on_new_track = "email_on_new_track"
        case email_on_reviewed_track = "email_on_reviewed_track"
        case email_on_comment_replay_mention = "email_on_comment_replay_mention"
        case email_on_comment_mention = "email_on_comment_mention"
        case gender_text = "gender_text"
        case is_blocked = "is_blocked"
        case followers = "followers"
        case following = "following"
        case albums = "albums"
        case playlists = "playlists"
        case recently_played = "recently_played"
        case liked = "liked"
        case activities = "activities"
        case latestsongs = "latestsongs"
        case top_songs = "top_songs"
        case store = "store"
        case stations = "stations"
        case events = "events"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        username = try values.decodeIfPresent(String.self, forKey: .username)
        email = try values.decodeIfPresent(String.self, forKey: .email)
        ip_address = try values.decodeIfPresent(String.self, forKey: .ip_address)
        password = try values.decodeIfPresent(String.self, forKey: .password)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        gender = try values.decodeIfPresent(String.self, forKey: .gender)
        email_code = try values.decodeIfPresent(String.self, forKey: .email_code)
        language = try values.decodeIfPresent(String.self, forKey: .language)
        avatar = try values.decodeIfPresent(String.self, forKey: .avatar)
        cover = try values.decodeIfPresent(String.self, forKey: .cover)
        src = try values.decodeIfPresent(String.self, forKey: .src)
        country_id = try values.decodeIfPresent(Int.self, forKey: .country_id)
        age = try values.decodeIfPresent(Int.self, forKey: .age)
        about = try values.decodeIfPresent(String.self, forKey: .about)
        google = try values.decodeIfPresent(String.self, forKey: .google)
        facebook = try values.decodeIfPresent(String.self, forKey: .facebook)
        twitter = try values.decodeIfPresent(String.self, forKey: .twitter)
        instagram = try values.decodeIfPresent(String.self, forKey: .instagram)
        linkedIn = try values.decodeIfPresent(String.self, forKey: .linkedIn)
        vk = try values.decodeIfPresent(String.self, forKey: .vk)
        qq = try values.decodeIfPresent(String.self, forKey: .qq)
        wechat = try values.decodeIfPresent(String.self, forKey: .wechat)
        discord = try values.decodeIfPresent(String.self, forKey: .discord)
        mailru = try values.decodeIfPresent(String.self, forKey: .mailru)
        active = try values.decodeIfPresent(Int.self, forKey: .active)
        admin = try values.decodeIfPresent(Int.self, forKey: .admin)
        verified = try values.decodeIfPresent(Int.self, forKey: .verified)
        last_active = try values.decodeIfPresent(Int.self, forKey: .last_active)
        registered = try values.decodeIfPresent(String.self, forKey: .registered)
        uploads = try values.decodeIfPresent(MultipleValues.self, forKey: .uploads)
        wallet = try values.decodeIfPresent(String.self, forKey: .wallet)
        balance = try values.decodeIfPresent(String.self, forKey: .balance)
        website = try values.decodeIfPresent(String.self, forKey: .website)
        artist = try values.decodeIfPresent(Int.self, forKey: .artist)
        is_pro = try values.decodeIfPresent(Int.self, forKey: .is_pro)
        pro_type = try values.decodeIfPresent(Int.self, forKey: .pro_type)
        pro_time = try values.decodeIfPresent(Int.self, forKey: .pro_time)
        last_follow_id = try values.decodeIfPresent(Int.self, forKey: .last_follow_id)
        ios_device_id = try values.decodeIfPresent(String.self, forKey: .ios_device_id)
        android_device_id = try values.decodeIfPresent(String.self, forKey: .android_device_id)
        web_device_id = try values.decodeIfPresent(String.self, forKey: .web_device_id)
        two_factor = try values.decodeIfPresent(Int.self, forKey: .two_factor)
        two_factor_hash = try values.decodeIfPresent(String.self, forKey: .two_factor_hash)
        new_email = try values.decodeIfPresent(String.self, forKey: .new_email)
        two_factor_verified = try values.decodeIfPresent(Int.self, forKey: .two_factor_verified)
        new_phone = try values.decodeIfPresent(String.self, forKey: .new_phone)
        phone_number = try values.decodeIfPresent(String.self, forKey: .phone_number)
        last_login_data = try values.decodeIfPresent(String.self, forKey: .last_login_data)
        referrer = try values.decodeIfPresent(Int.self, forKey: .referrer)
        ref_user_id = try values.decodeIfPresent(Int.self, forKey: .ref_user_id)
        upload_import = try values.decodeIfPresent(Int.self, forKey: .upload_import)
        paypal_email = try values.decodeIfPresent(String.self, forKey: .paypal_email)
        info_file = try values.decodeIfPresent(String.self, forKey: .info_file)
        time_code_sent = try values.decodeIfPresent(Int.self, forKey: .time_code_sent)
        time = try values.decodeIfPresent(Int.self, forKey: .time)
        permission = try values.decodeIfPresent(String.self, forKey: .permission)
        email_privacy = try values.decodeIfPresent(Email_privacy.self, forKey: .email_privacy)
        or_avatar = try values.decodeIfPresent(String.self, forKey: .or_avatar)
        or_cover = try values.decodeIfPresent(String.self, forKey: .or_cover)
        url = try values.decodeIfPresent(String.self, forKey: .url)
        about_decoded = try values.decodeIfPresent(String.self, forKey: .about_decoded)
        org_wallet = try values.decodeIfPresent(String.self, forKey: .org_wallet)
        wallet_format = try values.decodeIfPresent(String.self, forKey: .wallet_format)
        or_balance = try values.decodeIfPresent(MultipleValues.self, forKey: .or_balance)
        name_v = try values.decodeIfPresent(String.self, forKey: .name_v)
        country_name = try values.decodeIfPresent(String.self, forKey: .country_name)
        is_following = try values.decodeIfPresent(Bool.self, forKey: .is_following) ?? false
        email_on_follow_user = try values.decodeIfPresent(MultipleValues.self, forKey: .email_on_follow_user)
        email_on_liked_track = try values.decodeIfPresent(MultipleValues.self, forKey: .email_on_liked_track)
        email_on_liked_comment = try values.decodeIfPresent(MultipleValues.self, forKey: .email_on_liked_comment)
        email_on_artist_status_changed = try values.decodeIfPresent(MultipleValues.self, forKey: .email_on_artist_status_changed)
        email_on_receipt_status_changed = try values.decodeIfPresent(MultipleValues.self, forKey: .email_on_receipt_status_changed)
        email_on_new_track = try values.decodeIfPresent(MultipleValues.self, forKey: .email_on_new_track)
        email_on_reviewed_track = try values.decodeIfPresent(MultipleValues.self, forKey: .email_on_reviewed_track)
        email_on_comment_replay_mention = try values.decodeIfPresent(MultipleValues.self, forKey: .email_on_comment_replay_mention)
        email_on_comment_mention = try values.decodeIfPresent(MultipleValues.self, forKey: .email_on_comment_mention)
        gender_text = try values.decodeIfPresent(String.self, forKey: .gender_text)
        is_blocked = try values.decodeIfPresent(Bool.self, forKey: .is_blocked)
        followers = try values.decodeIfPresent([[Publisher]].self, forKey: .followers)
        following = try values.decodeIfPresent([[Publisher]].self, forKey: .following)
        albums = try values.decodeIfPresent([[Album]].self, forKey: .albums)
        playlists = try values.decodeIfPresent([[Playlist]].self, forKey: .playlists)
        recently_played = try values.decodeIfPresent([[Song]].self, forKey: .recently_played)
        liked = try values.decodeIfPresent([[Song]].self, forKey: .liked)
        activities = try values.decodeIfPresent([[Activity]].self, forKey: .activities)
        latestsongs = try values.decodeIfPresent([[Song]].self, forKey: .latestsongs)
        top_songs = try values.decodeIfPresent([[Song]].self, forKey: .top_songs)
        store = try values.decodeIfPresent([[Song]].self, forKey: .store)
        stations = try values.decodeIfPresent([[Song]].self, forKey: .stations)
        events = try values.decodeIfPresent([Events].self, forKey: .events)
    }
    
}
