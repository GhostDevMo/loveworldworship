//
//  ProductsVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris But on 17/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import ExpyTableView
import SwiftEventBus
import DeepSoundSDK
class ProductsVC: BaseVC {
    
    @IBOutlet weak var table: ExpyTableView!
    var productDetails = [String:Any]()
    private let popupContentController = R.storyboard.player.musicPlayerVC()
    private var likeMusicArray = [MusicPlayerModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftEventBus.onMainThread(self, name:   EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER) { result in
            log.verbose("To dismiss the popover")
            AppInstance.instance.player = nil
            self.tabBarController?.dismissPopupBar(animated: true, completion: nil)
        }
        SwiftEventBus.onMainThread(self, name:   "PlayerReload") { result in
            let stringValue = result?.object as? String
            self.view.makeToast(stringValue)
            log.verbose(stringValue)
        }
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        
        
        table.register(UINib(nibName: "productHeadrItem", bundle: nil), forCellReuseIdentifier: "productHeadrItem")
        table.register(UINib(nibName: "productsRelatedItem", bundle: nil), forCellReuseIdentifier: "productsRelatedItem")
        table.register(UINib(nibName: "productsSectionItem", bundle: nil), forCellReuseIdentifier: "productsSectionItem")
        table.register( ExpandableTextTableItem.nib, forCellReuseIdentifier: ExpandableTextTableItem.identifier)
        table.register( ExpandableProfileTableItem.nib, forCellReuseIdentifier: ExpandableProfileTableItem.identifier)
        table.register( ExpandableReviewTableItem.nib, forCellReuseIdentifier: ExpandableReviewTableItem.identifier)
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

extension ProductsVC:ExpyTableViewDataSource,ExpyTableViewDelegate{
    func tableView(_ tableView: ExpyTableView, expyState state: ExpyState, changeForSection section: Int) {
        print("section = \(section)")
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 2
        case 3:
            return 2
        case 4:
            return 2
        case 5:
            return 2
        default:
            return 1
        }
    }
    func tableView(_ tableView: ExpyTableView, expandableCellForSection section: Int) -> UITableViewCell {
        switch section {
        case 2:
            let cell = table.dequeueReusableCell(withIdentifier: "productsSectionItem") as! productsSectionItem
            cell.selectionStyle = .none
            cell.title.text = "Description"
            return cell
            
        case 3:
            let cell = table.dequeueReusableCell(withIdentifier: "productsSectionItem") as! productsSectionItem
            cell.selectionStyle = .none
            cell.title.text = "Reviews"
            return cell
            
        case 4:
            let cell = table.dequeueReusableCell(withIdentifier: "productsSectionItem") as! productsSectionItem
            cell.selectionStyle = .none
            cell.title.text = "Tag(s)"
            return cell
            
        case 5:
            let cell = table.dequeueReusableCell(withIdentifier: "productsSectionItem") as! productsSectionItem
            cell.selectionStyle = .none
            cell.title.text = "Profile"
            return cell
        default:
            return UITableViewCell()
        }
        
    }
    func tableView(_ tableView: ExpyTableView, canExpandSection section: Int) -> Bool {
        switch section {
        case 0:
            return false
        case 1:
            return false
        case 2:
            return true
        case 3:
            return true
        case 4:
            return true
        case 5:
            return true
        default:
            return false
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = table.dequeueReusableCell(withIdentifier: "productHeadrItem") as! productHeadrItem
            cell.selectionStyle = .none
            
            cell.bind(productDetails ?? [:])
            cell.vc = self
            return cell
        case 1:
            let cell = table.dequeueReusableCell(withIdentifier: "productsRelatedItem") as! productsRelatedItem
            cell.selectionStyle = .none
            let relatedSong = self.productDetails["related_song"] as? [String:Any]
            let title = relatedSong?["title"] as? String
            cell.bind(title ?? "")
            
            return cell
        case 2:
            let cell = table.dequeueReusableCell(withIdentifier: ExpandableTextTableItem.identifier) as! ExpandableTextTableItem
            cell.selectionStyle = .none
            
            let desc = self.productDetails["desc"] as? String
            cell.bind(desc ?? "")
            
            return cell
        case 3:
            let cell = table.dequeueReusableCell(withIdentifier: ExpandableReviewTableItem.identifier) as! ExpandableReviewTableItem
            cell.selectionStyle = .none
            
            return cell
        case 4:
            let cell = table.dequeueReusableCell(withIdentifier: ExpandableTextTableItem.identifier) as! ExpandableTextTableItem
            cell.selectionStyle = .none
            
            let tags = self.productDetails["tags"] as? String
            cell.bind(tags ?? "")
            return cell
        case 5:
            let cell = table.dequeueReusableCell(withIdentifier: ExpandableProfileTableItem.identifier) as! ExpandableProfileTableItem
            cell.selectionStyle = .none
            
            let object = self.productDetails["user_data"] as? [String:Any]
            cell.bind(object ?? [:])
            return cell
            
            
            
        default:
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            let object = self.productDetails["related_song"] as? [String:Any]
            AppInstance.instance.player = nil
            AppInstance.instance.AlreadyPlayed = false
//
//            self.LikedArray.forEach({ (it) in
//                var audioString:String? = ""
//                var isDemo:Bool? = false
//                let name = it.publisher?.name ?? ""
//                let time = it.timeFormatted ?? ""
//                let title = it.title ?? ""
//                let musicType = it.categoryName ?? ""
//                let thumbnailImageString = it.thumbnail ?? ""
//
//                if it.demoTrack == ""{
//                    audioString = it.audioLocation ?? ""
//                    isDemo = false
//                }else if it.demoTrack != "" && it.audioLocation != ""{
//                    audioString = it.audioLocation ?? ""
//                    isDemo = false
//                }else{
//                    audioString = it.demoTrack ?? ""
//                    isDemo = true
//                }
//                let isOwner = it.isOwner ?? false
//                let audioId = it.audioID ?? ""
//                let likeCount = it.countLikes?.intValue ?? 0
//                let favoriteCount = it.countFavorite?.intValue ?? 0
//                let recentlyPlayedCount = it.countViews?.intValue ?? 0
//                let sharedCount = it.countShares?.intValue ?? 0
//                let commentCount = it.countComment?.intValue ?? 0
//                let trackId = it.id ?? 0
//                let isLiked = it.isLiked ?? false
//                let isFavorited = it.isFavoriated ?? false
//                let likecountString = it.countLikes?.stringValue ?? ""
//                let favoriteCountString = it.countFavorite?.stringValue ?? ""
//                let recentlyPlayedCountString = it.countViews?.stringValue ?? ""
//                let sharedCountString = it.countShares?.stringValue ?? ""
//                let commentCountString = it.countComment?.stringValue ?? ""
//
//                let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner)
//                self.likeMusicArray.append(musicObject)
//            })
            var audioString:String? = ""
            var isDemo:Bool? = false
            let name = object?["name"] as? String ?? ""
            let time = object?["time_formatted"] as? String  ?? ""
            let title = object?["title"] as? String ?? ""
            let musicType = object?["category_name"] as? String ?? ""
            let thumbnailImageString = object?["thumbnail"] as? String ?? ""
            let demoTrack = object?["demo_track"] as? String ?? ""
            if demoTrack == ""{
                audioString = object?["audio_location"] as? String  ?? ""
                isDemo = false
            }else if demoTrack != "" && object?["audio_location"] as? String  ?? "" != ""{
                audioString = object?["audio_location"] as? String ?? ""
                isDemo = false
            }else{
                audioString = demoTrack ?? ""
                isDemo = true
            }
            let isOwner = object?["IsOwner"] as? Bool ?? false
            let audioId = object?["audio_id"] as? String ?? ""
            let likeCount = object?["count_likes"] as? Int ?? 0
            let favoriteCount = object?["count_favorite"] as? Int ?? 0
            let recentlyPlayedCount = object?["count_views"] as? Int ?? 0
            let sharedCount = object?["count_shares"] as? Int ?? 0
            let commentCount = object?["count_comment"] as? Int ?? 0
            let trackId = object?["id"] as? Int ?? 0
            let isLiked = object?["IsLiked"] as? Bool ?? false
            let isFavorited = object?["is_favoriated"] as? Bool ?? false
            
            let likecountString = object?["count_likes"] as? String ?? ""
            let favoriteCountString = object?["count_favorite"] as? String ?? ""
            let recentlyPlayedCountString =  object?["count_views"] as? String ?? ""
            let sharedCountString = object?["count_shares"] as? String  ?? ""
            let commentCountString = object?["count_comment"] as? String ?? ""
            let duration = object?["duration"] as? String ?? "0"
            let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner, duration: duration)
            self.likeMusicArray.append(musicObject)
            
            let url = URL.init(string:thumbnailImageString ?? "")
            let publisher = object?["publisher"] as? [String:Any]
            let PubName = publisher?["name"] as? String
            let id = object?["id"] as? Int
            
            popupContentController!.popupItem.title = PubName ?? ""
            popupContentController!.popupItem.subtitle = title.htmlAttributedString ?? ""
            let cell  = tableView.cellForRow(at: indexPath) as? Liked_TableCell
                      popupContentController!.popupItem.image = cell?.thumbnailImage.image
            self.addToRecentlyWatched(trackId: id ?? 0)
            AppInstance.instance.popupPlayPauseSong = false
            
            SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
            
            tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                
                self.popupContentController?.musicObject = musicObject
                self.popupContentController!.musicArray = self.likeMusicArray
                self.popupContentController!.currentAudioIndex = indexPath.row
                self.popupContentController!.songCodeStatus = 1
                 self.popupContentController?.setup()
                
                
            })
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 330
        }else if indexPath.section == 1{
            return 80
        }else if indexPath.section == 2{
            return UITableView.automaticDimension
        }else if indexPath.section == 3{
            return 80
        }else if indexPath.section == 4{
              return UITableView.automaticDimension
        }else if indexPath.section == 5{
            return 80
        }else{
            return 80
        }
    }
}
