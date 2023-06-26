//
//  MyAccountVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 19/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
import SwiftEventBus
class MyAccountVC: BaseVC {
    @IBOutlet weak var saveButt: UIButton!
    
    @IBOutlet weak var genderTitle: UILabel!
    @IBOutlet weak var female: UILabel!
    @IBOutlet weak var male: UILabel!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var femaleBtn: UIButton!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var maleBtn: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    private var gender :String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.maleBtn.tintColor = .ButtonColor
        self.femaleBtn.tintColor = .ButtonColor
        self.saveButt.backgroundColor = .ButtonColor
        self.setupUI()
        SwiftEventBus.onMainThread(self, name:   EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER) { result in
            log.verbose("To dismiss the popover")
            AppInstance.instance.player = nil
            self.tabBarController?.dismissPopupBar(animated: true, completion: nil)
        }
        SwiftEventBus.onMainThread(self, name:   "PlayerReload") { result in
            let stringValue = result?.object as? String
            self.view.makeToast(stringValue)
            log.verbose(stringValue)
        }
    }
    
    private func setupUI(){
        self.emailTextField.placeholder = (NSLocalizedString("Email", comment: ""))
        self.usernameTextField.placeholder = (NSLocalizedString("Username", comment: ""))
        self.ageTextField.placeholder = (NSLocalizedString("Choose your age", comment: ""))
        self.countryTextField.placeholder = (NSLocalizedString("Choose your country", comment: ""))
        self.genderTitle.text = (NSLocalizedString("Gender", comment: ""))
        self.male.text = (NSLocalizedString("Male", comment: ""))
        self.female.text = (NSLocalizedString("Female", comment: ""))
        self.saveButt.setTitle((NSLocalizedString("SAVE", comment: "")), for: .normal)
        self.title = (NSLocalizedString("My Account", comment: ""))
        let username = AppInstance.instance.userProfile?.data?.username ?? ""
        let email = AppInstance.instance.userProfile?.data?.email ?? ""
        let age = AppInstance.instance.userProfile?.data?.age ?? 0
        let country = AppInstance.instance.userProfile?.data?.countryName ?? ""
        let gender = AppInstance.instance.userProfile?.data?.gender ?? ""
        if age == 0{
             self.ageTextField.text = ""
        }else{
             self.ageTextField.text = "\(age)"
        }
        self.usernameTextField.text = username
        self.emailTextField.text = email
       
        self.countryTextField.text = country
        
        if gender == "male"{
            self.maleBtn.setImage(R.image.ic_check_radio(), for: .normal)
            self.femaleBtn.setImage(R.image.ic_uncheck_radio(), for: .normal)
        }else{
            self.femaleBtn.setImage(R.image.ic_check_radio(), for: .normal)
            self.maleBtn.setImage(R.image.ic_uncheck_radio(), for: .normal)
        }
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    @IBAction func malePressed(_ sender: Any) {
        self.maleBtn.setImage(R.image.ic_check_radio(), for: .normal)
        self.femaleBtn.setImage(R.image.ic_uncheck_radio(), for: .normal)
        self.gender = "male"
    }
    
    @IBAction func femalePressed(_ sender: Any) {
        self.femaleBtn.setImage(R.image.ic_check_radio(), for: .normal)
        self.maleBtn.setImage(R.image.ic_uncheck_radio(), for: .normal)
        self.gender = "female"
    }
    @IBAction func savePressed(_ sender: Any) {
        self.save()
    }
    
    private func save(){
        if Connectivity.isConnectedToNetwork(){
            
            self.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            let username = self.usernameTextField.text ?? ""
            let email = self.emailTextField.text ?? ""
            let age = Int(self.ageTextField.text ?? "")
            let country = self.countryTextField.text ?? ""
            let gender = self.gender ?? ""
            
            Async.background({
                ProfileManger.instance.updateMyAccount(UserId: userId, AccessToken: accessToken, Username: username, Email: email, Country: country, Gender: gender, Age: age ?? 0, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.message ?? "")")
                                self.view.makeToast(success?.message ?? "")
                                AppInstance.instance.fetchUserProfile()
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.error)")
                                self.view.makeToast(sessionError?.error ?? "")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription)")
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


