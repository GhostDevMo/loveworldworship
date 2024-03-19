//
//  ArticlesModel.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/10/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import Foundation

class GetArticlesModel: BaseModel {
    struct GetArticlesSuccessModel: Codable {
        var status: Int?
        var data: [Blog]?
        
        enum CodingKeys: String, CodingKey {
            case status = "status"
            case data = "data"
        }
    }
}

class GetArticlesCommentsModel: BaseModel {

    struct GetArticlesCommentsSuccessModel: Codable {
        let status: Int?
        let data: [BlogComment]?
    }
}

// MARK: - Datum
struct BlogComment: Codable {
    let id, articleID, userID: Int?
    let value: String?
    let time, orgPosted: Int?
    let posted, secondsFormated: String?
    let replies: [JSONAny]?
    let trackID: Int?
    let owner, is_reported, isLikedComment: Bool
    let countLiked: Int?
    let userData: Publisher?

    enum CodingKeys: String, CodingKey {
        case id
        case articleID = "article_id"
        case userID = "user_id"
        case value, time
        case orgPosted = "org_posted"
        case posted, secondsFormated, owner, replies
        case trackID = "track_id"
        case isLikedComment = "IsLikedComment"
        case is_reported = "is_reported"
        case countLiked
        case userData = "user_data"
    }
}

class CreateArticleCommentModel: BaseModel {
  

    // MARK: - Welcome
    struct CreateArticleCommentSuccessModel: Codable {
        let status: Int?
        let data: DataClass?
    }
    // MARK: - DataClass
    struct DataClass: Codable {
        let id, articleID, userID: Int?
        let value: String?
        let time: Int?
        let posted: String?
        let owner, isLikedComment: Bool?
        let countLiked: Int?
        let userData: Publisher?
        
        enum CodingKeys: String, CodingKey {
            case id
            case articleID = "article_id"
            case userID = "user_id"
            case value, time, posted, owner
            case isLikedComment = "IsLikedComment"
            case countLiked
            case userData = "user_data"
        }
    }
}
