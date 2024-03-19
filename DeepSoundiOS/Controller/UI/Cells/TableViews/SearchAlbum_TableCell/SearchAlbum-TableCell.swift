
//
//  SearchAlbum-TableCell.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 12/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit

import Async
import DeepSoundSDK
class SearchAlbum_TableCell: UITableViewCell {

    
    @IBOutlet weak var songsCountLabel: UILabel!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var thumbnailImage: UIImageView!
    
    var indexPath:Int = 0
    var albumURL:String? = ""
       var AlbumID:String? = ""
       var vc:SearchAlbumsVC?
       var object:Album?
       var userID:Int? = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    func bind(_ object: Album,index:Int){
        self.albumNameLabel.text = object.title?.htmlAttributedString ?? ""
        self.songsCountLabel.text = "\(object.category_name ?? "") Music - \(object.count_songs  ?? 0)"
            let url = URL.init(string:object.thumbnail ?? "")
        self.thumbnailImage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
         
        self.AlbumID = object.album_id ?? ""
         self.indexPath = index
         self.albumURL = object.url ?? ""
         self.userID = object.publisher?.id ?? 0
         
         self.object = object
         
     }
    func showMoreAlert(){
           let alert = UIAlertController(title: NSLocalizedString("Album", comment: "Album"), message: "", preferredStyle: .actionSheet)
           let deleteAlbum = UIAlertAction(title:NSLocalizedString("Delete Album", comment: "Delete Album") , style: .default) { (action) in
              
               self.deleteTrack(albumID: self.object?.id ?? 0)

               log.verbose("Delete Song")
           }
        let EditAlbum = UIAlertAction(title:NSLocalizedString("Edit Album", comment: "Edit Album"), style: .default) { (action) in
            log.verbose("Edit Song")
            let vc = R.storyboard.album.uploadAlbumVC()
            let object = UpdateAlbumModel(AlbumID: self.object?.album_id ?? "",
                                          userID: self.object?.publisher?.id ?? 0,
                                          title: self.object?.title ?? "",
                                          description: self.object?.description ?? "",
                                          imageString: self.object?.thumbnail ?? "",
                                          genre: self.object?.category_name ?? "",
                                          price: self.object?.price?.intValue ?? 0)
            vc?.albumObject = object
            self.vc?.navigationController?.pushViewController(vc!, animated: true)
        }
           
           let ShareAlbum = UIAlertAction(title:NSLocalizedString("Share", comment: "Share") , style: .default) { (action) in
               log.verbose("Share")
               self.share(shareString: self.albumURL ?? "")
           }
           let CopyAlbum = UIAlertAction(title: NSLocalizedString("Copy", comment: "Copy"), style: .default) { (action) in
               UIPasteboard.general.string = self.albumURL ?? ""
            self.vc?.view.makeToast(NSLocalizedString("Text copy to clipboad", comment: "Text copy to clipboad"))
               
           }
           let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
           
           alert.addAction(deleteAlbum)
           alert.addAction(EditAlbum)
           alert.addAction(ShareAlbum)
           alert.addAction(CopyAlbum)
           alert.addAction(cancel)
           alert.popoverPresentationController?.sourceView = self
        self.vc?.present(alert, animated: true, completion: nil)
           
           
       }
       func showMoreAlertforNonSameUser(){
           let alert = UIAlertController(title: NSLocalizedString("Album", comment: "Album"), message: "", preferredStyle: .actionSheet)
           
           let share = UIAlertAction(title: NSLocalizedString("Share", comment: "Share"), style: .default) { (action) in
               self.share(shareString: self.albumURL ?? "")
               
           }
           let CopyAlbum = UIAlertAction(title: NSLocalizedString("Copy", comment: "Copy"), style: .default) { (action) in
               UIPasteboard.general.string = self.albumURL ?? ""
            self.vc?.view.makeToast(NSLocalizedString("Text copy to clipboad", comment: "Text copy to clipboad"))
           }
           let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
           
           alert.addAction(share)
           alert.addAction(CopyAlbum)
           alert.addAction(cancel)
        alert.popoverPresentationController?.sourceView = self
        self.vc?.present(alert, animated: true, completion: nil)
       }
       func notLoggedInAlert(){
           let alert = UIAlertController(title: NSLocalizedString("Album", comment: "Album"), message: "", preferredStyle: .actionSheet)
           
           let CopyAlbum = UIAlertAction(title: NSLocalizedString("Copy", comment: "Copy"), style: .default) { (action) in
               UIPasteboard.general.string = self.albumURL ?? ""
            self.vc?.view.makeToast(NSLocalizedString("Text copy to clipboad", comment: "Text copy to clipboad"))
               
           }
           let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
           
           alert.addAction(CopyAlbum)
           alert.addAction(cancel)
        alert.popoverPresentationController?.sourceView = self
        self.vc?.present(alert, animated: true, completion: nil)
           
       }
       private func deleteTrack(albumID:Int){
           if Connectivity.isConnectedToNetwork(){
               let accessToken = AppInstance.instance.accessToken ?? ""
               Async.background({
                   AlbumManager.instance.deleteAlbum(albumId: albumID, AccessToken: accessToken, type: "single") { (success, sessionError, error) in
                       if success != nil{
                           Async.main({
                               
                            self.vc?.dismissProgressDialog {
                                   log.debug("success = \(success?.status ?? 0)")
                                self.vc?.navigationController?.popViewController(animated: true)
                               }
                               
                               
                           })
                           
                       }else if sessionError != nil{
                           
                           Async.main({
                               
                            self.vc?.dismissProgressDialog {
                                   log.error("sessionError = \(sessionError?.error ?? "")")
                                self.vc?.view.makeToast(sessionError?.error ?? "")
                               }
                               
                               
                           })
                       }else {
                           Async.main({
                               
                            self.vc?.dismissProgressDialog {
                                   log.error("error = \(error?.localizedDescription ?? "")")
                                self.vc?.view.makeToast(error?.localizedDescription ?? "")
                               }
                               
                           })
                       }
                   }
               })
           }else{
               
            self.vc?.dismissProgressDialog {
                   log.error("internetErrro = \(InterNetError)")
                self.vc?.view.makeToast(InterNetError)
               }
               
           }
       }
       private func share(shareString:String?){
           // text to share
           let text = shareString ?? ""
           
           // set up activity view controller
           let textToShare = [ text ]
           let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
           activityViewController.popoverPresentationController?.sourceView = self // so that iPads won't crash
           
           // exclude some activity types from the list (optional)
           activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
           
           // present the view controller
        self.vc?.present(activityViewController, animated: true, completion: nil)
       }
    @IBAction func morePressed(_ sender: UIButton) {
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
}
