//
//  GetChatsModel.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/12/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import Foundation
class GetChatsModel: BaseModel {
    // MARK: - Welcome
    struct GetChatsSuccessModel: Codable {
        let status: Int
        let data: [ChatConversationModel]
    }
}


// MARK: - Datum
struct ChatConversationModel: Codable {
    let user: Publisher
    let getCountSeen: Int
    let getLastMessage: GetMessage
    let chatTime: Int

    enum CodingKeys: String, CodingKey {
        case user
        case getCountSeen = "get_count_seen"
        case getLastMessage = "get_last_message"
        case chatTime = "chat_time"
    }
}

// MARK: - GetLastMessage
struct GetMessage: Codable {
    let id, fromID, toID: Int
    let text: String
    let seen, time, fromDeleted, toDeleted: Int
    let sentPush: Int
    let notificationID, typeTwo, image, fullImage: String
    let apiPosition, apiType: String

    enum CodingKeys: String, CodingKey {
        case id
        case fromID = "from_id"
        case toID = "to_id"
        case text, seen, time
        case fromDeleted = "from_deleted"
        case toDeleted = "to_deleted"
        case sentPush = "sent_push"
        case notificationID = "notification_id"
        case typeTwo = "type_two"
        case image
        case fullImage = "full_image"
        case apiPosition = "API_position"
        case apiType = "API_type"
    }
}

class GetChatMessagesModel: BaseModel {
    struct GetChatMessagesSuccessModel: Codable {
        let status: Int?
        let data: [GetMessage]?
    }
}

class SendMessageModel: BaseModel {
    struct SendMessageSuccessModel: Codable {
        var status, messageID: Int?
        var data: DataClass?

        enum CodingKeys: String, CodingKey {
            case status
            case messageID = "message_id"
            case data
        }
    }

    // MARK: - DataClass
    struct DataClass: Codable {
        var id, fromID, toID: Int?
        var text: String?
        var seen, time, fromDeleted, toDeleted: Int?
        var sentPush: Int?
        var notificationID, typeTwo, image, fullImage: String?
        var apiPosition, apiType, hash: String?

        enum CodingKeys: String, CodingKey {
            case id
            case fromID = "from_id"
            case toID = "to_id"
            case text, seen, time
            case fromDeleted = "from_deleted"
            case toDeleted = "to_deleted"
            case sentPush = "sent_push"
            case notificationID = "notification_id"
            case typeTwo = "type_two"
            case image
            case fullImage = "full_image"
            case apiPosition = "API_position"
            case apiType = "API_type"
            case hash
        }
    }

}
class DeleteChatModel: BaseModel {
    struct DeleteChatSuccessModel: Codable {
        var status: Int?
        var data: String?
    }
}
