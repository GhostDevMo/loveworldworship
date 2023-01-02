//
//  SongBottomSheetController.swift
//  DeepSoundiOS
//
//  Created by Mac Pro on 02/09/2022.
//  Copyright © 2022 Moghees Idrees. All rights reserved.
//

import UIKit
import PanModal
import DeepSoundSDK
import SwiftEventBus
import Async

protocol BottomSheetDelegate{
    func goToArtist()
    func goToAlbum()
}
class TopSongBottomSheetController: BaseVC, PanModalPresentable, createPlaylistDelegate{
    func createPlaylist(status: Bool) {
        
    }
    
    
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var lblSongDuration: UILabel!
    @IBOutlet weak var lblSongDesc: UILabel!
    @IBOutlet weak var lblSongName: UILabel!
    @IBOutlet weak var imgSong: UIImageView!
    var selectedSong:MusicPlayerModel
    private let popupContentController = R.storyboard.player.musicPlayerVC()
    var notloggedInVC:NotLoggedInHomeVC?
    var loggedInVC:Dashboard1VC?
    
    var panScrollable: UIScrollView?
    var isShortFormEnabled = true
    var shortFormHeight: PanModalHeight {
        return isShortFormEnabled ? .contentHeight(650.0) : longFormHeight
    }
    var delegate: BottomSheetDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.lblSongName.text = selectedSong.title?.htmlAttributedString
        self.lblSongDuration.text = "\(selectedSong.time ?? "" )"
        self.lblSongDesc.text = selectedSong.name
        let url = URL.init(string:selectedSong.ThumbnailImageString ?? "")
        self.imgSong.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
        
        if (selectedSong.isLiked ?? false) {
            btnLike.setImage(R.image.icHeartOrangeBs(), for: .normal)
            btnLike.isSelected = true
        }else{
            btnLike.setImage(R.image.icHeartBs(), for: .normal)
            btnLike.isSelected = false
        }
        
        SwiftEventBus.onMainThread(self, name:   EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER) { result in
            AppInstance.instance.player = nil
            if self.notloggedInVC != nil{
                self.notloggedInVC?.tabBarController?.dismissPopupBar(animated: true, completion: nil)
            }else if self.loggedInVC != nil{
                self.loggedInVC?.tabBarController?.dismissPopupBar(animated: true, completion: nil)
            }
        }
    }
    
    init(song: MusicPlayerModel,delegate: BottomSheetDelegate) {
        selectedSong = song
        self.delegate = delegate
        super.init(nibName: TopSongBottomSheetController.name, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    private func share(shareString:String?){
      
        let someText:String = shareString ?? ""
        let objectsToShare:URL = URL(string: shareString!)!
        let sharedObjects:[AnyObject] = [objectsToShare as AnyObject,someText as AnyObject]
        let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook,UIActivity.ActivityType.postToTwitter,UIActivity.ActivityType.mail,UIActivity.ActivityType.postToTencentWeibo]
        self.setSharedSongs()
        self.present(activityViewController, animated: true, completion: nil)
    }
    private func setSharedSongs(){
        log.verbose("Check = \(UserDefaults.standard.getSharedSongs(Key: Local.SHARE_SONG.Share_Song))")
        
        let objectToEncode = self.selectedSong
        let data = try? PropertyListEncoder().encode(objectToEncode)
        var getSharedSongsrData = UserDefaults.standard.getSharedSongs(Key: Local.SHARE_SONG.Share_Song)
        if UserDefaults.standard.getSharedSongs(Key: Local.SHARE_SONG.Share_Song).contains(data!){
            self.view.makeToast("Already added in shared videos")
        }else{
            getSharedSongsrData.append(data!)
            UserDefaults.standard.setSharedSongs(value: getSharedSongsrData, ForKey: Local.SHARE_SONG.Share_Song)
            self.view.makeToast("Added to shared song")
        }
    }
    private func likeDislikeSong(audioId:String){
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            let audioId = audioId ?? ""
            Async.background({
                likeManager.instance.likeDisLikeSong(audiotId: audioId, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            
                                log.debug("success = \(success?.mode ?? "")")
                                if success?.mode == "disliked"{
                                    self.btnLike.setImage(R.image.ic_heartOutlinePlayer(), for: .normal)
                                }else{
                                    self.btnLike.setImage(R.image.ic_heartRed(), for: .normal)
                                }
                            
                        })
                        
                    }else if sessionError != nil{
                        Async.main({
                           
                                log.error("sessionError = \(sessionError?.error ?? "")")
                                self.view.makeToast(sessionError?.error ?? "")
                        
                        })
                    }else {
                        Async.main({
                            
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.view.makeToast(error?.localizedDescription ?? "")
                            
                        })
                    }
                })
            })
        }else{
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
        
    }
   

    @IBAction func didTapLike(_ sender: UIButton) {
       
        if  AppInstance.instance.getUserSession(){
            sender.isSelected.toggle()
            let audioId = self.selectedSong.audioID ?? ""
            self.likeDislikeSong(audioId:audioId)
            
        }else{
            AppInstance.instance.player?.pause()
            loginAlert()
        }
    }

func loginAlert(){
    let alert = UIAlertController(title: "Login", message: "Sorry you can not continue, you must log in and enjoy access to everything you want", preferredStyle: .alert)
    let yes = UIAlertAction(title: "YES", style: .default) { (action) in
        self.appDelegate.window?.rootViewController = R.storyboard.login.main()
    }
    let no = UIAlertAction(title: "NO", style: .cancel, handler: nil)
    alert.addAction(yes)
    alert.addAction(no)
    self.present(alert, animated: true, completion: nil)
    
}
    @IBAction func didTapPlayNext(_ sender: Any) {
        let index =  self.popupContentController!.currentAudioIndex + 1
        self.popupContentController!.musicArray.append(selectedSong)
        self.dismiss(animated: true)
        
    }
    @IBAction func didTapAddToQueue(_ sender: Any) {
        self.popupContentController!.musicArray.append(selectedSong)
        self.dismiss(animated: true)
    }
    
    
    @IBAction func didTapAddToPlayList(_ sender: Any) {
        if  AppInstance.instance.getUserSession(){
            let vc = R.storyboard.popups.selectAPlaylistVC()
            vc?.createPlaylistDelegate = self
            vc?.trackId = Int(self.selectedSong.audioID ?? "0")
            self.present(vc!, animated: true, completion: nil)
        }
        else{
            AppInstance.instance.player?.pause()
            loginAlert()
        }
    }
    @IBAction func didTapGoToAlbum(_ sender: Any) {
        delegate?.goToAlbum()
        self.dismiss(animated: true)
    }
    @IBAction func didTapGoToArtist(_ sender: Any) {
        delegate?.goToArtist()
        self.dismiss(animated: true)
    }
    @IBAction func didTapDetails(_ sender: Any) {
        
        AppInstance.instance.player?.pause()
        let vc = R.storyboard.player.playerShowInfoVC()
        vc?.musicObject = selectedSong
        self.present(vc!, animated: true, completion: nil)
     
    }
    @IBAction func didTapSetAsRingtone(_ sender: Any) {
        self.dismiss(animated: true)
    }
    @IBAction func didTapAddToBlockList(_ sender: Any) {
      
        let vc = R.storyboard.popups.reportVC()
        vc?.Id = selectedSong.trackId ?? 0
        vc?.delegate = self
        self.present(vc!, animated: true, completion: nil)
       
        
    }
    @IBAction func didTapShare(_ sender: Any) {
        share(shareString: selectedSong.audioString)
    }
    @IBAction func didTapDeleteFromDevice(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
extension TopSongBottomSheetController:showToastStringDelegate{
        func showToastString(string: String) {
            self.view.makeToast(string)
        }
}
