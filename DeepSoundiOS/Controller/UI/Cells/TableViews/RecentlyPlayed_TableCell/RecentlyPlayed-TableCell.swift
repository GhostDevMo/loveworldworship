//
//  RecentlyPlayed-TableCell.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 22/06/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
class RecentlyPlayed_TableCell: UITableViewCell {
    
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
    var vc:RecentlyPlayedVC?
    var userId:Int? = 0
    var object : RecentlyPlayedModel.Datum?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBAction func heartPresserd(_ sender: Any) {
        
        self.likeStatus = !self.likeStatus!
               if self.likeStatus!{
                   log.verbose("Status = \(likeStatus!)")
                   self.likeDelegate?.likeDisLikeSong(status: likeStatus!,button: heartBtn,audioId: self.audioId  ?? "")
               }else{
                   log.verbose("Status = \(likeStatus!)")
                   self.likeDelegate?.likeDisLikeSong(status: likeStatus!,button: heartBtn,audioId:self.audioId  ?? "")
               }
    }
    func bind(_ object:RecentlyPlayedModel.Datum, index :Int){
        let thumbnailURL = URL.init(string:object.thumbnail ?? "")
        self.thumbnailImage.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
        titleLabel.text = object.title ?? ""
        categoryLabel.text = "\(object.categoryName ?? "") - \(object.publisher?.name ?? "")"
        timeDurationlabel.text = object.duration ?? ""
        if object.isLiked!{
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
                   self.indexPath = index
        self.songLink = object.audioLocation ?? ""
        self.userId = object.publisher?.id ?? 0
        self.object = object
        
    }
    func showMoreAlert(){
        let alert = UIAlertController(title: NSLocalizedString("Song", comment: "Song"), message: "", preferredStyle: .actionSheet)
        
        let ReportSong = UIAlertAction(title: NSLocalizedString("Report This Song", comment: "Report This Song"), style: .default) { (action) in
            self.reportSong(trackID: self.trackID ?? 0)
        }
        let CopySong = UIAlertAction(title: NSLocalizedString("Copy", comment: "Copy"), style: .default) { (action) in
            UIPasteboard.general.string = self.songLink ?? ""
            if self.vc != nil{
                self.vc?.view.makeToast(NSLocalizedString("Text copy to clipboad", comment: "Text copy to clipboad"))
            }
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
        alert.addAction(ReportSong)
        alert.addAction(CopySong)
        alert.addAction(cancel)
        alert.popoverPresentationController?.sourceView = self
        if self.vc != nil{
            self.vc?.present(alert, animated: true, completion: nil)
        }
     
        
    }
    func showUserAlert(){
          let alert = UIAlertController(title: NSLocalizedString("Song", comment: "Song"), message: "", preferredStyle: .actionSheet)
          let deleteSong = UIAlertAction(title: NSLocalizedString("Delete Song", comment: "Delete Song"), style: .default) { (action) in
              log.verbose("Delete Song")
              self.deleteTrack(trackID: self.trackID ?? 0, index:self.indexPath  ?? 0)
          }
          let EditSong = UIAlertAction(title:  NSLocalizedString("Edit Song", comment: "Edit Song"), style: .default) { (action) in
             
                            let vc = R.storyboard.track.uploadTrackVC()
                 let object = UpdateTrackModel(trackID: self.object?.id ?? 0, trackName: self.object?.title ?? "", trackTitle: self.object?.title ?? "", trackDescription: self.object?.datumDescription ?? "", trackLyrics:  "", tags: self.object?.tags ?? "", genres: self.object?.categoryName ?? "",  price:  0.0, availability: self.object?.availability ?? 0 , ageRestriction: self.object?.ageRestriction ?? 0, downloads:  0,trackImage:self.object?.thumbnail ?? "",songID:self.object?.audioID ?? "")
                            
                            vc?.trackObject = object
            self.vc?.navigationController?.pushViewController(vc!, animated: true)
                          
                        
          }
          
          let ReportSong = UIAlertAction(title: NSLocalizedString("Report This Song", comment: "Report This Song"), style: .default) { (action) in
              self.reportSong(trackID: self.trackID ?? 0)
              
              
          }
          let CopySong = UIAlertAction(title: NSLocalizedString("Copy", comment: "Copy"), style: .default) { (action) in
              UIPasteboard.general.string = self.songLink ?? ""
              self.vc?.view.makeToast(NSLocalizedString("Text copy to clipboad", comment: "Text copy to clipboad"))
              
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
                                       AppInstance.instance.userProfile?.data?.topSongs?.remove(at: index)
                                       self.vc?.tableView.reloadData()
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
                                   
                               }
                               
                           })
                       }else {
                           Async.main({
                               if self.vc != nil{
                                   self.vc?.dismissProgressDialog {
                                       log.error("error = \(error?.localizedDescription ?? "")")
                                       self.vc?.view.makeToast(error?.localizedDescription ?? "")
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
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            if self.vc != nil{
                                self.vc?.dismissProgressDialog {
                                    log.error("sessionError = \(sessionError?.error ?? "")")
                                    self.vc?.view.makeToast(sessionError?.error ?? "")
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
            }
        }
    }
    
    @IBAction func morePressed(_ sender: Any) {
//        self.delegate!.showReportScreen(Status: true,IndexPath: indexPath ?? 0, songLink: self.songLink ?? "")
       if userId == AppInstance.instance.userId ?? 0{
                  self.showUserAlert()
              }else{
                  self.showMoreAlert()
              }
    }
}
