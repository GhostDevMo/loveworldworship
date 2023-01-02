//
//  ConfirmCodeVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/9/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async

class ConfirmCodeVC: BaseVC {
    
    @IBOutlet weak var confirmBut: UIButton!
    @IBOutlet weak var cancelBut: UIButton!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var codeTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
      self.confirmBut.setTitle((NSLocalizedString("Confirm", comment: "")), for: .normal)
        self.cancelBut.setTitle((NSLocalizedString("CANCEL", comment: "")), for: .normal)
        self.topLabel.text = NSLocalizedString(" A confirmation email has been sent", comment: "")
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func sendPressed(_ sender: Any) {
        if self.codeTextField.text!.isEmpty{
            self.view.makeToast(NSLocalizedString(("Please enter code"), comment: ""))
        }else{
            self.verifyCode(code: self.codeTextField.text ?? "")
        }
    }
    private func verifyCode(code:String){
        self.showProgressDialog(text: (NSLocalizedString(("Loading"), comment: "")))
        let accessToken = AppInstance.instance.accessToken ?? ""
        let userId = AppInstance.instance.userId ?? 0
        Async.background({
            TwoFactorManager.instance.verifyTwoFactor(AccessToken: accessToken, userId: userId, code: code) { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(success?.data ?? "")
                            self.dismiss(animated: true) {
                                AppInstance.instance.fetchUserProfile()
                            }
                            
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
                            self.view.makeToast(error?.localizedDescription)
                            log.error("error = \(error?.localizedDescription)")
                        }
                    })
                }
            }
        })
    }
}
