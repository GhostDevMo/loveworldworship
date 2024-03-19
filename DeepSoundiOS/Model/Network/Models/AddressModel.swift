import Foundation

class AddressModel: BaseModel {
    
    struct AddressSuccessModel : Codable {
        
        let status : Int?
        let data : [AddressData]?
        
        enum CodingKeys: String, CodingKey {
            
            case status = "status"
            case data = "data"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            status = try values.decodeIfPresent(Int.self, forKey: .status)
            data = try values.decodeIfPresent([AddressData].self, forKey: .data)
        }
        
    }
    
    struct ManageAddressSuccessModel: Codable {
        
        let status: Int?
        let url: String?
        let message: String?
        
        enum CodingKeys: String, CodingKey {
            case status = "status"
            case url = "url"
            case message = "message"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            status = try values.decodeIfPresent(Int.self, forKey: .status)
            url = try values.decodeIfPresent(String.self, forKey: .url)
            message = try values.decodeIfPresent(String.self, forKey: .message)
        }
    }

    struct DeleteAddressSuccessModel: Codable {
        
        let status: Int?
        let message: String?
        
        enum CodingKeys: String, CodingKey {
            case status = "status"
            case message = "message"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            status = try values.decodeIfPresent(Int.self, forKey: .status)
            message = try values.decodeIfPresent(String.self, forKey: .message)
        }
        
    }
    
    struct GetByIdAddressSuccessModel: Codable {
        
        let status: Int?
        let data : AddressData?
        
        enum CodingKeys: String, CodingKey {
            case status = "status"
            case data = "data"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            status = try values.decodeIfPresent(Int.self, forKey: .status)
            data = try values.decodeIfPresent(AddressData.self, forKey: .data)
        }
        
    }
    
}


struct AddressData : Codable {
    let id : Int?
    let user_id : Int?
    let name : String?
    let phone : String?
    let country : String?
    let city : String?
    let zip : String?
    let address : String?
    let time : Int?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case user_id = "user_id"
        case name = "name"
        case phone = "phone"
        case country = "country"
        case city = "city"
        case zip = "zip"
        case address = "address"
        case time = "time"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        user_id = try values.decodeIfPresent(Int.self, forKey: .user_id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        phone = try values.decodeIfPresent(String.self, forKey: .phone)
        country = try values.decodeIfPresent(String.self, forKey: .country)
        city = try values.decodeIfPresent(String.self, forKey: .city)
        zip = try values.decodeIfPresent(String.self, forKey: .zip)
        address = try values.decodeIfPresent(String.self, forKey: .address)
        time = try values.decodeIfPresent(Int.self, forKey: .time)
    }
    
}
