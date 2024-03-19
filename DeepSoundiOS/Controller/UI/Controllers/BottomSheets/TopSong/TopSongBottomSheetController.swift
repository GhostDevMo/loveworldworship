//
//  SongBottomSheetController.swift
//  DeepSoundiOS
//
//  Created by Mac Pro on 02/09/2022.
//  Copyright © 2022 Moghees Idrees. All rights reserved.
//

import UIKit
import DeepSoundSDK
import SwiftEventBus
import Async

protocol BottomSheetDelegate {
    func goToArtist(artist: Publisher)
    func goToAlbum()
}

class TopSongBottomSheetController: BaseVC, PanModalPresentable {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var lblSongDuration: UILabel!
    @IBOutlet weak var lblSongDesc: UILabel!
    @IBOutlet weak var lblSongName: UILabel!
    @IBOutlet weak var imgSong: UIImageView!
    
    // MARK: - Properties
    
    var selectedSong: Song
    // private let popupContentController = R.storyboard.player.musicPlayerVC()
    var panScrollable: UIScrollView? {
        return scrollView
    }
    var isShortFormEnabled = true
    var shortFormHeight: PanModalHeight {
        return isShortFormEnabled ? .contentHeight(550.0) : longFormHeight
    }
    var delegate: BottomSheetDelegate?
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblSongName.text = selectedSong.title?.htmlAttributedString
        let time = selectedSong.duration?.components(separatedBy: ":").first
        let timeSTR = (Int(time ?? "") == 0) ? " Sec" : " Min"
        self.lblSongDuration.text = "\(selectedSong.duration ?? "")" + timeSTR
        self.lblSongDesc.text = selectedSong.publisher?.name
        let url = URL.init(string:selectedSong.songArray?.sThumbnail ?? "")
        self.imgSong.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
        
        if let isLiked = selectedSong.is_favoriated, isLiked {
            btnLike.setImage(R.image.icHeartOrangeBs(), for: .normal)
            btnLike.isSelected = true
        }else{
            btnLike.setImage(R.image.icHeartBs(), for: .normal)
            btnLike.isSelected = false
        }
    }
    
    init(song: Song, delegate: BottomSheetDelegate) {
        self.selectedSong = song
        self.delegate = delegate
        super.init(nibName: TopSongBottomSheetController.name, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Helper Functions
    
    private func share(shareString: String?) {
        let someText:String = shareString ?? ""
        let objectsToShare:URL = URL(string: shareString!)!
        let sharedObjects:[AnyObject] = [objectsToShare as AnyObject,someText as AnyObject]
        let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook,UIActivity.ActivityType.postToTwitter,UIActivity.ActivityType.mail,UIActivity.ActivityType.postToTencentWeibo]
        self.setSharedSongs()
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    private func setSharedSongs() {
        log.verbose("Check = \(UserDefaults.standard.getSharedSongs(Key: Local.SHARE_SONG.Share_Song))")
        let objectToEncode = self.selectedSong
        let data = try? PropertyListEncoder().encode(objectToEncode)
        var getSharedSongsrData = UserDefaults.standard.getSharedSongs(Key: Local.SHARE_SONG.Share_Song)
        if UserDefaults.standard.getSharedSongs(Key: Local.SHARE_SONG.Share_Song).contains(data!){
            self.view.makeToast("Already added in shared videos")
        } else {
            getSharedSongsrData.append(data!)
            UserDefaults.standard.setSharedSongs(value: getSharedSongsrData, ForKey: Local.SHARE_SONG.Share_Song)
            self.view.makeToast("Added to shared song")
        }
    }
    
    private func likeDislikeSong(audioId: String) {
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
            let audioId = audioId
            Async.background {
                LikeManager.instance.likeDisLikeSong(audiotId: audioId, AccessToken: accessToken) { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            log.debug("success = \(success?.mode ?? "")")
                        }
                    } else if sessionError != nil {
                        Async.main {
                            log.error("sessionError = \(sessionError?.error ?? "")")
                            self.view.makeToast(sessionError?.error ?? "")
                        }
                    } else {
                        Async.main {
                            log.error("error = \(error?.localizedDescription ?? "")")
                            self.view.makeToast(error?.localizedDescription ?? "")
                        }
                    }
                }
            }
        } else {
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
    private func favoriteUnFavoriteSong(audioId: String) {
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
            let audioId = audioId
            Async.background {
                FavoriteManager.instance.favoriteSong(audiotId: audioId, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            log.debug("success = \(success?.mode ?? "")")
                            if success?.mode == "Remove from favorite" {
                                self.btnLike.setImage(R.image.icHeartBs(), for: .normal)
                            } else {
                                self.btnLike.setImage(R.image.icHeartOrangeBs(), for: .normal)
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            log.error("sessionError = \(sessionError?.error ?? "")")
                            self.view.makeToast(sessionError?.error ?? "")
                        }
                    } else {
                        Async.main {
                            log.error("error = \(error?.localizedDescription ?? "")")
                            self.view.makeToast(error?.localizedDescription ?? "")
                        }
                    }
                })
            }
        } else {
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
    // MARK: - Selectors
    
    @IBAction func didTapLike(_ sender: UIButton) {
        self.view.endEditing(true)
        self.selectedSong.is_favoriated = !(self.selectedSong.is_favoriated ?? false)
        if AppInstance.instance.getUserSession() {
            let audioId = self.selectedSong.audio_id ?? ""
            self.favoriteUnFavoriteSong(audioId: audioId)
        } else {
            AppInstance.instance.player?.pause()
            self.showLoginAlert(delegate: self)
        }
    }
    
    @IBAction func didTapPlayNext(_ sender: UIButton) {
        self.view.endEditing(true)
        let index = (popupContentController?.currentAudioIndex ?? 0) + 1
        popupContentController?.musicArray.insert(selectedSong, at: index)//append(selectedSong)
        self.dismiss(animated: true)
    }
    
    @IBAction func didTapAddToQueue(_ sender: UIButton) {
        self.view.endEditing(true)
        popupContentController?.musicArray.append(selectedSong)
        self.dismiss(animated: true)
    }
    
    @IBAction func didTapAddToPlayList(_ sender: UIButton) {
        self.view.endEditing(true)
        if  AppInstance.instance.getUserSession() {
            let vc = R.storyboard.popups.selectAPlaylistVC()
            vc?.createPlaylistDelegate = self
            vc?.trackId = self.selectedSong.id
            self.present(vc!, animated: true, completion: nil)
        } else {
            AppInstance.instance.player?.pause()
            self.showLoginAlert(delegate: self)
        }
    }
    
    @IBAction func didTapGoToAlbum(_ sender: UIButton) {
        self.view.endEditing(true)
        delegate?.goToAlbum()
        self.dismiss(animated: true)
    }
    
    @IBAction func didTapGoToArtist(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true) {
            if let artist = self.selectedSong.publisher {
                self.delegate?.goToArtist(artist: artist)
            }
        }
    }
    
    @IBAction func didTapDetails(_ sender: UIButton) {
        self.view.endEditing(true)
        AppInstance.instance.player?.pause()
        let vc = R.storyboard.player.playerShowInfoVC()
        vc?.musicObject = selectedSong
        self.present(vc!, animated: true, completion: nil)
    }
    
    @IBAction func repostBtnPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true) {
            if Connectivity.isConnectedToNetwork() {
                self.showProgressDialog(text: "Please Wait....")
                Async.background {
                    RepostManager.instance.repostAPI(Id: self.selectedSong.id ?? 0) { (success, sessionError, error) in
                        if success != nil {
                            Async.main {
                                self.dismissProgressDialog {
                                    log.debug("success = \(success ?? "")")
                                    
                                    self.appDelegate.window?.rootViewController?.view.makeToast(success ?? "")
                                }
                            }
                        } else if sessionError != nil {
                            Async.main {
                                self.dismissProgressDialog {
                                    log.error("sessionError = \(sessionError ?? "")")
                                    self.appDelegate.window?.rootViewController?.view.makeToast(sessionError ?? "")
                                }
                            }
                        } else {
                            Async.main {
                                self.dismissProgressDialog {
                                    log.error("error = \(error?.localizedDescription ?? "")")
                                    self.view.makeToast(error?.localizedDescription ?? "")
                                    self.appDelegate.window?.rootViewController?.view.makeToast(sessionError ?? "")
                                }
                            }
                        }
                    }
                }
            } else {
                log.error("internetErrro = \(InterNetError)")
                self.appDelegate.window?.rootViewController?.view.makeToast(InterNetError)
            }
        }
    }
    
    @IBAction func didTapSetAsRingtone(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true)
    }
    
    @IBAction func didTapAddToBlockList(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = R.storyboard.popups.reportVC()
        vc?.Id = selectedSong.id ?? 0
        vc?.delegate = self
        self.present(vc!, animated: true, completion: nil)
    }
    
    @IBAction func didTapShare(_ sender: UIButton) {
        self.view.endEditing(true)
        var audioString: String? = ""
        let object = selectedSong
        if object.demo_track == "" {
            audioString = object.audio_location ?? ""
        } else if object.demo_track != "" && object.audio_location != "" {
            audioString = object.audio_location ?? ""
        } else {
            audioString = object.demo_track ?? ""
        }
        share(shareString: audioString)
    }
    
    @IBAction func didTapDeleteFromDevice(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true)
    }
    
}

// MARK: - Extensions

// MARK: showToastStringDelegate
extension TopSongBottomSheetController: showToastStringDelegate {
    
    func showToastString(string: String) {
        self.view.makeToast(string)
    }
    
}

// MARK: WarningPopupVCDelegate
extension TopSongBottomSheetController: WarningPopupVCDelegate {
    
    func warningPopupOKButtonPressed(_ sender: UIButton, _ songObject: Song?) {
        self.view.endEditing(true)
        if sender.tag == 1001 {
            let newVC = R.storyboard.login.loginNav()
            self.appDelegate.window?.rootViewController = newVC
        }
    }
    
}

// MARK: createPlaylistDelegate
extension TopSongBottomSheetController: createPlaylistDelegate {
    
    func createPlaylist(status: Bool) {
        if status {
            if let newVC = R.storyboard.playlist.createPlaylistVC() {
                let panVC: PanModalPresentable.LayoutType = newVC
                presentPanModal(panVC)
            }
        }
    }
    
}
