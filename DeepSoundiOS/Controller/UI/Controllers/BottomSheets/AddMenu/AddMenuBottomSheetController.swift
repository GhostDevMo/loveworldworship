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

protocol AddMenuBottomSheetDelegate {
    func uploadSingleSongPressed(_ sender: UIButton)
    func importSongPressed(_ sender: UIButton)
    func createAlbumPressed(_ sender: UIButton)
    func createPlayListPressed(_ sender: UIButton)
    func createStationPressed(_ sender: UIButton)
    func createAdvertisePressed(_ sender: UIButton)
}

class AddMenuBottomSheetController: UIViewController, PanModalPresentable{
    
    var panScrollable: UIScrollView?
    var isShortFormEnabled = true
    var shortFormHeight: PanModalHeight {
        return .contentHeight(375.0)
    }
    var longFormHeight: PanModalHeight {
        return .contentHeight(375.0)
    }
    var delegate: AddMenuBottomSheetDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    init(delegate: AddMenuBottomSheetDelegate) {
        super.init(nibName: AddMenuBottomSheetController.name, bundle: nil)
        self.delegate = delegate
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func uploadSingleSongPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true) {
            self.delegate?.uploadSingleSongPressed(sender)
        }
    }
    
    @IBAction func importSongPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true) {
            self.delegate?.importSongPressed(sender)
        }
    }
    
    @IBAction func createAlbumPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true) {
            self.delegate?.createAlbumPressed(sender)
        }
    }
    
    @IBAction func createPlayListPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true) {
            self.delegate?.createPlayListPressed(sender)
        }
    }
    
    @IBAction func createStationPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true) {
            self.delegate?.createStationPressed(sender)
        }
    }
    
    @IBAction func createAdvertisePressed(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true) {
            self.delegate?.createAdvertisePressed(sender)
        }
    }
}
