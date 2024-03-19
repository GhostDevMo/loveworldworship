//
//  PurchaseTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/20/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK

class PurchaseTableItem: UITableViewCell {
    
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var typeLabel: UILabel!
        
    var indexPath:Int = 0
    var songLink:String = ""
    var trackID:Int = 0
    var audioId:String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.mainView.addShadow()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bind(_ object: Purchase, index: Int) {
        let thumbnailURL = URL.init(string:object.songData?.thumbnail ?? "")
        self.thumbnailImage.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
        titleLabel.text = object.title ?? ""
        self.priceLabel.text = "Price: $\(object.price?.rounded(toPlaces: 2) ?? 0)" + "\t" + "Date: \(object.timestamp ?? "")"
        self.audioId = object.songData?.audio_id ?? ""
        self.trackID = object.id ?? 0
        self.songLink = object.songData?.audio_location ?? ""
        
    }
    /*func showMoreAlert(){
        let alert = UIAlertController(title: NSLocalizedString("Song", comment: "Song"), message: "", preferredStyle: .actionSheet)
        
        let ReportSong = UIAlertAction(title: NSLocalizedString("Report This Song", comment: "Report This Song"), style: .default) { (action) in
            self.reportSong(trackID: self.trackID)
        }
        let CopySong = UIAlertAction(title: NSLocalizedString("Copy", comment: "Copy"), style: .default) { (action) in
            UIPasteboard.general.string = self.songLink
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
    
    @IBAction func morePressed(_ sender: UIButton) {
        //        self.delegate!.showReportScreen(Status: true,IndexPath: indexPath, songLink: self.songLink ?? "")
        self.showMoreAlert()
    }*/
}
