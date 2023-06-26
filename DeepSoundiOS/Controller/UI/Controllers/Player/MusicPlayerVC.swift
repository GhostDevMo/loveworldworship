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
import CircleProgressView
import AVFoundation
import MediaPlayer
import DeepSoundSDK
import LNPopupController

class MusicPlayerVC: BaseVC {
    
    @IBOutlet weak var showWiteLine: UIImageView!
    @IBOutlet weak var dislikeBtn: UIButton!
    @IBOutlet weak var totalDurationLengthLabel: UILabel!
    @IBOutlet weak var calculatedTimeLenghtLabel: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var progressCircularView: CircleProgressView!
    @IBOutlet weak var favoriteBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var circularView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: MarqueeLabel!
    @IBOutlet weak var backGroundImage: UIImageView!
    @IBOutlet weak var musicTypeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pushUPView: UIView!
    @IBOutlet weak var pushUpimg: UIImageView!
    
    //    var payPalConfig = PayPalConfiguration() // default
    //    var environment:String = PayPalEnvironmentSandbox {
    //        willSet(newEnvironment) {
    //            if (newEnvironment != environment) {
    //                PayPalMobile.preconnect(withEnvironment: newEnvironment)
    //            }
    //        }
    //    }
    
    
    var musicObject:MusicPlayerModel?
    private var player1:AVAudioPlayer?
    var player = AVPlayer()
    var audioLength:Double? = 0.0
    var audioPlayer:AVAudioPlayer! = nil
    var totalLengthOfAudio = ""
    var currentAudioIndex = 0
    var timer:Timer!
    var shuffleState = false
    var repeatState = false
    var musicArray = [MusicPlayerModel]()
    var urlString:URL?
    var shuffleArray = [Int]()
    var status:Bool? = false
    var scrolled:Bool = false
    var songCodeStatus:Int? = 0
    var nowPlayingInfo = [String : Any]()
    
    let playerTimescale = AppInstance.instance.player?.currentItem?.asset.duration.timescale ?? 1
    
    
    var timer1: Timer?
    var index: Int = Int()
    var isPaused: Bool!
    var favoriteStatus:Bool? = false
    var isShuffle:Bool? = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //rotateThumbnailImageContinuously()
        let pause = UIBarButtonItem(image: R.image.playButton(), style: .plain, target: self, action: #selector(self.playPause))
        let next = UIBarButtonItem(image: R.image.icPlayNext()?.withTintColor(.ButtonColor), style: .plain, target: self, action: #selector(self.nextSongBottom))
        let cancel = UIBarButtonItem(image: R.image.ic_action_close(), style: .plain, target: self, action: #selector(self.cancel))
        
        
        popupItem.rightBarButtonItems = [ pause,next,cancel ]
        
        if UIApplication.shared.responds(to: #selector(UIApplication.beginReceivingRemoteControlEvents)){
            UIApplication.shared.beginReceivingRemoteControlEvents()
            UIApplication.shared.beginBackgroundTask(expirationHandler: { () -> Void in
            })
        }
        
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN) { (notification) in
            log.verbose("Notification = \(notification?.object as? Bool)")
            let statusBool = notification?.object as? Bool
            if statusBool!{
                AppInstance.instance.player?.play()
                pause.image = R.image.pauseSymbol()
                self.playBtn.setImage(R.image.ic_pause(), for: .normal)
                
            }else{
                AppInstance.instance.player?.pause()
                pause.image = R.image.playButton()
                self.playBtn.setImage(R.image.ic_playPlayer(), for: .normal)
                
            }
        }
        log.verbose("NewCellTapped = \(musicObject?.audioID)")
        
    }
    
    @objc func cancel(){
        SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER)
        
    }
    @objc func nextSongBottom(){
        nextTrack()
        setup()
    }
    
    @objc func playPause(){
    
        if AppInstance.instance.AlreadyPlayed!{
            
            if AppInstance.instance.player?.timeControlStatus == .playing { SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: false)
            }else{
                SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
            }
        }else{
            setup()
        }
        
        
        
        
        print("playPausePressed")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //rotateThumbnailImageContinuously()
        //        PayPalMobile.preconnect(withEnvironment: environment)
        
        log.verbose("SongCodeStatus = \(self.songCodeStatus!)")
        if AppInstance.instance.player?.currentItem != nil{
            log.verbose("Item is playing")
        }else{
            if  AppInstance.instance.AlreadyPlayed!{
                log.verbose("Item is playing")
                
            }else{
                log.verbose("Item is not Playing")
                self.setup()
                
            }
            
        }
    }
    
    @IBAction func dislikePressed(_ sender: Any) {
        if  AppInstance.instance.getUserSession(){
                   let audioId = self.musicObject?.audioID ?? ""
                   self.likeDislikeTrack(audioId:audioId)
                   
               }else{
                   AppInstance.instance.player?.pause()
                   self.loginAlert()
                }
    }
    @IBAction func playPressed(_ sender: AnyObject) {
        
        self.togglePlayPause()
    }
    
    @IBAction func didPressPushUp(_ sender: UIButton) {
        
        if !scrolled{
        self.scrollView.setContentOffset(CGPoint(x: 0, y: self.pushUPView.frame.minY), animated: true)
            scrolled = true
            pushUpimg.image = R.image.ic_action_arrow_down_sign()
        }
        else{
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            scrolled = false
            pushUpimg.image = R.image.icScrollupArrow()
        }
    }
    func togglePlayPause() {
        if AppInstance.instance.player?.timeControlStatus == .playing  {
            self.playBtn.setImage(R.image.ic_playPlayer(), for: .normal)
            AppInstance.instance.player?.pause()
            SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: false)
            isPaused = true
        } else {
            self.playBtn.setImage(R.image.ic_pause(), for: .normal)
            AppInstance.instance.player?.play()
            SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
            isPaused = false
        }
    }
    
    
    func setup(){
        self.showWiteLine.isHidden = true
        self.downloadBtn.isHidden = true
        if ControlSettings.showHideDownloadBtn{
            self.downloadBtn.isHidden = true
            self.progressCircularView.isHidden = true
            self.showWiteLine.isHidden = true
                  
        }else{
           // self.downloadBtn.isHidden = false
           // self.progressCircularView.isHidden = false
            //self.showWiteLine.isHidden = false

             checkOfflineDownload()
        }
//        if !AppInstance.instance.getUserSession(){
//            dislikeBtn.isHidden = true
//            likeBtn.isHidden = true
//
//        }
//        else{
//
//        }
        log.verbose("Music Object = \(musicArray)")
        self.musicArray.forEach { (it) in
            log.verbose("Music Object = \(it.title ?? "")")
        }

        self.playBtn.cornerRadiusV = self.playBtn.frame.height / 2
        self.nameLabel.text = self.musicArray[currentAudioIndex].name ?? ""
        self.titleLabel.text = self.musicArray[currentAudioIndex].title?.htmlAttributedString ?? ""
        
        self.timeLabel.text = self.musicArray[currentAudioIndex].time ?? ""
        self.musicTypeLabel.text = (self.musicArray[currentAudioIndex].musicType ?? "") + " Music"
        let thumbnailURL = URL.init(string:self.musicArray[currentAudioIndex].ThumbnailImageString ?? "")
        thumbnailImage.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
       // backGroundImage.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
        if (self.musicArray[currentAudioIndex].isLiked ?? false) {
            likeBtn.setImage(R.image.icHeartOrangeBs(), for: .normal)
        }else{
            likeBtn.setImage(R.image.icHeartBs(), for: .normal)
        }
        
        if (self.musicArray[currentAudioIndex].isFavorite!) {
            favoriteBtn.setImage(R.image.ic_starYellow(), for: .normal)
            
        }else{
            favoriteBtn.setImage(R.image.ic_starPlayer(), for: .normal)
        }
        
        //self.rotateThumbnailImageContinuously()
        log.verbose("URL = \(self.musicArray[currentAudioIndex].audioString ?? "")")
        log.verbose("IsDemoTrack = \(self.musicArray[currentAudioIndex].isDemoTrack ?? false)")
        let replaced = self.musicArray[currentAudioIndex].audioString!.replacingOccurrences(of: "\(API.baseURL)/", with: "")
        log.verbose("replaced = \(replaced)")
        self.playBtn.setImage(R.image.ic_pause(), for: .normal)
        isPaused = false
        var songUrlString:String? = ""
        if musicArray[self.currentAudioIndex].isDemoTrack!{
            if (musicArray[self.currentAudioIndex].audioString?.contains(find: "http"))!{
                songUrlString  = musicArray[self.currentAudioIndex].audioString!
            }else{
                songUrlString  = "\(API.baseURL)/"+musicArray[self.currentAudioIndex].audioString!
            }
            
        }else{
            let replaced = self.musicArray[currentAudioIndex].audioString!.replacingOccurrences(of: "\(API.baseURL)/", with: "")
            if replaced.startsWith(string: "upload"){
                songUrlString  = "\(API.baseURL)/"+replaced.htmlAttributedString!
            }else{
                songUrlString  = replaced.htmlAttributedString!
            }
        }
        //        guard let songUrlString = musicArray[self.currentAudioIndex].audioString as? String else {return}
        guard let songUrl = URL(string:songUrlString!) else{return}
        //        self.setupRemoteCommandCenter()
        
        self.play(url: songUrl)
        
        self.setupTimer()
        self.pRemoteCommandCenter()
        self.AudioSession()
        Async.main({
            self.setupNowPlaying(title: self.musicObject?.title ?? "", image: self.thumbnailImage.image ?? UIImage())
        })
        AppInstance.instance.AlreadyPlayed = true
    }
    
    func setupNowPlaying(title : String, image: UIImage) {
        // Define Now Playing Info
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = ControlSettings.appName
        nowPlayingInfo[MPMediaItemPropertyArtist] = title
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = false
        
        //        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playerItem.currentTime().seconds
        //        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = playerItem.asset.duration.seconds
        //        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        
        Async.main({
            let image =  image //self.trackImage!.image!
            let artwork = MPMediaItemArtwork.init(boundsSize: image.size, requestHandler: { (size) -> UIImage in
                return image
            })
            self.nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        })
        
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        MPNowPlayingInfoCenter.default().playbackState = .playing
    }
    
    func AudioSession() {
        do {
            try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, options: [])
            try! AVAudioSession.sharedInstance().setCategory(.playback)
            
            try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.mixWithOthers)
            
            //            try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: [])
            
            if #available(iOS 10.0, *) {
                try! AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            }
            else {
                // Workaround until https://forums.swift.org/t/using-methods-marked-unavailable-in-swift-4-2/14949 isn't fixed
                AVAudioSession.sharedInstance().perform(NSSelectorFromString("setCategory:error:"), with: AVAudioSession.Category.playback)
            }
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            debugPrint("Error setting the AVAudioSession:", error.localizedDescription)
        }
    }
    
    func pRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared();
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget {event in
            self.playPause()
            return .success
        }
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget {event in
            self.playPause()
            
            return .success
        }
        commandCenter.seekForwardCommand.isEnabled = true
        commandCenter.seekForwardCommand.addTarget {event in
            self.nextTrack()
            
            return .success
        }
        commandCenter.seekBackwardCommand.addTarget {event in
            self.prevTrack()
            return .success
        }
    }
    func setupTimer(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.didPlayToEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        timer = Timer(timeInterval: 0.001, target: self, selector: #selector(self.tick), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.common)
    }
    
    @objc func didPlayToEnd() {
        if ControlSettings.isPurchase{
            if self.musicArray[self.currentAudioIndex].isDemoTrack!{
                
                let alert = UIAlertController(title: "nil", message: "To continue listening to this track, you need to purchase the song", preferredStyle: .alert)
                let ok = UIAlertAction(title: "Pay", style: .default) { (action) in
                    let alertA = UIAlertController(title: "Pay", message: "", preferredStyle: .actionSheet)
                    let wallet = UIAlertAction(title: "Wallet", style: .default) { action in
                        log.verbose("Wallet")
                        self.purchaseSongWallet(trackId: self.musicArray[self.currentAudioIndex].audioID ?? "")
                    }
                    let cancel =  UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
                    alertA.addAction(wallet)
                    alertA.addAction(cancel)
                    self.present(alertA, animated: true, completion: nil)
                }
                let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
                alert.addAction(ok)
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
            }else{
                self.nextTrack()
                
            }
        }else{
            if repeatState {
                currentTrack()
            } else {
                self.nextTrack()
            }
        }
        
        
    }
    
    @objc func tick(){
        if(isPaused == false){
            if(AppInstance.instance.player?.rate == nil){
                AppInstance.instance.player?.play()
                
            }else{
            }
            
        }
        
        if((AppInstance.instance.player?.currentItem?.asset.duration) != nil){
            if AppInstance.instance.player?.currentItem?.status == .readyToPlay {
                if let _ = AppInstance.instance.player?.currentItem?.asset.duration{}else{return}
                if let _ = AppInstance.instance.player?.currentItem?.currentTime(){}else{return}
                let currentTime1 : CMTime = (AppInstance.instance.player?.currentItem?.asset.duration)!
                let seconds1 : Float64 = CMTimeGetSeconds(currentTime1)
                let time1 : Float = Float(seconds1)
                
                let timeData = musicObject?.duration ?? "0:0"
                let parts = timeData.split(separator: ":")
                let minutesData = Int(parts[0])!
                let secondsData = Int(parts[1])!
                let totalData = minutesData * 60 + secondsData
                print(totalData)
                
                
                progressSlider.minimumValue = 0
                progressSlider.maximumValue = Float(totalData)
                
                let currentTime : CMTime = ((AppInstance.instance.player?.currentTime())!)
                let seconds : Float64 = CMTimeGetSeconds(currentTime)
                let time : Float = Float(seconds)
                self.progressSlider.value = time
                totalDurationLengthLabel.text =  self.formatTimeFromSeconds(totalSeconds: Int32(Float(totalData)))
                calculatedTimeLenghtLabel.text = self.formatTimeFromSeconds(totalSeconds: Int32(Float(Float64(CMTimeGetSeconds((AppInstance.instance.player?.currentItem?.currentTime())!)))))
            } else {
                progressSlider.value = 0
                progressSlider.minimumValue = 0
                progressSlider.maximumValue = 0
            }
        }else{
            progressSlider.value = 0
            progressSlider.minimumValue = 0
            progressSlider.maximumValue = 0
            //            totalTime.text = "Live stream \(self.formatTimeFromSeconds(totalSeconds: Int32(CMTimeGetSeconds((AppInstance.instance.player?.currentItem?.currentTime() ?? CMTime())))))"
        }
    }
    func nextTrack(){
        
        if(currentAudioIndex < musicArray.count-1){
            currentAudioIndex = currentAudioIndex + 1
            isPaused = false
            
            self.playBtn.setImage(R.image.ic_pause(), for: .normal)
            self.play(url: URL(string:(musicArray[self.currentAudioIndex].audioString!))!)
            self.nameLabel.text = self.musicArray[currentAudioIndex].name ?? ""
            self.titleLabel.text = self.musicArray[currentAudioIndex].title?.htmlAttributedString ?? ""
            
            self.timeLabel.text = self.musicArray[currentAudioIndex].time ?? ""
            self.musicTypeLabel.text = (self.musicArray[currentAudioIndex].musicType ?? "") + " Music"
            let thumbnailURL = URL.init(string:self.musicArray[currentAudioIndex].ThumbnailImageString ?? "")
            thumbnailImage.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
            popupItem.image = thumbnailImage.image
            popupItem.title = self.musicArray[currentAudioIndex].name ?? ""
            popupItem.subtitle = self.musicArray[currentAudioIndex].title?.htmlAttributedString ?? ""
           // backGroundImage.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
            if (self.musicArray[currentAudioIndex].isLiked ?? false) {
                likeBtn.setImage(R.image.icHeartOrangeBs(), for: .normal)
            }else{
                likeBtn.setImage(R.image.icHeartBs(), for: .normal)
            }
            
            if (self.musicArray[currentAudioIndex].isFavorite!) {
                favoriteBtn.setImage(R.image.ic_starYellow(), for: .normal)
                
            }else{
                favoriteBtn.setImage(R.image.ic_starPlayer(), for: .normal)
            }
            
           // self.rotateThumbnailImageContinuously()
            
        }else{
            self.playBtn.cornerRadiusV = self.playBtn.frame.height / 2
            self.nameLabel.text = self.musicArray[currentAudioIndex].name ?? ""
            self.titleLabel.text = self.musicArray[currentAudioIndex].title?.htmlAttributedString ?? ""
            
            self.timeLabel.text = self.musicArray[currentAudioIndex].time ?? ""
            self.musicTypeLabel.text = (self.musicArray[currentAudioIndex].musicType ?? "") + " Music"
            let thumbnailURL = URL.init(string:self.musicArray[currentAudioIndex].ThumbnailImageString ?? "")
            thumbnailImage.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
            popupItem.image = thumbnailImage.image
            popupItem.title = self.musicArray[currentAudioIndex].name ?? ""
            popupItem.subtitle = self.musicArray[currentAudioIndex].title?.htmlAttributedString ?? ""
          //  backGroundImage.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
            if (self.musicArray[currentAudioIndex].isLiked ?? false) {
                likeBtn.setImage(R.image.icHeartOrangeBs(), for: .normal)
            }else{
                likeBtn.setImage(R.image.icHeartBs(), for: .normal)
            }
            
            if (self.musicArray[currentAudioIndex].isFavorite!) {
                favoriteBtn.setImage(R.image.ic_starYellow(), for: .normal)
                
            }else{
                favoriteBtn.setImage(R.image.ic_starPlayer(), for: .normal)
            }
            
            //self.rotateThumbnailImageContinuously()
            currentAudioIndex = 0
            isPaused = false
            self.playBtn.setImage(R.image.ic_pause(), for: .normal)
            
            self.play(url: URL(string:(musicArray[self.currentAudioIndex].audioString as! String))!)
            self.setupNowPlaying(title: musicArray[self.currentAudioIndex].title ?? "", image: self.thumbnailImage.image ?? UIImage())
        }
    }
    
    func currentTrack(){
        
        if(currentAudioIndex < musicArray.count-1){

            isPaused = false
            
            self.playBtn.setImage(R.image.ic_pause(), for: .normal)
            self.play(url: URL(string:(musicArray[self.currentAudioIndex].audioString!))!)
            self.nameLabel.text = self.musicArray[currentAudioIndex].name ?? ""
            self.titleLabel.text = self.musicArray[currentAudioIndex].title?.htmlAttributedString ?? ""
            
            self.timeLabel.text = self.musicArray[currentAudioIndex].time ?? ""
            self.musicTypeLabel.text = (self.musicArray[currentAudioIndex].musicType ?? "") + " Music"
            let thumbnailURL = URL.init(string:self.musicArray[currentAudioIndex].ThumbnailImageString ?? "")
            thumbnailImage.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
            popupItem.image = thumbnailImage.image
            popupItem.title = self.musicArray[currentAudioIndex].name ?? ""
            popupItem.subtitle = self.musicArray[currentAudioIndex].title?.htmlAttributedString ?? ""
           // backGroundImage.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
            if (self.musicArray[currentAudioIndex].isLiked ?? false) {
                likeBtn.setImage(R.image.icHeartOrangeBs(), for: .normal)
            }else{
                likeBtn.setImage(R.image.icHeartBs(), for: .normal)
            }
            
            if (self.musicArray[currentAudioIndex].isFavorite!) {
                favoriteBtn.setImage(R.image.ic_starYellow(), for: .normal)
                
            }else{
                favoriteBtn.setImage(R.image.ic_starPlayer(), for: .normal)
            }
            
           // self.rotateThumbnailImageContinuously()
            
        }else{
            self.playBtn.cornerRadiusV = self.playBtn.frame.height / 2
            self.nameLabel.text = self.musicArray[currentAudioIndex].name ?? ""
            self.titleLabel.text = self.musicArray[currentAudioIndex].title?.htmlAttributedString ?? ""
            
            self.timeLabel.text = self.musicArray[currentAudioIndex].time ?? ""
            self.musicTypeLabel.text = (self.musicArray[currentAudioIndex].musicType ?? "") + " Music"
            let thumbnailURL = URL.init(string:self.musicArray[currentAudioIndex].ThumbnailImageString ?? "")
            thumbnailImage.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
            popupItem.image = thumbnailImage.image
            popupItem.title = self.musicArray[currentAudioIndex].name ?? ""
            popupItem.subtitle = self.musicArray[currentAudioIndex].title?.htmlAttributedString ?? ""
          //  backGroundImage.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
            if (self.musicArray[currentAudioIndex].isLiked ?? false) {
                likeBtn.setImage(R.image.icHeartOrangeBs(), for: .normal)
            }else{
                likeBtn.setImage(R.image.icHeartBs(), for: .normal)
            }
            
            if (self.musicArray[currentAudioIndex].isFavorite!) {
                favoriteBtn.setImage(R.image.ic_starYellow(), for: .normal)
                
            }else{
                favoriteBtn.setImage(R.image.ic_starPlayer(), for: .normal)
            }
            
            //self.rotateThumbnailImageContinuously()
            currentAudioIndex = 0
            isPaused = false
            self.playBtn.setImage(R.image.ic_pause(), for: .normal)
            
            self.play(url: URL(string:(musicArray[self.currentAudioIndex].audioString as! String))!)
            self.setupNowPlaying(title: musicArray[self.currentAudioIndex].title ?? "", image: self.thumbnailImage.image ?? UIImage())
        }
    }
    
    func prevTrack(){
        if(currentAudioIndex > 0){
            currentAudioIndex = currentAudioIndex - 1
            isPaused = false
            self.playBtn.cornerRadiusV = self.playBtn.frame.height / 2
            self.nameLabel.text = self.musicArray[currentAudioIndex].name ?? ""
            self.titleLabel.text = self.musicArray[currentAudioIndex].title?.htmlAttributedString ?? ""
            
            self.timeLabel.text = self.musicArray[currentAudioIndex].time ?? ""
            self.musicTypeLabel.text = (self.musicArray[currentAudioIndex].musicType ?? "") + " Music"
            let thumbnailURL = URL.init(string:self.musicArray[currentAudioIndex].ThumbnailImageString ?? "")
            thumbnailImage.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
            //backGroundImage.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
            if (self.musicArray[currentAudioIndex].isLiked ?? false) {
                likeBtn.setImage(R.image.icHeartOrangeBs(), for: .normal)
            }else{
                likeBtn.setImage(R.image.icHeartBs(), for: .normal)
            }
            
            if (self.musicArray[currentAudioIndex].isFavorite!) {
                favoriteBtn.setImage(R.image.ic_starYellow(), for: .normal)
                
            }else{
                favoriteBtn.setImage(R.image.ic_starPlayer(), for: .normal)
            }
            
           // self.rotateThumbnailImageContinuously()
            self.playBtn.setImage(R.image.ic_pause(), for: .normal)
            self.play(url: URL(string:(musicArray[self.currentAudioIndex].audioString as! String))!)
            self.setupNowPlaying(title: musicArray[self.currentAudioIndex].title ?? "", image: self.thumbnailImage.image ?? UIImage())
        }
    }
    
    func formatTimeFromSeconds(totalSeconds: Int32) -> String {
        let seconds: Int32 = totalSeconds%60
        let minutes: Int32 = (totalSeconds/60)%60
        let hours: Int32 = totalSeconds/3600
        return String(format: "%02d:%02d", minutes,seconds)
    }
    func assingSliderUI () {
        let minImage = R.image.sliderTrackFill()!.withRenderingMode(.alwaysTemplate)
        let maxImage = R.image.sliderTrack()!.withRenderingMode(.alwaysTemplate)
        let thumb = R.image.thumb()!.withRenderingMode(.alwaysTemplate)
        
        progressSlider.minimumTrackTintColor = .red
        progressSlider.thumbTintColor = .red
        progressSlider.setMinimumTrackImage(minImage, for: UIControl.State())
        progressSlider.setMaximumTrackImage(maxImage, for: UIControl.State())
        progressSlider.setThumbImage(thumb, for: UIControl.State())
        
        
    }
    private func checkOfflineDownload(){
        
        let audioUrl = URL(string: self.musicArray[currentAudioIndex].audioString ?? "")
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent(audioUrl!.lastPathComponent) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                print("FILE AVAILABLE")
                
                self.downloadBtn.isEnabled = false
               // self.progressCircularView.isHidden = true
                self.downloadBtn.setImage(R.image.ic_circularTick(), for: .normal)
                let fileManager = FileManager.default
                
                let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
                
                if let documentDirectoryURL: NSURL = urls.first as? NSURL {
                    let playYoda = documentDirectoryURL.appendingPathComponent(audioUrl!.lastPathComponent)
                    print("playYoda is \(playYoda)")
                    self.urlString = playYoda!
                    AppInstance.instance.playSongBool = true
                    
                }
            } else {
                self.downloadBtn.isEnabled = true
                //self.progressCircularView.isHidden = true
                self.downloadBtn.setImage(R.image.ic_cloudPlayer(), for: .normal)
                self.urlString = URL(string: musicArray[currentAudioIndex].audioString ?? "")
                AppInstance.instance.playSongBool = false
                
                
                print("FILE NOT AVAILABLE")
            }
        } else {
            print("FILE PATH NOT AVAILABLE")
        }
    }
    private func rotateThumbnailImageContinuously(){
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = 2 * M_PI
        rotation.duration = 2.5
        rotation.repeatCount = Float.infinity
        circularView.layer.add(rotation, forKey: "Spin")
    }
    
    @IBAction func fastForawardPressed(_ sender: Any) {
        
        guard let duration  = AppInstance.instance.player?.currentItem?.duration else {
            return
        }
        let playerCurrentTime = CMTimeGetSeconds((AppInstance.instance.player?.currentTime())!)
        let newTime = playerCurrentTime + 10.0000
        
        if newTime < (CMTimeGetSeconds(duration) - 10.0000) {
            
            let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
            AppInstance.instance.player?.seek(to: time2, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            
        }
        
    }
    
    @IBAction func fastBackwardPressed(_ sender: Any) {
        let playerCurrentTime = CMTimeGetSeconds((AppInstance.instance.player?.currentTime())!)
        var newTime = playerCurrentTime - 10.0000
        
        if newTime < 0 {
            newTime = 0
        }
        let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
        AppInstance.instance.player?.seek(to: time2, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        
        
        
        
    }
    @IBAction func showInfoPressed(_ sender: Any) {
        AppInstance.instance.player?.pause()
        let vc = R.storyboard.player.playerShowInfoVC()
        vc?.musicObject = self.musicArray[currentAudioIndex]
        self.present(vc!, animated: true, completion: nil)
    }
    
    @IBAction func addToPlayListPressed(_ sender: Any) {
        if  AppInstance.instance.getUserSession(){
            let vc = R.storyboard.popups.selectAPlaylistVC()
            vc?.createPlaylistDelegate = self
            vc?.trackId = self.musicArray[currentAudioIndex].trackId ?? 0
            self.present(vc!, animated: true, completion: nil)
        }else{
            AppInstance.instance.player?.pause()
            
            self.loginAlert()
            
        }
        
        
    }
    @IBAction func sharedPressed(_ sender: Any) {
        if  AppInstance.instance.getUserSession(){
            self.shareSong(stringURL: musicObject?.audioString ?? "")
        }else{
            AppInstance.instance.player?.pause()
            
            self.loginAlert()
            
        }
        
    }
    
    
    @IBAction func commentPressed(_ sender: Any) {
        
        if  AppInstance.instance.getUserSession(){
            let vc = R.storyboard.comment.commentsVC()
            vc?.trackId = self.musicArray[currentAudioIndex].trackId ?? 0
            vc?.trackIdString = self.musicArray[currentAudioIndex].audioID ?? ""
            self.present(vc!, animated: true, completion: nil)
            
        }else{
            AppInstance.instance.player?.pause()
            
            self.loginAlert()
            
        }
    }
    
    @IBAction func offlinePressed(_ sender: Any) {
        
        
        if  AppInstance.instance.getUserSession(){
            self.downloadBtn.isEnabled = true
            //self.progressCircularView.isHidden = false
            
            let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
            
            AF.download(
                self.musicArray[currentAudioIndex].audioString ?? "",
                method: .get,
                parameters: [:],
                encoding: JSONEncoding.default,
                headers: nil,
                to: destination).downloadProgress(closure: { (progress) in
                    log.verbose("progress = \(progress)")
                    //self.progressCircularView.progress = progress.fractionCompleted
                }).response(completionHandler: { (DefaultDownloadResponse) in
//                    log.verbose("DefaultDownloadResponse = \(DefaultDownloadResponse.description!)")
                    self.downloadBtn.isEnabled = false
                    //self.progressCircularView.isHidden = true
                    self.downloadBtn.setImage(R.image.ic_circularTick(), for: .normal)
                    self.setDownloadSongs()
                })
            
        }else{
            AppInstance.instance.player?.pause()
            self.loginAlert()
            
        }
    }
    
    @IBAction func sliderValueChange(_ sender: UISlider) {
        if self.progressSlider.isTouchInside {
            AppInstance.instance.player?.pause()
            let seconds : Int64 = Int64(progressSlider.value)
            let preferredTimeScale : Int32 = 1
            let seekTime : CMTime = CMTimeMake(value: seconds, timescale: preferredTimeScale)
            AppInstance.instance.player?.currentItem!.seek(to: seekTime)
            AppInstance.instance.player?.play()
            
        } else {
            
            let duration : CMTime = ( AppInstance.instance.player?.currentItem!.asset.duration)!
            let seconds : Float64 = CMTimeGetSeconds(duration)
            self.progressSlider.value = Float(seconds)
        }
    }
    
    @IBAction func sliderTapped(_ sender: UILongPressGestureRecognizer) {
        if let slider = sender.view as? UISlider {
            if slider.isHighlighted { return }
            let point = sender.location(in: slider)
            let percentage = Float(point.x / slider.bounds.width)
            let delta = percentage * (slider.maximumValue - slider.minimumValue)
            let value = slider.minimumValue + delta
            slider.setValue(value, animated: false)
            let seconds : Int64 = Int64(value)
            let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
            AppInstance.instance.player?.seek(to: targetTime)
            if(isPaused == false){
            }
        }
    }
    
    @IBAction func repeatPressed(_ sender: UIButton) {
        if sender.isSelected == true {
            sender.isSelected = false
            repeatState = false
            
        } else {
            sender.isSelected = true
            repeatState = true
        }
    }
    
    @IBAction func shufflePressed(_ sender: UIButton) {
        shuffleArray.removeAll()
        let shuffledArray = self.musicArray.shuffled()
        self.musicArray.removeAll()
        self.musicArray = shuffledArray
        
    }
    @IBAction func nextPressed(_ sender: AnyObject) {
        self.nextTrack()
    }
    
    @IBAction func previousPressed(_ sender: AnyObject) {
        self.prevTrack()
    }
    @IBAction func favoritePressed(_ sender: Any) {
        if  AppInstance.instance.getUserSession(){
            
            let audioId = self.musicObject?.audioID ?? ""
            self.favoriteUnFavoriteSong(audioId: audioId)
            
        }else{
            AppInstance.instance.player?.pause()
            
            self.loginAlert()
            
        }
        
    }
    
    @IBAction func likedPressed(_ sender: Any) {
        if  AppInstance.instance.getUserSession(){
            let audioId = self.musicObject?.audioID ?? ""
            self.likeDislikeSong(audioId:audioId)
            
        }else{
            AppInstance.instance.player?.pause()
            
            self.loginAlert()
            
        }
        
    }
    private func shareSong(stringURL:String){
        let someText:String = stringURL
        let objectsToShare:URL = URL(string: stringURL)!
        let sharedObjects:[AnyObject] = [objectsToShare as AnyObject,someText as AnyObject]
        let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook,UIActivity.ActivityType.postToTwitter,UIActivity.ActivityType.mail,UIActivity.ActivityType.postToTencentWeibo]
        self.setSharedSongs()
        self.present(activityViewController, animated: true, completion: nil)
    }
    private func setSharedSongs(){
        log.verbose("Check = \(UserDefaults.standard.getSharedSongs(Key: Local.SHARE_SONG.Share_Song))")
        
        let objectToEncode = self.musicArray[currentAudioIndex]
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
    
    private func setDownloadSongs(){
        log.verbose("Check = \(UserDefaults.standard.getDownloadSongs(Key: Local.SHARE_SONG.Share_Song))")
        let objectToEncode = self.musicArray[currentAudioIndex]
        let data = try? PropertyListEncoder().encode(objectToEncode)
        var getDownloadSongsrData = UserDefaults.standard.getDownloadSongs(Key: Local.DOWNLOAD_SONG.Download_Song)
        if UserDefaults.standard.getDownloadSongs(Key: Local.DOWNLOAD_SONG.Download_Song).contains(data!){
            self.view.makeToast("Already added in recently downloaded songs.")
        }else{
            getDownloadSongsrData.append(data!)
            UserDefaults.standard.setDownloadSongs(value: getDownloadSongsrData, ForKey: Local.DOWNLOAD_SONG.Download_Song)
            self.view.makeToast("Added to recently downloaded songs")
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
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.mode ?? "")")
                                if success?.mode == "disliked"{
                                    self.likeBtn.setImage(R.image.icHeartOrangeBs(), for: .normal)
                                }else{
                                    self.likeBtn.setImage(R.image.icHeartBs(), for: .normal)
                                }
                            }
                        })
                        
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.error ?? "")")
                                self.view.makeToast(sessionError?.error ?? "")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.view.makeToast(error?.localizedDescription ?? "")
                            }
                        })
                    }
                })
            })
        }else{
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
        
    }
    private func likeDislikeTrack(audioId:String){
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            let audioId = audioId ?? ""
            Async.background({
                likeManager.instance.likeDisLikeTrack(audiotId: audioId, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.mode ?? "")")
                                if success?.mode == "disliked"{
                                    self.dislikeBtn.setImage(UIImage(named: "ic-dislike-heart-fill"), for: .normal)
                                }else{
                                    self.dislikeBtn.setImage(UIImage(named: "ic-dislike-heart-border"), for: .normal)
                                }
                            }
                        })
                        
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.error ?? "")")
                                self.view.makeToast(sessionError?.error ?? "")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.view.makeToast(error?.localizedDescription ?? "")
                            }
                        })
                    }
                })
            })
        }else{
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
        
    }
    private func favoriteUnFavoriteSong(audioId:String){
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            let audioId = audioId ?? ""
            Async.background({
                FavoriteManager.instance.favoriteSong(audiotId: audioId, AccessToken: accessToken
                    , completionBlock: { (success, sessionError, error) in
                        if success != nil{
                            Async.main({
                                self.dismissProgressDialog {
                                    log.debug("success = \(success?.mode ?? "")")
                                    if success?.mode == "Remove from favorite"{
                                        self.favoriteBtn.setImage(R.image.ic_starPlayer(), for: .normal)
                                    }else{
                                        self.favoriteBtn.setImage(R.image.ic_starYellow(), for: .normal)
                                    }
                                }
                            })
                            
                        }else if sessionError != nil{
                            Async.main({
                                self.dismissProgressDialog {
                                    log.error("sessionError = \(sessionError?.error ?? "")")
                                    self.view.makeToast(sessionError?.error ?? "")
                                }
                            })
                        }else {
                            Async.main({
                                self.dismissProgressDialog {
                                    log.error("error = \(error?.localizedDescription ?? "")")
                                    self.view.makeToast(error?.localizedDescription ?? "")
                                }
                            })
                        }
                })
            })
        }else{
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    private func purchaseSong(trackId:Int){
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userid = AppInstance.instance.userId ?? 0
            Async.background({
                PurchaseTrackManager.instance.purchaseTrack(AccessToken: accessToken, userId: userid, TrackId: trackId, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.message ?? "")")
                                
                                
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                self.view.makeToast(sessionError?.error ?? "")
                                log.error("sessionError = \(sessionError?.error ?? "")")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(error?.localizedDescription ?? "")
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        })
                    }
                })
            })
            
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    private func purchaseSongWallet(trackId:String){
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userid = AppInstance.instance.userId ?? 0
            Async.background({
                UpgradeMemberShipManager.instance.purchaseTrack(AccessToken: accessToken, type: "buy_song", TrackID: trackId) { success, sessionError, error in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("userList = \(success ?? "")")
                                self.view.makeToast(success ?? "")
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                self.view.makeToast(sessionError ?? "")
                                log.error("sessionError = \(sessionError ?? "")")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(error?.localizedDescription ?? "")
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        })
                    }
                }
            })
            
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
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
}
extension MusicPlayerVC:createPlaylistDelegate{
    func createPlaylist(status: Bool) {
        if status{
            let vc = R.storyboard.playlist.createPlaylistVC()
            self.present(vc!, animated: true, completion: nil)
        }
    }
}

extension MusicPlayerVC:AVAudioPlayerDelegate{
    
    // MARK:- AVAudioPlayer Delegate's Callback method
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
        if flag == true {
            
            if shuffleState == false && repeatState == false {
                // do nothing
                playBtn.setImage(R.image.ic_playPlayer(), for: UIControl.State())
                return
                
            } else if shuffleState == false && repeatState == true {
                //repeat same song
                //                setupUI()
                //                playAudio()
                
            } else if shuffleState == true && repeatState == false {
                //shuffle songs but do not repeat at the end
                //Shuffle Logic : Create an array and put current song into the array then when next song come randomly choose song from available song and check against the array it is in the array try until you find one if the array and number of songs are same then stop playing as all songs are already played.
                shuffleArray.append(currentAudioIndex)
                if shuffleArray.count >= musicArray.count {
                    playBtn.setImage(R.image.ic_playPlayer(), for: UIControl.State())
                    return
                    
                }
                
                var randomIndex = 0
                var newIndex = false
                while newIndex == false {
                    randomIndex =  Int(arc4random_uniform(UInt32(musicArray.count)))
                    if shuffleArray.contains(randomIndex) {
                        newIndex = false
                    }else{
                        newIndex = true
                    }
                }
                currentAudioIndex = randomIndex
                setup()
                //                playAudio()
                
            } else if shuffleState == true && repeatState == true {
                //shuffle song endlessly
                shuffleArray.append(currentAudioIndex)
                if shuffleArray.count >= musicArray.count {
                    shuffleArray.removeAll()
                }
                
                var randomIndex = 0
                var newIndex = false
                while newIndex == false {
                    randomIndex =  Int(arc4random_uniform(UInt32(musicArray.count)))
                    if shuffleArray.contains(randomIndex) {
                        newIndex = false
                    }else{
                        newIndex = true
                    }
                }
                currentAudioIndex = randomIndex
                //                stopAudiplayer()
                setup()
                //                playAudio()
            }
        }
    }
    func showMediaInfo(){
        let artistName = self.musicObject?.name ?? ""
        let songName = self.musicObject?.title ?? ""
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyArtist : artistName,  MPMediaItemPropertyTitle : songName]
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        if event!.type == UIEvent.EventType.remoteControl{
            switch event!.subtype{
            case UIEvent.EventSubtype.remoteControlPlay:
                playPressed(self)
            case UIEvent.EventSubtype.remoteControlPause:
                playPressed(self)
            case UIEvent.EventSubtype.remoteControlNextTrack:
                nextPressed(self)
            case UIEvent.EventSubtype.remoteControlPreviousTrack:
                previousPressed(self)
            default:
                print("There is an issue with the control")
            }
        }
    }
    
    
}
//extension MusicPlayerVC:PayPalPaymentDelegate{
//    // PayPalPaymentDelegate
//    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
//        print("PayPal Payment Cancelled")
//        paymentViewController.dismiss(animated: true, completion: nil)
//    }
//    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
//        print("PayPal Payment Success !")
//        purchaseSong(trackId: self.musicArray[self.currentAudioIndex].trackId ?? 0)
//        paymentViewController.dismiss(animated: true, completion: { () -> Void in
//            
//            print("Here is your proof of payment:nn(completedPayment.confirmation)nnSend this to your server for confirmation and fulfillment.")
//        })
//    }
//}

extension AVPlayer {
    func duration() -> Double {
        guard let currentItem = currentItem else { return 0.0 }
        return CMTimeGetSeconds(currentItem.duration)
    }
}
