//
//  Shared-TableCell.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 22/06/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
class Shared_TableCell: UITableViewCell {
    
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
    var vc:SharedVC?
    
    
    
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
    func bind(_ object:MusicPlayerModel, index :Int){
        let thumbnailURL = URL.init(string:object.ThumbnailImageString ?? "")
        self.thumbnailImage.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
        titleLabel.text = object.title?.htmlAttributedString ?? ""
        categoryLabel.text = "\(object.musicType ?? "") - \(object.name ?? "")"
        timeDurationlabel.text = object.time ?? ""
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
        self.trackID = object.trackId ?? 0
        self.indexPath = index
        self.songLink = object.audioString ?? ""
        
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
        self.showMoreAlert()
    }
}
