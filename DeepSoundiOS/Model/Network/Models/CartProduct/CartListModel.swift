import Foundation

class CartListModel: BaseModel {
    struct CartListSuccessModel: Codable {
        var status : Int
        var array : [CartModel]
        
        enum CodingKeys: String, CodingKey {

            case status = "status"
            case array = "array"
        }
    }
}

struct CartModel : Codable {
    var id : Int
    var user_id : Int
    var product_id : Int
    var units : Int
    var product : Product

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case user_id = "user_id"
        case product_id = "product_id"
        case units = "units"
        case product = "product"
    }
}

class ReviewListModel: BaseModel {
    struct ReviewListSuccessModel: Codable {
        var status : Int
        var data : [ReviewModel]
        
        enum CodingKeys: String, CodingKey {
            case status = "status"
            case data = "data"
        }
    }
}

struct ReviewModel : Codable {
    let id : Int
    let user_id : Int
    let product_id : Int
    let review : String
    let star : Int
    let time : Int
    let user_data : Publisher
    
    enum CodingKeys: String, CodingKey {

        case id = "id"
        case user_id = "user_id"
        case product_id = "product_id"
        case review = "review"
        case star = "star"
        case time = "time"
        case user_data = "user_data"
    }
}
