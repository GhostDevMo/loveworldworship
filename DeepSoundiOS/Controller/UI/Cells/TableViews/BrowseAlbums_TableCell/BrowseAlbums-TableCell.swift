//
//  BrowseAlbums-TableCell.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 16/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK

class BrowseAlbums_TableCell: UITableViewCell {
    @IBOutlet weak var likeBtn: UIButton!
    
    @IBOutlet weak var songsCountLabel: UILabel!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var thumbnailImage: UIImageView!
    
    var delegate:showReportScreenDelegate?
    var likeDelegate:likeDislikeSongDelegate?
    
    var playlistVC:ShowPlaylistDetailsVC?
    var albumVC:ShowAlbumVC?
    var indexPath:Int? = 0
    var songLink:String? = ""
    var likeStatus:Bool? = false
    var audioId:String? = ""
    var trackID:Int? = 0
    var userID:Int? = 0
    
    var PlaylistObject: GetPlaylistSongsModel.Song?
    var albumObject:GetAlbumSongsModel.Song?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    func bind(_ object:GetAlbumSongsModel.Song,index:Int){
        self.likeStatus = object.isLiked ?? false
        self.audioId = object.audioID ?? ""
        self.albumNameLabel.text = object.title?.htmlAttributedString ?? ""
        if object.countViews?.intValue != nil{
            self.songsCountLabel.text = "\(object.categoryName ?? "")\(NSLocalizedString("Music", comment: "Music")) - \(object.countViews?.intValue ?? 0)"
        }else{
            self.songsCountLabel.text = "\(object.categoryName ?? "") \(NSLocalizedString("Music", comment: "Music")) - \(object.countViews?.stringValue ?? "")"
        }
        let url = URL.init(string:object.thumbnail ?? "")
        self.thumbnailImage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
        if object.isLiked ?? false{
            self.likeBtn.setImage(R.image.ic_redHeart(), for: .normal)
        }else{
            self.likeBtn.setImage(R.image.ic_outlineHeart(), for: .normal)
            
        }
        self.likeStatus = object.isLiked ?? false
        self.audioId = object.audioID ?? ""
        self.trackID = object.id ?? 0
        self.indexPath = index
        self.songLink = object.audioLocation ?? ""
        self.userID = object.publisher?.id ?? 0
        self.albumObject = object
        
        
    }
    func PlaylistBind(_ object:GetPlaylistSongsModel.Song,index:Int){
        self.likeStatus = object.isLiked ?? false
        self.audioId = object.audioID ?? ""
        self.albumNameLabel.text = object.title?.htmlAttributedString ?? ""
        if object.countViews?.intValue != nil{
            self.songsCountLabel.text = "\(object.categoryName ?? "") \(NSLocalizedString("Music", comment: "Music")) - \(object.countViews?.intValue ?? 0)"
        }else{
            self.songsCountLabel.text = "\(object.categoryName ?? "") \(NSLocalizedString("Music", comment: "Music")) - \(object.countViews?.stringValue ?? "")"
        }
        let url = URL.init(string:object.thumbnail ?? "")
        self.thumbnailImage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
        if object.isLiked ?? false{
            self.likeBtn.setImage(R.image.ic_redHeart(), for: .normal)
        }else{
            self.likeBtn.setImage(R.image.ic_outlineHeart(), for: .normal)
            
        }
        self.likeStatus = object.isLiked ?? false
        self.audioId = object.audioID ?? ""
        self.trackID = object.id ?? 0
        self.indexPath = index
        self.songLink = object.audioLocation ?? ""
        self.userID = object.publisher?.id ?? 0
        self.PlaylistObject = object
        
        
    }
    
    
    @IBAction func morePressed(_ sender: Any) {     
        if AppInstance.instance.getUserSession(){
                   if AppInstance.instance.userId == self.userID ?? 0 {
                       self.showMoreAlert()
                   }else{
                       self.showMoreAlertforNonSameUser()
                   }
               }else{
                   notLoggedInAlert()
               }
    }
    
    
    
    @IBAction func likePressed(_ sender: Any) {
        if AppInstance.instance.getUserSession(){
            self.likeStatus = !self.likeStatus!
            if self.likeStatus!{
                log.verbose("Status = \(likeStatus!)")
                self.likeDelegate?.likeDisLikeSong(status: likeStatus!,button: likeBtn,audioId: self.audioId  ?? "")
            }else{
                log.verbose("Status = \(likeStatus!)")
                self.likeDelegate?.likeDisLikeSong(status: likeStatus!,button: likeBtn,audioId:self.audioId  ?? "")
            }
        }else{
           loginAlert()
        }
        
    }
    func showMoreAlert(){
        let alert = UIAlertController(title:NSLocalizedString("Song", comment: "Song"), message: "", preferredStyle: .actionSheet)
        let deleteSong = UIAlertAction(title: NSLocalizedString("Delete Song", comment: "Delete Song"), style: .default) { (action) in
            log.verbose("Delete Song")
            self.deleteTrack(trackID: self.trackID ?? 0, index:self.indexPath  ?? 0)
        }
        let EditSong = UIAlertAction(title: NSLocalizedString("Edit Song", comment: "Edit Song"), style: .default) { (action) in
            log.verbose("Edit Song")
            if self.PlaylistObject != nil{
                let vc = R.storyboard.track.uploadTrackVC()
                let object = UpdateTrackModel(trackID: self.PlaylistObject?.id ?? 0, trackName: self.PlaylistObject?.title ?? "", trackTitle: self.PlaylistObject?.title ?? "", trackDescription: self.PlaylistObject?.songDescription ?? "", trackLyrics:  "", tags: self.PlaylistObject?.tags ?? "", genres: self.PlaylistObject?.categoryName ?? "",  price:  0.0, availability: self.PlaylistObject?.availability ?? 0 , ageRestriction: self.PlaylistObject?.ageRestriction ?? 0, downloads: self.PlaylistObject?.allowDownloads ?? 0,trackImage:self.PlaylistObject?.thumbnail ?? "",songID:self.PlaylistObject?.audioID ?? "")
                
                vc?.trackObject = object
                if self.playlistVC != nil{
                    self.playlistVC?.navigationController?.pushViewController(vc!, animated: true)
                }else  if self.albumVC != nil{
                    self.albumVC?.navigationController?.pushViewController(vc!, animated: true)
                }
            }else if self.albumObject != nil{
                let vc = R.storyboard.track.uploadTrackVC()
                let object = UpdateTrackModel(trackID: self.albumObject?.id ?? 0, trackName: self.albumObject?.title ?? "", trackTitle: self.albumObject?.title ?? "", trackDescription: self.albumObject?.songDescription ?? "", trackLyrics:  "", tags: self.albumObject?.tags ?? "", genres: self.albumObject?.categoryName ?? "",  price:  0.0, availability: self.albumObject?.availability ?? 0 , ageRestriction: self.albumObject?.ageRestriction ?? 0, downloads: self.albumObject?.allowDownloads ?? 0,trackImage:self.albumObject?.thumbnail ?? "",songID:self.albumObject?.audioID ?? "")
                
                vc?.trackObject = object
                if self.playlistVC != nil{
                    self.playlistVC?.navigationController?.pushViewController(vc!, animated: true)
                }else  if self.albumVC != nil{
                    self.albumVC?.navigationController?.pushViewController(vc!, animated: true)
                }
                
            }
            
            
        }
        
        let ReportSong = UIAlertAction(title:NSLocalizedString("Report This Song", comment: "Report This Song"), style: .default) { (action) in
            self.reportSong(trackID: self.trackID ?? 0)
            
            
        }
        let CopySong = UIAlertAction(title: NSLocalizedString("Copy", comment: "Copy"), style: .default) { (action) in
            if self.playlistVC != nil{
                UIPasteboard.general.string = self.songLink ?? ""
                self.playlistVC?.view.makeToast(NSLocalizedString("Text copy to clipboad", comment: "Text copy to clipboad"))
            }else  if self.albumVC != nil{
                UIPasteboard.general.string = self.songLink ?? ""
                self.albumVC?.view.makeToast(NSLocalizedString("Text copy to clipboad", comment: "Text copy to clipboad"))
            }
            
            
        }
        let cancel = UIAlertAction(title:NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
        
        alert.addAction(deleteSong)
        alert.addAction(EditSong)
        alert.addAction(ReportSong)
        alert.addAction(CopySong)
        alert.addAction(cancel)
        alert.popoverPresentationController?.sourceView = self
        if self.playlistVC != nil{
            self.playlistVC?.present(alert, animated: true, completion: nil)
        }else  if self.albumVC != nil{
            self.albumVC?.present(alert, animated: true, completion: nil)
        }
        
    }
    func showMoreAlertforNonSameUser(){
        let alert = UIAlertController(title: NSLocalizedString("Song", comment: "Song"), message: "", preferredStyle: .actionSheet)
        
        let ReportSong = UIAlertAction(title: NSLocalizedString("Report This Song", comment: "Report This Song"), style: .default) { (action) in
            self.reportSong(trackID: self.trackID ?? 0)
            
            
        }
        let CopySong = UIAlertAction(title: NSLocalizedString("Copy", comment: "Copy"), style: .default) { (action) in
            if self.playlistVC != nil{
                UIPasteboard.general.string = self.songLink ?? ""
                self.playlistVC?.view.makeToast(NSLocalizedString("Text copy to clipboad", comment: "Text copy to clipboad"))
            }else  if self.albumVC != nil{
                UIPasteboard.general.string = self.songLink ?? ""
                self.albumVC?.view.makeToast(NSLocalizedString("Text copy to clipboad", comment: "Text copy to clipboad"))
            }
            
            
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
        
        alert.addAction(ReportSong)
        alert.addAction(CopySong)
        alert.addAction(cancel)
        alert.popoverPresentationController?.sourceView = self
        if self.playlistVC != nil{
            self.playlistVC?.present(alert, animated: true, completion: nil)
        }else  if self.albumVC != nil{
            self.albumVC?.present(alert, animated: true, completion: nil)
        }
        
    }
    func notLoggedInAlert(){
        let alert = UIAlertController(title: NSLocalizedString("Song", comment: "Song"), message: "", preferredStyle: .actionSheet)
        
        let CopySong = UIAlertAction(title: NSLocalizedString("Copy", comment: "Copy"), style: .default) { (action) in
            if self.playlistVC != nil{
                UIPasteboard.general.string = self.songLink ?? ""
                self.playlistVC?.view.makeToast(NSLocalizedString("Text copy to clipboad", comment: "Text copy to clipboad"))
            }else  if self.albumVC != nil{
                UIPasteboard.general.string = self.songLink ?? ""
                self.albumVC?.view.makeToast(NSLocalizedString("Text copy to clipboad", comment: "Text copy to clipboad"))
            }
            
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
        
        alert.addAction(CopySong)
        alert.addAction(cancel)
        alert.popoverPresentationController?.sourceView = self
        if self.playlistVC != nil{
            self.playlistVC?.present(alert, animated: true, completion: nil)
        }else  if self.albumVC != nil{
            self.albumVC?.present(alert, animated: true, completion: nil)
        }
        
    }
    func loginAlert(){
        let alert = UIAlertController(title:NSLocalizedString("Login", comment: "Login"), message:NSLocalizedString("Sorry you can not continue, you must log in and enjoy access to everything you want", comment: "Sorry you can not continue, you must log in and enjoy access to everything you want"), preferredStyle: .alert)
        let yes = UIAlertAction(title:NSLocalizedString("YES", comment: "YES") , style: .default) { (action) in
            if self.playlistVC != nil {
                self.playlistVC?.appDelegate.window?.rootViewController = R.storyboard.login.main()
                
            } else if self.albumVC != nil{
                self.albumVC?.appDelegate.window?.rootViewController = R.storyboard.login.main()
            }
        }
        let no = UIAlertAction(title: NSLocalizedString("NO", comment: "NO"), style: .cancel, handler: nil)
        alert.addAction(yes)
        alert.addAction(no)
        alert.popoverPresentationController?.sourceView = self
        if self.playlistVC != nil {
            self.playlistVC?.present(alert, animated: true, completion: nil)
            
        } else if self.albumVC != nil{
            self.albumVC?.present(alert, animated: true, completion: nil)
        }
    }
    
    private func deleteTrack(trackID:Int,index:Int){
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                TrackManager.instance.deletTrack(TrackId: trackID, AccessToken: accessToken) { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            if self.playlistVC != nil{
                                self.playlistVC?.dismissProgressDialog {
                                    log.debug("success = \(success?.status ?? 0)")
                                    AppInstance.instance.userProfile?.data?.activities?.remove(at: index)
                                    self.playlistVC?.tableView.reloadData()
                                }
                            }else  if self.albumVC != nil{
                                self.albumVC?.dismissProgressDialog {
                                    log.debug("success = \(success?.status ?? 0)")
                                    AppInstance.instance.userProfile?.data?.activities?.remove(at: index)
                                    self.albumVC?.tableView.reloadData()
                                }
                            }
                            
                        })
                        
                    }else if sessionError != nil{
                        
                        Async.main({
                            if self.playlistVC != nil{
                                self.playlistVC?.dismissProgressDialog {
                                    log.error("sessionError = \(sessionError?.error ?? "")")
                                    self.playlistVC?.view.makeToast(sessionError?.error ?? "")
                                }
                            }else  if self.albumVC != nil{
                                self.albumVC?.dismissProgressDialog {
                                    log.error("sessionError = \(sessionError?.error ?? "")")
                                    self.albumVC?.view.makeToast(sessionError?.error ?? "")
                                }
                            }
                            
                        })
                    }else {
                        Async.main({
                            if self.playlistVC != nil{
                                self.playlistVC?.dismissProgressDialog {
                                    log.error("error = \(error?.localizedDescription ?? "")")
                                    self.playlistVC?.view.makeToast(error?.localizedDescription ?? "")
                                }
                            }else  if self.albumVC != nil{
                                self.albumVC?.dismissProgressDialog {
                                    log.error("error = \(error?.localizedDescription ?? "")")
                                    self.albumVC?.view.makeToast(error?.localizedDescription ?? "")
                                }
                            }
                        })
                    }
                }
            })
        }else{
            if self.playlistVC != nil{
                self.playlistVC?.dismissProgressDialog {
                    log.error("internetErrro = \(InterNetError)")
                    self.playlistVC?.view.makeToast(InterNetError)
                }
            }else  if self.albumVC != nil{
                self.albumVC?.dismissProgressDialog {
                    log.error("internetErrro = \(InterNetError)")
                    self.albumVC?.view.makeToast(InterNetError)
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
                            if self.playlistVC != nil{
                                self.playlistVC?.dismissProgressDialog {
                                    log.debug("The song has been reported")
                                    self.playlistVC?.view.makeToast(NSLocalizedString("The song has been reported", comment: "The song has been reported"))
                                    
                                }
                            }else  if self.albumVC != nil{
                                self.albumVC?.dismissProgressDialog {
                                    log.debug("The song has been reported")
                                    self.albumVC?.view.makeToast(NSLocalizedString("The song has been reported", comment: "The song has been reported"))
                                }
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            if self.playlistVC != nil{
                                self.playlistVC?.dismissProgressDialog {
                                    log.error("sessionError = \(sessionError?.error ?? "")")
                                    self.playlistVC?.view.makeToast(sessionError?.error ?? "")
                                }
                            }else  if self.albumVC != nil{
                                self.albumVC?.dismissProgressDialog {
                                    log.error("sessionError = \(sessionError?.error ?? "")")
                                    self.albumVC?.view.makeToast(sessionError?.error ?? "")
                                }
                            }
                        })
                    }else{
                        Async.main({
                            if self.playlistVC != nil{
                                self.playlistVC?.dismissProgressDialog {
                                    log.error("error = \(error?.localizedDescription ?? "")")
                                    self.playlistVC?.view.makeToast(error?.localizedDescription ?? "")
                                }
                            }else  if self.albumVC != nil{
                                self.albumVC?.dismissProgressDialog {
                                    log.error("error = \(error?.localizedDescription ?? "")")
                                    self.albumVC?.view.makeToast(error?.localizedDescription ?? "")
                                }
                            }
                        })
                    }
                }
            })
        }else{
            if self.playlistVC != nil{
                self.playlistVC?.dismissProgressDialog {
                    log.error("internetErrro = \(InterNetError)")
                    self.playlistVC?.view.makeToast(InterNetError)
                }
            }else  if self.albumVC != nil{
                self.albumVC?.dismissProgressDialog {
                    log.error("internetErrro = \(InterNetError)")
                    self.albumVC?.view.makeToast(InterNetError)
                }
            }
            
        }
    }
}
