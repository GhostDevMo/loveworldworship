//
//  Activities_TableCell.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 08/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
class Activities_TableCell: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var actionTextLabel: UILabel!
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var activityTextLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    //    var IndexPath:Int? = 0
    var audioId:String? = ""
    var songLink:String? = ""
    var trackID:Int? = 0
    var indexPath:Int? = 0
    var vc:ActivitiesVC?
    var userInfoVC:UserInfoVC?
    
    var object:ProfileModel.Activity?
    var userActivityObject:UserInfoModel.Activity?
    var userID:Int? = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func bind(_ object:ProfileModel.Activity,index:Int){
          let thumbnailURL = URL.init(string:object.sThumbnail ?? "")
             self.thumbnailImage.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
             let profileURL = URL.init(string:object.userData?.avatar ?? "")
             profileImage.sd_setImage(with: profileURL , placeholderImage:R.image.imagePlacholder())
             nameLabel.text = object.userData?.name ?? ""
             activityTextLabel.text = "\(object.activityText?.htmlAttributedString ?? "")\(object.activityTimeFormatted ?? "")"
             actionTextLabel.text = object.sName?.htmlAttributedString ?? ""
             timeLabel.text = object.sDuration ?? ""
             profileImage.cornerRadiusV = (profileImage.frame.height) / 2
        profileImage.borderColorV = .mainColor
             self.audioId = object.trackData?.audioID ?? ""
                    self.trackID = object.trackData?.id ?? 0
                    self.indexPath = index
                    self.songLink = object.trackData?.url ?? ""
                    self.userID = object.trackData?.userID ?? 0
        
        self.object = object
        
    }
    func userInfoBind(_ object:UserInfoModel.Activity,index:Int){
        let thumbnailURL = URL.init(string:object.sThumbnail ?? "")
        self.thumbnailImage.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
        let profileURL = URL.init(string:object.userData?.avatar ?? "")
        profileImage.sd_setImage(with: profileURL , placeholderImage:R.image.imagePlacholder())
        nameLabel.text = object.userData?.name ?? ""
        activityTextLabel.text = "\(object.activityText?.htmlAttributedString ?? "")\(object.activityTimeFormatted ?? "")"
        actionTextLabel.text = object.sName?.htmlAttributedString ?? ""
        timeLabel.text = object.sDuration ?? ""
        profileImage.cornerRadiusV = (profileImage.frame.height) / 2
        
        self.audioId = object.trackData?.audioID ?? ""
        self.trackID = object.trackData?.id ?? 0
        self.indexPath = index
        self.songLink = object.trackData?.url ?? ""
        self.userID = object.trackData?.userID ?? 0
        self.userActivityObject = object
        
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
    func showMoreAlert(){
        let alert = UIAlertController(title: NSLocalizedString("Song", comment: "Song"), message: "", preferredStyle: .actionSheet)
        let deleteSong = UIAlertAction(title: NSLocalizedString("Delete Song", comment: "Delete Song"), style: .default) { (action) in
            log.verbose("Delete Song")
            self.deleteTrack(trackID: self.trackID ?? 0, index:self.indexPath  ?? 0)
        }
        let EditSong = UIAlertAction(title:  NSLocalizedString("Edit Song", comment: "Edit Song"), style: .default) { (action) in
            log.verbose("Edit Song")
            if self.object != nil{
                let vc = R.storyboard.track.uploadTrackVC()
                let object = UpdateTrackModel(trackID: self.object?.trackData?.id ?? 0, trackName: self.object?.trackData?.title ?? "", trackTitle: self.object?.trackData?.title ?? "", trackDescription: self.object?.trackData?.latestsongDescription ?? "", trackLyrics: self.object?.trackData?.lyrics ?? "", tags: self.object?.trackData?.tags ?? "", genres: self.object?.trackData?.categoryName ?? "",  price: self.object?.trackData?.price ?? 0.0, availability: self.object?.trackData?.availability ?? 0 , ageRestriction: self.object?.trackData?.ageRestriction ?? 0, downloads: self.object?.trackData?.allowDownloads ?? 0,trackImage:self.object?.trackData?.thumbnail ?? "",songID:self.object?.trackData?.audioID ?? "")
                
                vc?.trackObject = object
                if self.vc != nil{
                    self.vc?.navigationController?.pushViewController(vc!, animated: true)
                }else  if self.userInfoVC != nil{
                    self.userInfoVC?.navigationController?.pushViewController(vc!, animated: true)
                }
            }else if self.userActivityObject != nil{
                let vc = R.storyboard.track.uploadTrackVC()
                let object = UpdateTrackModel(trackID: self.userActivityObject?.trackData?.id ?? 0, trackName: self.userActivityObject?.trackData?.title ?? "", trackTitle: self.userActivityObject?.trackData?.title ?? "", trackDescription: self.userActivityObject?.trackData?.latestsongDescription ?? "", trackLyrics: self.object?.trackData?.lyrics ?? "", tags: self.userActivityObject?.trackData?.tags ?? "", genres: self.userActivityObject?.trackData?.categoryName ?? "",  price: self.userActivityObject?.trackData?.price ?? 0.0, availability: self.userActivityObject?.trackData?.availability ?? 0 , ageRestriction: self.userActivityObject?.trackData?.ageRestriction ?? 0, downloads:1,trackImage:self.userActivityObject?.trackData?.thumbnail ?? "",songID:self.userActivityObject?.trackData?.audioID ?? "")
                
                vc?.trackObject = object
                if self.vc != nil{
                    self.vc?.navigationController?.pushViewController(vc!, animated: true)
                }else  if self.userInfoVC != nil{
                    self.userInfoVC?.navigationController?.pushViewController(vc!, animated: true)
                }
                
            }
            
            
        }
        
        let ReportSong = UIAlertAction(title: NSLocalizedString("Report This Song", comment: "Report This Song"), style: .default) { (action) in
            self.reportSong(trackID: self.trackID ?? 0)
            
            
        }
        let CopySong = UIAlertAction(title: NSLocalizedString("Copy", comment: "Copy"), style: .default) { (action) in
            if self.vc != nil{
                UIPasteboard.general.string = self.songLink ?? ""
                self.vc?.view.makeToast(NSLocalizedString("Text copy to clipboad", comment: "Text copy to clipboad"))
            }else  if self.userInfoVC != nil{
                UIPasteboard.general.string = self.songLink ?? ""
                self.userInfoVC?.view.makeToast(NSLocalizedString("Text copy to clipboad", comment: "Text copy to clipboad"))
            }
            
            
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
        
        alert.addAction(deleteSong)
        alert.addAction(EditSong)
        alert.addAction(ReportSong)
        alert.addAction(CopySong)
        alert.addAction(cancel)
        alert.popoverPresentationController?.sourceView = self
        if self.vc != nil{
          
            self.vc?.present(alert, animated: true, completion: nil)
        }else  if self.userInfoVC != nil{
            self.userInfoVC?.present(alert, animated: true, completion: nil)
        }
        
    }
    func showMoreAlertforNonSameUser(){
        let alert = UIAlertController(title: NSLocalizedString("Song", comment: "Song"), message: "", preferredStyle: .actionSheet)
        
        let ReportSong = UIAlertAction(title: NSLocalizedString("Report This Song", comment: "Report This Song"), style: .default) { (action) in
            self.reportSong(trackID: self.trackID ?? 0)
            
            
        }
        let CopySong = UIAlertAction(title: NSLocalizedString("Copy", comment: "Copy"), style: .default) { (action) in
            if self.vc != nil{
                UIPasteboard.general.string = self.songLink ?? ""
                self.vc?.view.makeToast(NSLocalizedString("Text copy to clipboad", comment: "Text copy to clipboad"))
            }else  if self.userInfoVC != nil{
                UIPasteboard.general.string = self.songLink ?? ""
                self.userInfoVC?.view.makeToast(NSLocalizedString("Text copy to clipboad", comment: "Text copy to clipboad"))
            }
            
            
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
        
        alert.addAction(ReportSong)
        alert.addAction(CopySong)
        alert.addAction(cancel)
        alert.popoverPresentationController?.sourceView = self
        if self.vc != nil{
            self.vc?.present(alert, animated: true, completion: nil)
        }else  if self.userInfoVC != nil{
            self.userInfoVC?.present(alert, animated: true, completion: nil)
        }
        
    }
    func notLoggedInAlert(){
        let alert = UIAlertController(title: NSLocalizedString("Song", comment: "Song"), message: "", preferredStyle: .actionSheet)
        
        let CopySong = UIAlertAction(title: NSLocalizedString("Copy", comment: "Copy"), style: .default) { (action) in
            if self.vc != nil{
                UIPasteboard.general.string = self.songLink ?? ""
                self.vc?.view.makeToast(NSLocalizedString("Text copy to clipboad", comment: "Text copy to clipboad"))
            }else  if self.userInfoVC != nil{
                UIPasteboard.general.string = self.songLink ?? ""
                self.userInfoVC?.view.makeToast(NSLocalizedString("Text copy to clipboad", comment: "Text copy to clipboad"))
            }
            
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
        
        alert.addAction(CopySong)
        alert.addAction(cancel)
        alert.popoverPresentationController?.sourceView = self
        if self.vc != nil{
            self.vc?.present(alert, animated: true, completion: nil)
        }else  if self.userInfoVC != nil{
            self.userInfoVC?.present(alert, animated: true, completion: nil)
        }
        
    }
    private func deleteTrack(trackID:Int,index:Int){
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                TrackManager.instance.deletTrack(TrackId: trackID, AccessToken: accessToken) { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            if self.vc != nil{
                                self.vc?.dismissProgressDialog {
                                    log.debug("success = \(success?.status ?? 0)")
                                    AppInstance.instance.userProfile?.data?.activities?.remove(at: index)
                                    self.vc?.tableView.reloadData()
                                }
                            }else  if self.userInfoVC != nil{
                                self.userInfoVC?.dismissProgressDialog {
                                    log.debug("success = \(success?.status ?? 0)")
                                    AppInstance.instance.userProfile?.data?.activities?.remove(at: index)
                                    self.userInfoVC?.tableView.reloadData()
                                }
                            }
                            
                        })
                        
                    }else if sessionError != nil{
                        
                        Async.main({
                            if self.vc != nil{
                                self.vc?.dismissProgressDialog {
                                    log.error("sessionError = \(sessionError?.error ?? "")")
                                    self.vc?.view.makeToast(sessionError?.error ?? "")
                                }
                            }else  if self.userInfoVC != nil{
                                self.userInfoVC?.dismissProgressDialog {
                                    log.error("sessionError = \(sessionError?.error ?? "")")
                                    self.userInfoVC?.view.makeToast(sessionError?.error ?? "")
                                }
                            }
                            
                        })
                    }else {
                        Async.main({
                            if self.vc != nil{
                                self.vc?.dismissProgressDialog {
                                    log.error("error = \(error?.localizedDescription ?? "")")
                                    self.vc?.view.makeToast(error?.localizedDescription ?? "")
                                }
                            }else  if self.userInfoVC != nil{
                                self.userInfoVC?.dismissProgressDialog {
                                    log.error("error = \(error?.localizedDescription ?? "")")
                                    self.userInfoVC?.view.makeToast(error?.localizedDescription ?? "")
                                }
                            }
                        })
                    }
                }
            })
        }else{
            if self.vc != nil{
                self.vc?.dismissProgressDialog {
                    log.error("internetErrro = \(InterNetError)")
                    self.vc?.view.makeToast(InterNetError)
                }
            }else  if self.userInfoVC != nil{
                self.userInfoVC?.dismissProgressDialog {
                    log.error("internetErrro = \(InterNetError)")
                    self.userInfoVC?.view.makeToast(InterNetError)
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
                            if self.vc != nil{
                                self.vc?.dismissProgressDialog {
                                    log.debug("The song has been reported")
                                    self.vc?.view.makeToast(NSLocalizedString("The song has been reported", comment: "The song has been reported"))
                                    
                                }
                            }else  if self.userInfoVC != nil{
                                self.userInfoVC?.dismissProgressDialog {
                                    log.debug("The song has been reported")
                                    self.userInfoVC?.view.makeToast(NSLocalizedString("The song has been reported", comment: "The song has been reported"))
                                }
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            if self.vc != nil{
                                self.vc?.dismissProgressDialog {
                                    log.error("sessionError = \(sessionError?.error ?? "")")
                                    self.vc?.view.makeToast(sessionError?.error ?? "")
                                }
                            }else  if self.userInfoVC != nil{
                                self.userInfoVC?.dismissProgressDialog {
                                    log.error("sessionError = \(sessionError?.error ?? "")")
                                    self.userInfoVC?.view.makeToast(sessionError?.error ?? "")
                                }
                            }
                        })
                    }else{
                        Async.main({
                            if self.vc != nil{
                                self.vc?.dismissProgressDialog {
                                    log.error("error = \(error?.localizedDescription ?? "")")
                                    self.vc?.view.makeToast(error?.localizedDescription ?? "")
                                }
                            }else  if self.userInfoVC != nil{
                                self.userInfoVC?.dismissProgressDialog {
                                    log.error("error = \(error?.localizedDescription ?? "")")
                                    self.userInfoVC?.view.makeToast(error?.localizedDescription ?? "")
                                }
                            }
                        })
                    }
                }
            })
        }else{
            if self.vc != nil{
                self.vc?.dismissProgressDialog {
                    log.error("internetErrro = \(InterNetError)")
                    self.vc?.view.makeToast(InterNetError)
                }
            }else  if self.userInfoVC != nil{
                self.userInfoVC?.dismissProgressDialog {
                    log.error("internetErrro = \(InterNetError)")
                    self.userInfoVC?.view.makeToast(InterNetError)
                }
            }
            
        }
    }
}
