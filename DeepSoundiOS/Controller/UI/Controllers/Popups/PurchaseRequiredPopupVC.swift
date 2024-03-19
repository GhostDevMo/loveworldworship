//
//  PurchaseRequiredPopupVC.swift
//  DeepSoundiOS
//
//  Created by iMac on 28/06/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
import SwiftEventBus

class PurchaseRequiredPopupVC: UIViewController {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var puchaseButton: UIButton!
    
    var delegate: PurchaseRequiredPopupDelegate?
    var object: Song?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
   
    @IBAction func cancelPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func purchasePressed(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true) {
            if let object = self.object {
                self.delegate?.purchaseButtonPressed(sender, object)
            }
        }
    }
}
