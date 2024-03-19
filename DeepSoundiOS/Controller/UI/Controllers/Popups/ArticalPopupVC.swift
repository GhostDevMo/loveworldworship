//
//  ArticalPopupVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 02/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
import SwiftEventBus

protocol ArticalPopupDelegate {
    func reportBtnAction(_ sender: UIButton)
    func copyBtnAction(_ sender: UIButton, isLink: Bool)
    func shareBtnAction(_ sender: UIButton)
    func deleteBtnAction(_ sender: UIButton)
}

class ArticalPopupVC: BaseVC {
    
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnReport: UIButton!
    @IBOutlet weak var commentStackView: UIStackView!
    @IBOutlet weak var mainStackView: UIStackView!
        
    var isComment = false
    var isDelete = false
    var isReported = false
    var delegate: ArticalPopupDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black.withAlphaComponent(0.4)
        commentStackView.isHidden = !self.isComment
        mainStackView.isHidden = self.isComment
        let title = self.isReported ? "Unreport" : "Report"
        self.btnReport.setTitle(title, for: .normal)
        if isComment {
            self.btnDelete.isHidden = !self.isDelete
        }
        
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER) { result in
            log.verbose("To dismiss the popover")
            self.tabBarController?.dismissPopupBar(animated: true, completion: nil)
        }
        SwiftEventBus.onMainThread(self, name: "PlayerReload") { result in
            let stringValue = result?.object as? String
            self.view.makeToast(stringValue)
            log.verbose(stringValue ?? "")
        }
    }
    
    @IBAction func copyLinkPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true) {
            self.delegate?.copyBtnAction(sender, isLink: true)
        }
    }
    
    @IBAction func reportBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true) {
            self.delegate?.reportBtnAction(sender)
        }
    }
    @IBAction func copyBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true) {
            self.delegate?.copyBtnAction(sender, isLink: false)
        }
    }
    @IBAction func shareBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true) {
            self.delegate?.shareBtnAction(sender)
        }
    }
    @IBAction func deleteBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true) {
            self.delegate?.deleteBtnAction(sender)
        }
    }
}
