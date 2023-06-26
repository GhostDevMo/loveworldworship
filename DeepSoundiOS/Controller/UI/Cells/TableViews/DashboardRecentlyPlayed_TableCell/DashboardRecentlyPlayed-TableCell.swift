//
//  DashboardRecentlyPlayed-TableCell.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 05/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Foundation
import Async
import DeepSoundSDK
class DashboardRecentlyPlayed_TableCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var timeDurationlabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var heartBtn: UIButton!
    var likeDelegate:likeDislikeSongDelegate?
    
    var indexPath:Int? = 0
    var songLink:String? = ""
    var trackID:Int? = 0
    var likeStatus:Bool? = false
    var audioId:String? = ""
    var likedVC:DashboardRecentlyPlayedVC?
    var userID:Int? = 0
    var object:DiscoverModel.Song?
    var genreSongObject: GenresSongsModel.Datum?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    @IBAction func heartPresserd(_ sender: Any) {
        
     if AppInstance.instance.getUserSession(){
            self.likeStatus = !self.likeStatus!
            if self.likeStatus!{
                log.verbose("Status = \(likeStatus!)")
                self.likeDelegate?.likeDisLikeSong(status: likeStatus!,button: heartBtn,audioId: self.audioId  ?? "")
            }else{
                log.verbose("Status = \(likeStatus!)")
                self.likeDelegate?.likeDisLikeSong(status: likeStatus!,button: heartBtn,audioId:self.audioId  ?? "")
            }
        }else{
           loginAlert()
        }
    }
    func bind(_ object:DiscoverModel.Song, index :Int){
        let thumbnailURL = URL.init(string:object.thumbnail ?? "")
        self.thumbnailImage.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
        titleLabel.text = object.title ?? ""
        categoryLabel.text = "\(object.categoryName ?? "") - \(object.publisher?.name ?? "")"
        timeDurationlabel.text = object.duration ?? ""
        if object.isLiked ?? false{
            heartBtn.setImage(R.image.ic_heartRed(), for: .normal)
            
        }else{
            heartBtn.setImage(R.image.heart(), for: .normal)
            
        }
        if index > 9{
            self.countLabel.text = "\(index)"
        }else{
            self.countLabel.text = "0\(index)"
        }
        self.likeStatus = object.isLiked ?? false
        self.audioId = object.audioID ?? ""
        self.trackID = object.id ?? 0
        //           self.indexPath = index
        self.songLink = object.audioLocation ?? ""
        self.userID = object.publisher?.id ?? 0
        self.object = object
    }
    func showMoreAlert(){
        let alert = UIAlertController(title: NSLocalizedString("Song", comment: "Song"), message: "", preferredStyle: .actionSheet)
        
        let ReportSong = UIAlertAction(title: NSLocalizedString("Report This Song", comment: "Report This Song"), style: .default) { (action) in
            self.reportSong(trackID: self.trackID ?? 0)
        }
        let CopySong = UIAlertAction(title: NSLocalizedString("Copy", comment: "Copy"), style: .default) { (action) in
            UIPasteboard.general.string = self.songLink ?? ""
            if self.likedVC != nil{
                self.likedVC?.view.makeToast(NSLocalizedString("Text copy to clipboad", comment: "Text copy to clipboad"))
            }
            
            
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
        
        
        alert.addAction(ReportSong)
        alert.addAction(CopySong)
        alert.addAction(cancel)
        alert.popoverPresentationController?.sourceView = self
        if self.likedVC != nil{
            self.likedVC?.present(alert, animated: true, completion: nil)
        }
        
    }
    func showUserAlert(){
        let alert = UIAlertController(title: NSLocalizedString("Song", comment: "Song"), message: "", preferredStyle: .actionSheet)
        let deleteSong = UIAlertAction(title: NSLocalizedString("Delete Song", comment: "Delete Song"), style: .default) { (action) in
            log.verbose("Delete Song")
            self.deleteTrack(trackID: self.trackID ?? 0, index:self.indexPath  ?? 0)
        }
        let EditSong = UIAlertAction(title:  NSLocalizedString("Edit Song", comment: "Edit Song"), style: .default) { (action) in
            log.verbose("Edit Song")
            if self.object != nil{
                let vc = R.storyboard.track.uploadTrackVC()
                let object = UpdateTrackModel(trackID: self.object?.id ?? 0, trackName: self.object?.title ?? "", trackTitle: self.object?.title ?? "", trackDescription: self.object?.songDescription ?? "", trackLyrics:  "", tags: self.object?.tags ?? "", genres: self.object?.categoryName ?? "",  price:  0.0, availability: self.object?.availability ?? 0 , ageRestriction: self.object?.ageRestriction ?? 0, downloads:  0,trackImage:self.object?.thumbnail ?? "",songID:self.object?.audioID ?? "")
                
                vc?.trackObject = object
                if self.likedVC != nil{
                    self.likedVC?.navigationController?.pushViewController(vc!, animated: true)
                }
            }
        }
        
        let ReportSong = UIAlertAction(title: NSLocalizedString("Report This Song", comment: "Report This Song"), style: .default) { (action) in
            self.reportSong(trackID: self.trackID ?? 0)
            
            
        }
        let CopySong = UIAlertAction(title: NSLocalizedString("Copy", comment: "Copy"), style: .default) { (action) in
            if self.likedVC != nil{
                UIPasteboard.general.string = self.songLink ?? ""
                self.likedVC?.view.makeToast(NSLocalizedString("Text copy to clipboad", comment: "Text copy to clipboad"))
            }
            
            
            
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
        
        alert.addAction(deleteSong)
        alert.addAction(EditSong)
        alert.addAction(ReportSong)
        alert.addAction(CopySong)
        alert.addAction(cancel)
        alert.popoverPresentationController?.sourceView = self
        if self.likedVC != nil{
            self.likedVC?.present(alert, animated: true, completion: nil)
        }
        
    }
    func notLoggedInUser(){
        let alert = UIAlertController(title: NSLocalizedString("Song", comment: "Song"), message: "", preferredStyle: .actionSheet)
        
        
        let CopySong = UIAlertAction(title: NSLocalizedString("Copy", comment: "Copy"), style: .default) { (action) in
            UIPasteboard.general.string = self.songLink ?? ""
            if self.likedVC != nil{
                self.likedVC?.view.makeToast(NSLocalizedString("Text copy to clipboad", comment: "Text copy to clipboad"))
            }
            
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
        
        
        alert.addAction(CopySong)
        alert.addAction(cancel)
        alert.popoverPresentationController?.sourceView = self
        if self.likedVC != nil{
            self.likedVC?.present(alert, animated: true, completion: nil)
        }
    }
    func loginAlert(){
        let alert = UIAlertController(title: NSLocalizedString("Login", comment: "Login"), message: NSLocalizedString("Sorry you can not continue, you must log in and enjoy access to everything you want", comment: "Sorry you can not continue, you must log in and enjoy access to everything you want"), preferredStyle: .alert)
        let yes = UIAlertAction(title: NSLocalizedString("YES", comment: "YES") , style: .default) { (action) in
            
            if self.likedVC != nil{
                self.likedVC?.appDelegate.window?.rootViewController = R.storyboard.login.main()
            }
        }
        let no = UIAlertAction(title: NSLocalizedString("NO", comment: "NO"), style: .cancel, handler: nil)
        alert.addAction(yes)
        alert.addAction(no)
        alert.popoverPresentationController?.sourceView = self
        if self.likedVC != nil{
            self.likedVC?.present(alert, animated: true, completion: nil)
        }
    }
    private func deleteTrack(trackID:Int,index:Int){
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                TrackManager.instance.deletTrack(TrackId: trackID, AccessToken: accessToken) { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            if self.likedVC != nil{
                                self.likedVC?.dismissProgressDialog {
                                    
                                    log.debug("success = \(success?.status ?? 0)")
                                    AppInstance.instance.userProfile?.data?.topSongs?.remove(at: index)
                                    self.likedVC?.tableView.reloadData()
                                }
                                
                            }
                            
                        })
                        
                    }else if sessionError != nil{
                        
                        Async.main({
                            if self.likedVC != nil{
                                self.likedVC?.dismissProgressDialog {
                                    log.error("sessionError = \(sessionError?.error ?? "")")
                                    self.likedVC?.view.makeToast(sessionError?.error ?? "")
                                }
                                
                            }
                            
                        })
                    }else {
                        Async.main({
                            if self.likedVC != nil{
                                self.likedVC?.dismissProgressDialog {
                                    log.error("error = \(error?.localizedDescription ?? "")")
                                    self.likedVC?.view.makeToast(error?.localizedDescription ?? "")
                                }
                                
                            }
                        })
                    }
                }
            })
        }else{
            if self.likedVC != nil{
                self.likedVC?.dismissProgressDialog {
                    log.error("internetErrro = \(InterNetError)")
                    self.likedVC?.view.makeToast(InterNetError)
                }
            }
        }
    }
    private func reportSong(trackID:Int){
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                ReportManager.instance.report(Id: trackID, AccessToken: accessToken, ReportDescription: "this song is not good") { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            if self.likedVC != nil{
                                self.likedVC?.dismissProgressDialog {
                                    log.debug("The song has been reported")
                                    self.likedVC?.view.makeToast(NSLocalizedString("The song has been reported", comment: "The song has been reported"))
                                    
                                }
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            if self.likedVC != nil{
                                self.likedVC?.dismissProgressDialog {
                                    log.error("sessionError = \(sessionError?.error ?? "")")
                                    self.likedVC?.view.makeToast(sessionError?.error ?? "")
                                }
                            }
                        })
                    }else{
                        Async.main({
                            if self.likedVC != nil{
                                self.likedVC?.dismissProgressDialog {
                                    log.error("error = \(error?.localizedDescription ?? "")")
                                    self.likedVC?.view.makeToast(error?.localizedDescription ?? "")
                                }
                            }
                        })
                    }
                }
            })
        }else{
            if self.likedVC != nil{
                self.likedVC?.dismissProgressDialog {
                    log.error("internetErrro = \(InterNetError)")
                    self.likedVC?.view.makeToast(InterNetError)
                }
            }
        }
    }
    
    @IBAction func morePressed(_ sender: Any) {
        //        self.delegate!.showReportScreen(Status: true,IndexPath: indexPath ?? 0, songLink: self.songLink ?? "")
        
        
        if AppInstance.instance.getUserSession(){
            if userID == AppInstance.instance.userId ?? 0{
                self.showUserAlert()
            }else{
                self.showMoreAlert()
            }
        }else{
            self.notLoggedInUser()
        }
    }
}
