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
import MediaPlayer
import Async
class AddMenuBottomSheetController: BaseVC, PanModalPresentable{
    
    
    private let popupContentController = R.storyboard.player.musicPlayerVC()
    var notloggedInVC:NotLoggedInHomeVC?
    var loggedInVC:Dashboard1VC?
    
    var panScrollable: UIScrollView?
    var isShortFormEnabled = true
    var shortFormHeight: PanModalHeight {
        return isShortFormEnabled ? .contentHeight(self.view.bounds.height/2) : longFormHeight
    }


    override func viewDidLoad() {
        super.viewDidLoad()
    
      
        SwiftEventBus.onMainThread(self, name:   EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER) { result in
            AppInstance.instance.player = nil
            if self.notloggedInVC != nil{
                self.notloggedInVC?.tabBarController?.dismissPopupBar(animated: true, completion: nil)
            }else if self.loggedInVC != nil{
                self.loggedInVC?.tabBarController?.dismissPopupBar(animated: true, completion: nil)
            }
        }
    }
    init(song: String) {
 

        super.init(nibName: AddMenuBottomSheetController.name, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    @IBAction func didTapUploadsinglesonge(_ sender: UIButton) {
        
        let mediaPicker = MPMediaPickerController(mediaTypes: .music)
        mediaPicker.delegate = self
        mediaPicker.allowsPickingMultipleItems = false
        self.present(mediaPicker, animated: true, completion: nil)
        print("uploadAlbumVC button")
      
    }
    
    @IBAction func didTapImportSong(_ sender: Any) {
        
        let vc = R.storyboard.track.importURLVC()
        self.present(vc!, animated: true, completion: nil)
       
        
    }
    @IBAction func didTapCreateAlbum(_ sender: Any) {
        
        let vc = R.storyboard.album.uploadAlbumVC()
        self.present(vc!, animated: true, completion: nil)
        

    }
    @IBAction func didTapCreatePlaylist(_ sender: Any) {
        
        let vc = R.storyboard.playlist.createPlaylistVC()
        self.present(vc!, animated: true, completion: nil)
        
    }
    @IBAction func didTapCreateStation(_ sender: Any) {
        
        let vc = R.storyboard.stations.stationsFullVC()
        self.present(vc!, animated: true, completion: nil)
        
       
    }
    @IBAction func didTapCreateAdvertise(_ sender: Any) {
        
        let vc = R.storyboard.events.createEventVC()
        self.present(vc!, animated: true, completion: nil)
        
    }
 
    
}
extension AddMenuBottomSheetController:MPMediaPickerControllerDelegate{
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
        guard let mediaItem = mediaItemCollection.items.first else{
            NSLog("No item selected.")
            return
        }
        let songUrl = mediaItem.value(forProperty: MPMediaItemPropertyAssetURL) as! URL
        print(songUrl)
        // get file extension andmime type
        let str = songUrl.absoluteString
        let str2 = str.replacingOccurrences( of : "ipod-library://item/item", with: "")
        let arr = str2.components(separatedBy: "?")
        var mimeType = arr[0]
        mimeType = mimeType.replacingOccurrences( of : ".", with: "")
        
        let exportSession = AVAssetExportSession(asset: AVAsset(url: songUrl), presetName: AVAssetExportPresetAppleM4A)
        exportSession?.shouldOptimizeForNetworkUse = true
        exportSession?.outputFileType = AVFileType.m4a
        
        //save it into your local directory
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let outputURL = documentURL.appendingPathComponent(mediaItem.title!)
        print(outputURL.absoluteString)
        do
        {
            try FileManager.default.removeItem(at: outputURL)
        }
        catch let error as NSError
        {
            print(error.debugDescription)
        }
        exportSession?.outputURL = outputURL
        Async.background({
            exportSession?.exportAsynchronously(completionHandler: { () -> Void in
                
                if exportSession!.status == AVAssetExportSession.Status.completed
                {
                    print("Export Successfull")
                    let data = try! Data(contentsOf: outputURL)
                    log.verbose("Data = \(data)")
                  Async.main({
                    self.uploadTrack(TrackData: data)
                  })
                }
            })
        })
        
        self.dismiss(animated: true, completion: nil)
    }
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        self.dismiss(animated: true, completion: nil)
        print("User selected Cancel tell me what to do")
    }
    
    private func uploadTrack(TrackData:Data){
        self.showProgressDialog(text: "Loading...")
        let accessToken = AppInstance.instance.accessToken ?? ""
        if Connectivity.isConnectedToNetwork(){
            Async.background({
                TrackManager.instance.uploadTrack(AccesToken: accessToken, audoFile_data: TrackData, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.filePath ?? "")")
                                let vc = R.storyboard.track.uploadTrackVC()
                                self.navigationController?.pushViewController(vc!, animated: true)
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
}
