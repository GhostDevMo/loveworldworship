
//
//  MusicPlayerModel.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 17/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation

struct MusicPlayerModel:Codable {
    var name:String?
    var time:String?
    var title:String?
    var musicType:String?
    var ThumbnailImageString:String?
    var likeCount:Int?
    var favoriteCount:Int?
    var recentlyPlayedCount:Int?
    var sharedCount:Int?
    var commentCount:Int?
    var likeCountString:String?
    var favoriteCountString:String?
    var recentlyPlayedCountString:String?
    var sharedCountString:String?
    var commentCountString:String?
    var audioString:String?
    var audioID:String?
    var isLiked:Bool?
    var isFavorite:Bool?
    var trackId:Int?
    var isDemoTrack:Bool?
    var isPurchased:Bool?
    var isOwner:Bool?
    var duration:String?
}
