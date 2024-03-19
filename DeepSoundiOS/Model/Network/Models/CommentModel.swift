//
//  CommentModel.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 18/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
class GetCommentModel: BaseModel {
    
    struct GetCommentSuccessModel: Codable {
        let status: Int?
        let data: DataClass?
    }
    
    // MARK: - DataClass
    struct DataClass: Codable {
        let count: Int?
        let data: [Comment]?
    }
}

struct Comment: Codable {
    let id, trackID, userID: Int?
    let value: String?
    let time, orgPosted: Int?
    let posted, secondsFormated: String?
    var owner, isLikedComment: Bool
    var countLiked: Int
    let userData: Publisher?
    
    enum CodingKeys: String, CodingKey {
        case id
        case trackID = "track_id"
        case userID = "user_id"
        case value, time
        case orgPosted = "org_posted"
        case posted, secondsFormated, owner
        case isLikedComment = "IsLikedComment"
        case countLiked, userData
    }
}

class PostCommentModel: BaseModel {
    struct PostCommentSuccessModel: Codable {
        let status: Int?
        let data: DataClass?
    }
    
    // MARK: - DataClass
    struct DataClass: Codable {
        let id, commentSeconds, commentPercentage: Int?
        let userData: Publisher?
        let commentText, commentPostedTime: String?
        let commentSecondsFormatted, commentSongID: String?
        let commentSongTrackID: Int?
        
        enum CodingKeys: String, CodingKey {
            case id
            case commentSeconds = "comment_seconds"
            case commentPercentage = "comment_percentage"
            case userData = "USER_DATA"
            case commentText = "comment_text"
            case commentPostedTime = "comment_posted_time"
            case commentSecondsFormatted = "comment_seconds_formatted"
            case commentSongID = "comment_song_id"
            case commentSongTrackID = "comment_song_track_id"
        }
    }
}
class likeDisLikeCommentModel: BaseModel {
    struct likeDisLikeCommentSuccessModel: Codable {
        let status: Int?
    }
}
