//
//  Protocols.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 22/06/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import UIKit
import DeepSoundSDK

protocol showReportScreenDelegate {
    func showReportScreen(Status:Bool,IndexPath:Int,songLink:String)
}
protocol didSetInterestGenres {
    func didSetInterest(Label:UILabel,Image:UIImageView,status:Bool,idsArray:[GenresModel.Datum],Index:Int)
}
protocol followUserDelegate {
    func followUser(index:Int,button:UIButton,status:Bool)
}
protocol unFollowUserDelegate {
     func unFollowUser(index:Int)
}
protocol showToastStringDelegate {
    func showToastString(string:String)
}
protocol showToastStringForBlockUserDelegate {
    func showToastStringForBlockUser(string:String,status:Bool)
}
protocol showPlaylistPopupDelegate {
    func showPlaylistPopup(status:Bool,index:Int)
}
protocol deletePlaylisttPopupDelegate {
    func deletePlaylistPopup(status:Bool,playlistID:Int)
}
protocol updatePlaylistDelegate {
    func updatePlaylistPlaylist(status:Bool,object:PlaylistModel.Playlist)
}

protocol likeDislikeSongDelegate {
    func likeDisLikeSong(status:Bool,button:UIButton,audioId:String)
}

protocol likeDislikeCommentDelegate {
    func likeDisLikeComment(status:Bool,button:UIButton,commentId:Int)
}
protocol didSetPlaylistDelegate {
    func didPlaylist(Image:UIImageView,status:Bool,idsArray:[PlaylistModel.Playlist],Index:Int)
}
protocol didSetGenrestDelegate {
    func didSetGenres(Image:UIImageView,status:Bool,idsArray:[GenresModel.Datum],Index:Int)
}
protocol didSetPriceDelegate {
    func didSetPrice(Image:UIImageView,status:Bool,idsArray:[PriceModel.Datum],Index:Int)
}
protocol createPlaylistDelegate {
    func createPlaylist(status:Bool)
}
protocol getGenresStringDelegate {
    func getGenresString(String:String,nameString:String)
}
protocol getPriceStringDelegate {
    func getPriceString(String:String,nameString:String)
}


protocol commentProfileDelegate {
    func commentProfile(index:Int,status:Bool)
}

protocol OnNotificationSettingsDelegate{
    func OnNotificationSettingsChanged(value:Int,index:Int,status:Bool)
}
protocol didInitializeCashFreeDelegate{
    func didInitializeCashFree(name:String,email:String,phoneNumber:String)
}

protocol addStationDelegate {
    func addStation(object:[String:Any])
}

protocol didSelectTimeZoneDelegate{
    func didSelectTimeZone(timeZone:String,name:String,index:Int)
}
protocol  didSelectPaystackEmailDelegate {
    func didSelectPaystackEmail(email:String)
}
protocol didReceivePaystackReferenceIDDelegate {
    func didReceivePaystackReferenceID(refID:String)
}
