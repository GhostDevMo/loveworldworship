//
//  MusicPlayerVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 17/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.


import UIKit
import SwiftEventBus
import Async
import Alamofire
import AVFoundation
import MediaPlayer
import DeepSoundSDK
import LNPopupController

let appDelegate = UIApplication.shared.delegate as! AppDelegate

class MusicPlayerVC: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var dislikeBtn: UIButton!
    @IBOutlet weak var totalDurationLengthLabel: UILabel!
    @IBOutlet weak var calculatedTimeLenghtLabel: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var favoriteBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var circularView: UIView!
    @IBOutlet weak var titleLabel: MarqueeLabel!
    @IBOutlet weak var musicTypeLabel: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - Properties
    
    var playSpeed: Float = 1.0
    var musicObject: Song?
    var isDemo = false
    var audioString: String = ""
    var player: AVPlayer?
    var currentAudioIndex: Int?
    var repeatState = false
    var musicArray = [Song]()
    var urlString: URL?
    var shuffleArray = [Int]()
    var playerItem: AVPlayerItem?
    fileprivate let seekDuration: Float64 = 10
    var nowPlayingInfo = [String : Any]()
    var isPaused: Bool!
    var favoriteStatus: Bool = false
    var isShuffle: Bool = false
    var timeObserver: Any?
    var timeObserverAdded: Bool = false
    var delegate: BottomSheetDelegate?
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let pause = UIBarButtonItem(image: R.image.playButton(), style: .plain, target: self, action: #selector(self.playPressed))
        let next = UIBarButtonItem(image: R.image.icPlayNext()?.withTintColor(.ButtonColor), style: .plain, target: self, action: #selector(self.nextSongBottom))
        let cancel = UIBarButtonItem(image: R.image.ic_action_close(), style: .plain, target: self, action: #selector(self.cancel))
        popupItem.rightBarButtonItems = [pause,next,cancel]
        
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER) { [self] result in
            self.player?.pause()
            self.player = nil
            AppInstance.instance.AlreadyPlayed = false
            self.currentAudioIndex = nil
        }
        
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN) { (notification) in
            log.verbose("Notification = \(notification?.object as! Bool)")
            if let statusBool = notification?.object as? Bool {
                if !statusBool {
                    AppInstance.instance.AlreadyPlayed = true
                    self.player?.play()
                    pause.image = R.image.pauseSymbol()
                    self.playBtn.setImage(R.image.ic_pause(), for: .normal)
                } else {
                    AppInstance.instance.AlreadyPlayed = false
                    self.player?.pause()
                    pause.image = R.image.playButton()
                    self.playBtn.setImage(R.image.ic_playPlayer(), for: .normal)
                }
            }
        }
        log.verbose("NewCellTapped = \(musicObject?.audio_id ?? "")")
        
        let panGesture = UIPanGestureRecognizer(target: self, action:  #selector(self.panGesture))
        self.progressSlider.addGestureRecognizer(panGesture)
        self.pRemoteCommandCenter()
        self.AudioSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        popupPresentationContainer?.popupContentView.popupCloseButtonStyle = .none
        popupPresentationContainer?.popupBar.progressViewStyle = .top
        popupPresentationContainer?.popupBar.imageView.contentMode = .scaleAspectFill
        if self.player?.currentItem != nil {
            log.verbose("Item is playing")
        } else {
            if  AppInstance.instance.AlreadyPlayed {
                log.verbose("Item is playing")
            } else {
                log.verbose("Item is not Playing")
            }
        }
    }
    
    // MARK: - Selectors
    
    @IBAction func closeAction(_ sender: UIButton) {
        self.view.endEditing(true)
        popupPresentationContainer?.closePopup(animated: true, completion: nil)
    }
    
    @IBAction func songSpeedAction(_ sender: UIButton) {
        sender.setTitleColor(.mainColor, for: .normal)
        if sender.currentTitle == "1x" {
            sender.setTitle("1.5x", for: .normal)
            self.playSpeed = 1.5
        } else if sender.currentTitle == "1.5x" {
            sender.setTitle("2x", for: .normal)
            self.playSpeed = 2.0
        } else {
            sender.setTitle("1x", for: .normal)
            self.playSpeed = 1.0
        }
        player?.playImmediately(atRate: self.playSpeed)
    }
    
    @IBAction func moreBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if let object = musicObject {
            let panVC: PanModalPresentable.LayoutType = TopSongBottomSheetController(song: object, delegate: self)
            presentPanModal(panVC)
        }
    }
    
    @IBAction func fastForawardPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if player == nil { return }
        if let duration = player?.currentItem?.duration {
            let playerCurrentTime = CMTimeGetSeconds(player?.currentTime() ?? .zero)
            let newTime = playerCurrentTime + seekDuration
            if newTime < CMTimeGetSeconds(duration) {
                let selectedTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
                player?.seek(to: selectedTime)
            }
            player?.pause()
            player?.play()
        }
    }
    
    @IBAction func fastBackwardPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if player == nil { return }
        let playerCurrenTime = CMTimeGetSeconds(player?.currentTime() ?? .zero)
        var newTime = playerCurrenTime - seekDuration
        if newTime < 0 { newTime = 0 }
        player?.pause()
        let selectedTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
        player?.seek(to: selectedTime)
        player?.play()
    }
    
    @IBAction func showInfoPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        self.player?.pause()
        if let newVC = R.storyboard.player.playerShowInfoVC() {
            newVC.musicObject = self.musicArray[(currentAudioIndex ?? 0)]
            self.present(newVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func addToPlayListPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if AppInstance.instance.isLoginUser {
            if let newVC = R.storyboard.popups.selectAPlaylistVC() {
                newVC.createPlaylistDelegate = self
                newVC.trackId = self.musicArray[(currentAudioIndex ?? 0)].id ?? 0
                self.present(newVC, animated: true, completion: nil)
            }
        } else {
            self.player?.pause()
            self.showLoginAlert(delegate: self)
        }
    }
    
    @IBAction func sharedPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if let object = self.musicObject {
            if  AppInstance.instance.isLoginUser {
                var audioString:String = ""
                if object.demo_track == ""{
                    audioString = object.audio_location ?? ""
                } else if object.demo_track != "" && object.audio_location != "" {
                    audioString = object.audio_location ?? ""
                } else {
                    audioString = object.demo_track ?? ""
                }
                self.shareSong(stringURL: audioString)
            }
        } else {
            self.player?.pause()
            self.showLoginAlert(delegate: self)
        }
    }
    
    @IBAction func commentPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if  AppInstance.instance.isLoginUser {
            if let newVC = R.storyboard.comment.commentsVC() {
                newVC.trackId = self.musicArray[(currentAudioIndex ?? 0)].id ?? 0
                newVC.trackIdString = self.musicArray[(currentAudioIndex ?? 0)].audio_id ?? ""
                self.present(newVC, animated: true, completion: nil)
            }
        } else {
            self.player?.pause()
            self.showLoginAlert(delegate: self)
        }
    }
    
    @IBAction func offlinePressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if AppInstance.instance.userProfile?.data?.is_pro == 0 {
            if let warningPopupVC = R.storyboard.popups.warningPopupVC() {
                warningPopupVC.delegate = self
                warningPopupVC.titleText = "Warning"
                warningPopupVC.messageText = "To activate this service, the account must be upgraded"
                warningPopupVC.okText = "OK"
                warningPopupVC.cancelText = "CANCEL"
                self.present(warningPopupVC, animated: true, completion: nil)
                warningPopupVC.okButton.tag = 10001
            }
        } else {
            if AppInstance.instance.isLoginUser {
                self.downloadBtn.isEnabled = true
                if Connectivity.isConnectedToNetwork() {
                    if getLocalVideoAdded(url: audioString) {
                        self.view.makeToast("Already added in recently downloaded songs.", duration: 1.0)
                    } else {
                        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
                        AF.download(audioString, to: destination).downloadProgress(closure: { (progress) in
                            log.verbose("progress = \(progress)")
                            print(progress.fractionCompleted)
                        }).response(completionHandler: { (DefaultDownloadResponse) in
                            print(DefaultDownloadResponse)
                            if let error = DefaultDownloadResponse.error {
                                self.view.makeToast(error.localizedDescription)
                                return
                            }
                            Async.main {
                                self.downloadBtn.isEnabled = false
                                self.downloadBtn.setImage(R.image.ic_circularTick(), for: .normal)
                                if let object = self.musicObject,
                                   let url = URL(string: object.secure_url ?? "") {
                                    if url.lastPathComponent == DefaultDownloadResponse.fileURL?.lastPathComponent {
                                        self.setDownloadSongs(objectToEncode: object)
                                    }
                                }
                            }
                        })
                    }
                } else {
                    self.view.makeToast(InterNetError)
                }
            } else {
                self.showLoginAlert(delegate: self)
            }
        }
    }
    
    @IBAction func repeatPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        self.repeatState = !repeatState
        sender.tintColor = self.repeatState ? .mainColor : .textColor
    }
    
    @IBAction func shufflePressed(_ sender: UIButton) {
        self.view.endEditing(true)
        self.isShuffle = !isShuffle
        sender.tintColor = self.isShuffle ? .mainColor : .textColor
        shuffleArray.removeAll()
        let shuffledArray = self.musicArray.shuffled()
        self.musicArray.removeAll()
        self.musicArray = shuffledArray
    }
    
    @IBAction func nextPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        self.nextTrack()
    }
    
    @IBAction func previousPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        self.prevTrack()
    }
    
    @IBAction func favoritePressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if  AppInstance.instance.isLoginUser {
            let audioId = self.musicObject?.audio_id ?? ""
            self.favoriteUnFavoriteSong(audioId: audioId)
        } else {
            self.player?.pause()
            self.showLoginAlert(delegate: self)
        }
    }
    
    @IBAction func likedPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if  AppInstance.instance.isLoginUser {
            let audioId = self.musicObject?.audio_id ?? ""
            self.likeDislikeSong(audioId:audioId)
        } else {
            self.player?.pause()
            self.showLoginAlert(delegate: self)
        }
    }
    
    @objc func cancel() {
        self.nowPlayingInfo = [:]
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        popupContentController?.musicObject = nil
        SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER)
    }
    
    @objc func nextSongBottom() {
        nextTrack()
    }
    
    @IBAction func dislikePressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if AppInstance.instance.isLoginUser {
            let audioId = self.musicObject?.audio_id ?? ""
            self.likeDislikeTrack(audioId:audioId)
        } else {
            self.player?.pause()
            self.showLoginAlert(delegate: self)
        }
    }
    
    @IBAction func playPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.player != nil {
            if AppInstance.instance.AlreadyPlayed {
                SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
                isPaused = true
            } else {
                SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: false)
                isPaused = false
            }
        } else {
            setup()
        }
    }
    
    @objc func panGesture(_ gesture: UIPanGestureRecognizer) {
        let currentPoint = gesture.location(in: progressSlider)
        let percentage = currentPoint.x/progressSlider.bounds.size.width;
        let delta = Float(percentage) *  (progressSlider.maximumValue - progressSlider.minimumValue)
        let value = progressSlider.minimumValue + delta
        progressSlider.setValue(value, animated: true)
        let seconds : Int64 = Int64(value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        switch gesture.state {
        case .began:
            self.player?.pause()
        case .changed:
            self.player?.seek(to: targetTime)
            let time : Float64 = CMTimeGetSeconds(self.player?.currentTime() ?? .zero)
            self.calculatedTimeLenghtLabel.text = stringFromTimeInterval(interval: time)
            break
        case .ended:
            self.player?.play()
        default:
            break
        }
    }
    
    @objc func finishedPlaying( _ myNotification:NSNotification) {
        self.view.endEditing(true)
        self.isPaused = true
        self.progressSlider.value = 0
        self.calculatedTimeLenghtLabel.text = "00:00"
        self.totalDurationLengthLabel.text = "00:00"
        if !repeatState {
            self.nextTrack()
        } else {
            self.setRepeatPlay()
        }
    }
    
    @objc func playbackSliderValueChanged(sender: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                self.player?.pause()
                if let timeObserver = timeObserver {
                    if (self.timeObserverAdded) {
                        self.player?.removeTimeObserver(timeObserver)
                    }
                }
                self.timeObserverAdded = false
                break
            case .moved:
                let seconds : Int64 = Int64(sender.value)
                let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
                self.player?.seek(to: targetTime)
                self.player?.play()
                let time : Float64 = CMTimeGetSeconds(self.player?.currentTime() ?? .zero)
                self.calculatedTimeLenghtLabel.text = stringFromTimeInterval(interval: time)
            case .ended:
                self.addTimeObserver()
            default:
                break
            }
        }
    }
    
}

// MARK: - Extensions

// MARK: Helper Functions
extension MusicPlayerVC {
    
    func showLoginAlert(delegate: WarningPopupVCDelegate?) {
        self.view.endEditing(true)
        if let warningPopupVC = R.storyboard.popups.warningPopupVC() {
            warningPopupVC.delegate = self
            warningPopupVC.titleText = "Login"
            warningPopupVC.messageText = "Sorry you can not continue, you must log in and enjoy access to everything you want?"
            warningPopupVC.okText = "YES"
            warningPopupVC.cancelText = "NO"
            self.present(warningPopupVC, animated: true, completion: nil)
            warningPopupVC.okButton.tag = 1001
        }
    }
    
    func setup() {
        let object = musicArray[(currentAudioIndex ?? 0)]
        self.addToRecentlyWatched(trackId: object.audio_id ?? "")
        self.musicObject = object
        self.setupUI(object: object)
        if let can_listen = object.can_listen, can_listen {
            log.verbose("URL = \(self.audioString)")
            log.verbose("IsDemoTrack = \(isDemo)")
            let replaced = self.audioString.replacingOccurrences(of: "\(API.baseURL)/", with: "")
            log.verbose("replaced = \(replaced)")
            self.playBtn.setImage(R.image.ic_pause(), for: .normal)
            isPaused = false
            var songUrlString: String = ""
            if urlString == nil {
                if isDemo {
                    if (self.audioString.contains(find: "http")) {
                        songUrlString = audioString
                    } else {
                        songUrlString = "\(API.baseURL)/" + audioString
                    }
                } else {
                    let replaced = audioString.replacingOccurrences(of: "\(API.baseURL)/", with: "")
                    if replaced.startsWith(string: "upload") {
                        songUrlString = "\(API.baseURL)/" + replaced.htmlAttributedString!
                    } else {
                        songUrlString = replaced.htmlAttributedString!
                    }
                }
                guard let songUrl = URL(string: songUrlString) else{ return }
                self.play(url: songUrl)
            } else {
                if let url = self.urlString {
                    self.play(url: url)
                }
            }
            AppInstance.instance.AlreadyPlayed = true
        } else {
            if let warningPopupVC = R.storyboard.popups.purchaseRequiredPopupVC() {
                warningPopupVC.delegate = self
                warningPopupVC.object = object
                appDelegate.window?.rootViewController?.present(warningPopupVC, animated: true, completion: nil)
            }
        }
    }
    
    func setupUI(object: Song) {
        if object.demo_track == "" {
            audioString = object.audio_location ?? ""
            isDemo = false
        } else if object.demo_track != "" && object.audio_location != "" {
            audioString = object.audio_location ?? ""
            isDemo = false
        } else {
            audioString = object.demo_track ?? ""
            isDemo = true
        }
        if ControlSettings.showHideDownloadBtn {
            self.downloadBtn.isHidden = true
        } else {
            checkOfflineDownload()
        }
        log.verbose("Music Object = \(musicArray)")
        self.musicArray.forEach { (it) in
            log.verbose("Music Object = \(it.title ?? "")")
        }
        self.playBtn.cornerRadiusV = self.playBtn.frame.height / 2
        self.titleLabel.text = object.title?.htmlAttributedString
        self.totalDurationLengthLabel.text = object.duration
        var album_name = ""
        if object.album_name != "" {
            album_name = "in album \(object.album_name ?? "")"
        }
        self.musicTypeLabel.text = (object.songArray?.sCategory ?? "") + " Music" + album_name
        self.popupItem.title = object.title?.htmlAttributedString ?? ""
        let thumbnailURL = URL.init(string:object.songArray?.sThumbnail ?? "")
        thumbnailImage.sd_setImage(with: thumbnailURL, placeholderImage: R.image.imagePlacholder()) { image, err, type, url in
            if let image = image {
                self.popupItem.image = image
            } else {
                self.popupItem.image = R.image.imagePlacholder()
            }
        }
        if let isLiked = object.isLiked, isLiked {
            likeBtn.setImage(R.image.icHeartOrangeBs(), for: .normal)
        } else {
            likeBtn.setImage(R.image.icHeartBs(), for: .normal)
        }
        if let is_favoriated = object.is_favoriated, !is_favoriated {
            self.favoriteBtn.setImage(R.image.ic_starPlayer(), for: .normal)
            self.favoriteBtn.tintColor = UIColor(named: "textColor")
        } else {
            self.favoriteBtn.setImage(UIImage(named: "icn_fill_star")?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.favoriteBtn.tintColor = .mainColor
        }
    }
    
    func play(url: URL) {
        Async.background({ [self] in
            playerItem = AVPlayerItem(url: url)
            self.player = AVPlayer(playerItem: playerItem)
            NotificationCenter.default.addObserver(self, selector: #selector(self.finishedPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
            self.player?.volume = 1.0
            self.player?.playImmediately(atRate: self.playSpeed)
            self.isPaused = false
            Async.main { [self] in
                self.progressSlider.minimumValue = 0
                let duration : CMTime = playerItem?.asset.duration ?? .zero
                let seconds : Float64 = CMTimeGetSeconds(duration)
                self.totalDurationLengthLabel.text = stringFromTimeInterval(interval: seconds)
                let duration1 : CMTime = playerItem?.currentTime() ?? .zero
                let seconds1 : Float64 = CMTimeGetSeconds(duration1)
                self.calculatedTimeLenghtLabel.text = stringFromTimeInterval(interval: seconds1)
                self.progressSlider.maximumValue = Float(seconds)
                self.progressSlider.isContinuous = true
                self.player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
                self.addTimeObserver()
            }
        })
    }
    
    // MARK: Player Observer
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentItem.loadedTimeRanges" {
            self.player?.removeObserver(self, forKeyPath: "currentItem.loadedTimeRanges")
            self.setupNowPlaying(title: self.musicObject?.title ?? "", image: self.thumbnailImage.image ?? UIImage())
        }
    }
    
    func addTimeObserver() {
        timeObserver = self.player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { [self] (CMTime) -> Void in
            self.timeObserverAdded = true
            if playerItem?.status == .readyToPlay {
                let time : Float64 = CMTimeGetSeconds(self.player?.currentTime() ?? .zero)
                self.progressSlider.value = Float(time)
                self.calculatedTimeLenghtLabel.text = stringFromTimeInterval(interval: time)
                self.nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.player?.currentItem?.currentTime().seconds
                self.nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.player?.rate
                MPNowPlayingInfoCenter.default().nowPlayingInfo = self.nowPlayingInfo
            }
            let playbackLikelyToKeepUp = self.player?.currentItem?.isPlaybackLikelyToKeepUp
            if playbackLikelyToKeepUp == false {
                print("IsBuffering")
            } else {
                print("Buffering completed")
            }
        }
    }
    
    func setRepeatPlay() {
        var songUrlString: String = ""
        if isDemo {
            if (self.audioString.contains(find: "http")) {
                songUrlString  = audioString
            } else {
                songUrlString  = "\(API.baseURL)/"+audioString
            }
        } else {
            let replaced = audioString.replacingOccurrences(of: "\(API.baseURL)/", with: "")
            if replaced.startsWith(string: "upload"){
                songUrlString  = "\(API.baseURL)/"+replaced.htmlAttributedString!
            } else {
                songUrlString  = replaced.htmlAttributedString!
            }
        }
        guard let songUrl = URL(string:songUrlString) else{return}
        self.play(url: songUrl)
    }
    
    func setupNowPlaying(title : String, image: UIImage) {
        self.nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork.init(boundsSize: image.size, requestHandler: { (size) -> UIImage in
            return image
        })
        self.nowPlayingInfo[MPMediaItemPropertyTitle] = ControlSettings.appName
        self.nowPlayingInfo[MPMediaItemPropertyArtist] = title
        self.nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = false
        self.nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = self.player?.currentItem?.asset.duration.seconds
        self.nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.player?.currentItem?.currentTime().seconds
        self.nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.player?.rate
        MPNowPlayingInfoCenter.default().nowPlayingInfo = self.nowPlayingInfo
        MPNowPlayingInfoCenter.default().playbackState = .playing
    }
    
    func AudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func pRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared();
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { event in
            self.playPressed(self.playBtn)
            return .success
        }
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { event in
            self.playPressed(self.playBtn)
            return .success
        }
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget { event in
            self.nextTrack()
            return .success
        }
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget { event in
            self.prevTrack()
            return .success
        }
    }
    
    func nextTrack() {
        self.player = nil
        AppInstance.instance.AlreadyPlayed = false
        if((currentAudioIndex ?? 0) < musicArray.count-1) {
            currentAudioIndex = (currentAudioIndex ?? 0) + 1
        } else {
            self.playBtn.cornerRadiusV = self.playBtn.frame.height / 2
            currentAudioIndex = 0
        }
        self.setup()
        SwiftEventBus.postToMainThread("EVENT_NEXT_TRACK_BTN", sender: true)
    }
    
    func prevTrack() {
        if((currentAudioIndex ?? 0) > 0) {
            currentAudioIndex = (currentAudioIndex ?? 0) - 1
            isPaused = false
            self.setup()
        }
        SwiftEventBus.postToMainThread("EVENT_NEXT_TRACK_BTN", sender: true)
    }
    
    private func checkOfflineDownload() {
        if getLocalVideoAdded(url: audioString) {
            self.downloadBtn.isEnabled = false
            self.downloadBtn.setImage(R.image.icn_downloaded_song(), for: .normal)
            if let audioUrl = URL(string: self.audioString) {
                let fileManager = FileManager.default
                let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
                if let documentDirectoryURL = urls.first {
                    let playYoda = documentDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
                    print("playYoda is \(playYoda)")
                    self.urlString = playYoda
                    AppInstance.instance.playSongBool = true
                }
            }
        } else {
            self.downloadBtn.isEnabled = true
            self.downloadBtn.setImage(R.image.download(), for: .normal)
            AppInstance.instance.playSongBool = false
            self.urlString = nil
        }
    }
    
    private func shareSong(stringURL: String) {
        let someText:String = stringURL
        if let objectsToShare:URL = URL(string: stringURL) {
            let sharedObjects:[AnyObject] = [objectsToShare as AnyObject,someText as AnyObject]
            let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook,UIActivity.ActivityType.postToTwitter,UIActivity.ActivityType.mail,UIActivity.ActivityType.postToTencentWeibo]
            self.setSharedSongs()
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    private func setSharedSongs() {
        log.verbose("Check = \(UserDefaults.standard.getSharedSongs(Key: Local.SHARE_SONG.Share_Song))")
        let objectToEncode = self.musicArray[(currentAudioIndex ?? 0)]
        let data = try? PropertyListEncoder().encode(objectToEncode)
        var getSharedSongsrData = UserDefaults.standard.getSharedSongs(Key: Local.SHARE_SONG.Share_Song)
        if let data = data {
            if UserDefaults.standard.getSharedSongs(Key: Local.SHARE_SONG.Share_Song).contains(data){
                appDelegate.window?.rootViewController?.view.makeToast("Already added in shared videos")
            } else {
                getSharedSongsrData.append(data)
                UserDefaults.standard.setSharedSongs(value: getSharedSongsrData, ForKey: Local.SHARE_SONG.Share_Song)
                appDelegate.window?.rootViewController?.view.makeToast("Added to shared song")
            }
        }
    }
    
    private func setDownloadSongs(objectToEncode: Song) {
        log.verbose("Check = \(UserDefaults.standard.getDownloadSongs(Key: Local.SHARE_SONG.Share_Song))")
        do {
            let data = try PropertyListEncoder().encode(objectToEncode)
            var getDownloadSongsrData = UserDefaults.standard.getDownloadSongs(Key: Local.DOWNLOAD_SONG.Download_Song)
            getDownloadSongsrData.append(data)
            UserDefaults.standard.setDownloadSongs(value: getDownloadSongsrData, ForKey: Local.DOWNLOAD_SONG.Download_Song)
            appDelegate.window?.rootViewController?.view.makeToast("Added to recently downloaded songs", duration: 1.0)
        } catch {
            appDelegate.window?.rootViewController?.view.makeToast(error.localizedDescription)
        }
    }
    
}

// MARK: - API Call
extension MusicPlayerVC {
    
    func addToRecentlyWatched(trackId: String) {
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
            let track_id = trackId
            Async.background {
                TrackManager.instance.getTrackInfo(TrackId: track_id, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            log.debug("userList = \(success?.status ?? 0)")
                        }
                    } else if sessionError != nil {
                        Async.main {
                            log.error("sessionError = \(sessionError?.error ?? "")")
                        }
                    } else {
                        Async.main{
                            log.error("error = \(error?.localizedDescription ?? "")")
                        }
                    }
                })
            }
        } else {
            log.error("internetError = \(InterNetError)")
            appDelegate.window?.rootViewController?.view.makeToast(InterNetError)
        }
    }
    
    private func likeDislikeSong(audioId: String) {
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
            let audioId = audioId
            Async.background {
                LikeManager.instance.likeDisLikeSong(audiotId: audioId, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            log.debug("success = \(success?.mode ?? "")")
                            if success?.mode != "disliked" {
                                self.likeBtn.setImage(R.image.icHeartOrangeBs(), for: .normal)
                            } else {
                                self.likeBtn.setImage(R.image.icHeartBs(), for: .normal)
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            log.error("sessionError = \(sessionError?.error ?? "")")
                            appDelegate.window?.rootViewController?.view.makeToast(sessionError?.error ?? "")
                        }
                    } else {
                        Async.main {
                            log.error("error = \(error?.localizedDescription ?? "")")
                            appDelegate.window?.rootViewController?.view.makeToast(error?.localizedDescription ?? "")
                        }
                    }
                })
            }
        } else {
            log.error("internetErrro = \(InterNetError)")
            appDelegate.window?.rootViewController?.view.makeToast(InterNetError)
        }
    }
    
    private func likeDislikeTrack(audioId: String) {
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
            let audioId = audioId
            Async.background {
                LikeManager.instance.likeDisLikeTrack(audiotId: audioId, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            log.debug("success = \(success?.mode ?? "")")
                            if success?.mode == "disliked" {
                                self.dislikeBtn.setImage(UIImage(named: "ic-dislike-heart-fill"), for: .normal)
                            } else {
                                self.dislikeBtn.setImage(UIImage(named: "ic-dislike-heart-border"), for: .normal)
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            log.error("sessionError = \(sessionError?.error ?? "")")
                            appDelegate.window?.rootViewController?.view.makeToast(sessionError?.error ?? "")
                        }
                    } else {
                        Async.main {
                            log.error("error = \(error?.localizedDescription ?? "")")
                            appDelegate.window?.rootViewController?.view.makeToast(error?.localizedDescription ?? "")
                        }
                    }
                })
            }
        } else {
            log.error("internetErrro = \(InterNetError)")
            appDelegate.window?.rootViewController?.view.makeToast(InterNetError)
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
                                self.favoriteBtn.setImage(R.image.ic_starPlayer(), for: .normal)
                                self.favoriteBtn.tintColor = UIColor(named: "textColor")
                            } else {
                                self.favoriteBtn.setImage(UIImage(named: "icn_fill_star")?.withRenderingMode(.alwaysTemplate), for: .normal)
                                self.favoriteBtn.tintColor = .mainColor
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            log.error("sessionError = \(sessionError?.error ?? "")")
                            appDelegate.window?.rootViewController?.view.makeToast(sessionError?.error ?? "")
                        }
                    } else {
                        Async.main {
                            log.error("error = \(error?.localizedDescription ?? "")")
                            appDelegate.window?.rootViewController?.view.makeToast(error?.localizedDescription ?? "")
                        }
                    }
                })
            }
        } else {
            log.error("internetErrro = \(InterNetError)")
            appDelegate.window?.rootViewController?.view.makeToast(InterNetError)
        }
    }
    
    private func purchaseSong(trackId: Int) {
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userid = AppInstance.instance.userId ?? 0
            Async.background {
                PurchaseTrackManager.instance.purchaseTrack(AccessToken: accessToken, userId: userid, TrackId: trackId, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main {
                            log.debug("userList = \(success?.message ?? "")")
                        }
                    } else if sessionError != nil {
                        Async.main {
                            appDelegate.window?.rootViewController?.view.makeToast(sessionError?.error ?? "")
                            log.error("sessionError = \(sessionError?.error ?? "")")
                        }
                    } else {
                        Async.main {
                            appDelegate.window?.rootViewController?.view.makeToast(error?.localizedDescription ?? "")
                            log.error("error = \(error?.localizedDescription ?? "")")
                        }
                    }
                })
            }
        } else {
            log.error("internetError = \(InterNetError)")
            appDelegate.window?.rootViewController?.view.makeToast(InterNetError)
        }
    }
    
    private func purchaseSongWallet(trackId: String) {
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background {
                UpgradeMemberShipManager.instance.purchaseTrack(AccessToken: accessToken, type: "buy_song", TrackID: trackId) { success, sessionError, error in
                    if success != nil {
                        Async.main {
                            log.debug("userList = \(success ?? "")")
                            appDelegate.window?.rootViewController?.view.makeToast(success ?? "")
                        }
                    } else if sessionError != nil {
                        Async.main {
                            appDelegate.window?.rootViewController?.view.makeToast(sessionError ?? "")
                            log.error("sessionError = \(sessionError ?? "")")
                        }
                    } else {
                        Async.main {
                            appDelegate.window?.rootViewController?.view.makeToast(error?.localizedDescription ?? "")
                            log.error("error = \(error?.localizedDescription ?? "")")
                        }
                    }
                }
            }
        } else {
            log.error("internetError = \(InterNetError)")
            appDelegate.window?.rootViewController?.view.makeToast(InterNetError)
        }
    }
    
}

// MARK: Create PlayList delegate Methods
extension MusicPlayerVC: createPlaylistDelegate {
    
    func createPlaylist(status: Bool) {
        if status {
            if let newVC = R.storyboard.playlist.createPlaylistVC() {
                let panVC: PanModalPresentable.LayoutType = newVC
                presentPanModal(panVC)
            }
        }
    }
    
}

// MARK: Warning Popup Delegate Methods
extension MusicPlayerVC: WarningPopupVCDelegate {
    
    func warningPopupOKButtonPressed(_ sender: UIButton, _ songObject: Song?) {
        self.view.endEditing(true)
        if sender.tag == 1001 {
            let newVC = R.storyboard.login.loginNav()
            appDelegate.window?.rootViewController = newVC
        }
    }
    
}

// MARK: Purchase Required Popup Delegate Methods
extension MusicPlayerVC: PurchaseRequiredPopupDelegate {
    
    func purchaseButtonPressed(_ sender: UIButton, _ songObject: Song?) {
        self.view.endEditing(true)
        if AppInstance.instance.isLoginUser {
            if let object = songObject {
                let sell_music = object.price ?? 0.0
                print("Amount >>>>>", sell_music)
                AppInstance.instance.fetchUserProfile(isNew: true) { success in
                    if success {
                        let walletBalance = AppInstance.instance.userProfile?.data?.wallet?.doubleValue() ?? 0.0
                        if sell_music < walletBalance {
                            self.purchaseSongWallet(trackId: songObject?.audio_id ?? "")
                        } else {
                            let warningPopupVC = R.storyboard.popups.warningPopupVC()
                            warningPopupVC?.delegate = self
                            warningPopupVC?.okButton.tag = 1003
                            warningPopupVC?.titleText  = "Wallet"
                            warningPopupVC?.messageText = "Sorry, You do not have enough money please top up your wallet"
                            warningPopupVC?.okText = "ADD WALLET"
                            appDelegate.window?.rootViewController?.present(warningPopupVC!, animated: true, completion: nil)
                        }
                    }
                }
            }
        } else {
            self.showLoginAlert(delegate: self)
        }
    }
    
}

func stringFromTimeInterval(interval: TimeInterval) -> String {
    let interval = Int(interval)
    let seconds = interval % 60
    let minutes = (interval / 60) % 60
    return String(format: "%02d:%02d", minutes, seconds)
}

// MARK: BottomSheet Delegate Methods
extension MusicPlayerVC: BottomSheetDelegate {
    
    func goToArtist(artist: Publisher) {
        self.view.endEditing(true)
        popupPresentationContainer?.closePopup(animated: true) {
            self.delegate?.goToArtist(artist: artist)
        }
    }
    
    func goToAlbum() {
        self.delegate?.goToAlbum()
    }
    
}
