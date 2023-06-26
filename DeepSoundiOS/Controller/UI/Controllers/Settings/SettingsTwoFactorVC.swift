//
//  SettingsTwoFactorVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/9/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async

protocol TwoFactorAuthDelegate {
    func getTwoFactorUpdateString(type:String)
}

class SettingsTwoFactorVC: BaseVC {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var selectBtn: UIButton!
    //    var bannerView: GADBannerView!
    
    
    var typeString:String? = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    private func setupUI(){
        self.titleLabel.text = NSLocalizedString("Turn on 2-step login to level-up your account security. Once turned on, you'll use both your password and a 6-digit security code send to your  phone or email to log in.", comment: "Turn on 2-step login to level-up your account security. Once turned on, you'll use both your password and a 6-digit security code send to your  phone or email to log in.")
        
        self.saveButton.backgroundColor = .ButtonColor
        self.saveButton.setTitle((NSLocalizedString("SAVE", comment: "")), for: .normal)
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationItem.title = (NSLocalizedString("Two Factor Authentication", comment: ""))
        
        //        self.typeString = self.selectBtn.titleLabel?.text ?? ""
        //        if AppInstance.instance.userProfile?.twoFactor == "0"{
        //            self.selectBtn.setTitle("Disable", for: .normal)
        //        }else{
        //            self.selectBtn.setTitle("Enable", for: .normal)
        //        }
        
    }
    
    
    @IBAction func selectBtnPressed(_ sender: Any) {
        let vc = R.storyboard.popups.twoFactorUpdatePopupVC()
        vc!.delegate = self
        self.present(vc!, animated: true, completion: nil)
        
        
    }
    @IBAction func savePressed(_ sender: Any) {
        self.updateTwoFactorSendCode()
//        if typeString == "enable"{
//            self.updateTwoFactorSendCode()
//        }else{
//        }
    }
   
    private func updateTwoFactorSendCode(){
//        self.showProgressDialog(text: "Loading")
        let accessToken = AppInstance.instance.accessToken ?? ""
        let type = self.typeString ?? ""
        let userId = AppInstance.instance.userId ?? 0
        Async.background({
            TwoFactorManager.instance.updateTwoFactor(AccessToken: accessToken, userId: userId, twoFactor: type, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            if success?.data == (NSLocalizedString("Settings successfully updated!", comment: "")){
                                self.view.makeToast(success?.data ?? "")
                            }else{ let vc = R.storyboard.popups.confirmCodeVC()
                                self.present(vc!, animated: true, completion: nil)
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
            })
        })
    }
}
extension SettingsTwoFactorVC:TwoFactorAuthDelegate{
    func getTwoFactorUpdateString(type: String) {
        if type == "enable"{
            self.selectBtn.setTitle((NSLocalizedString("Enable", comment: "")), for: .normal)
        }else{
            self.selectBtn.setTitle((NSLocalizedString("Disable", comment: "")), for: .normal)
        }
        self.typeString = type
    }
}
