//
//  UpgradeProVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 04/12/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import DeepSoundSDK
import Async
import PassKit
import StoreKit
import Toast_Swift

class UpgradeProVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var moneyLabel: UILabel!
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialConfig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Selectors
    // Back Button Action
    @IBAction override func backButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    // Upgrade Now Button Action
    @IBAction func upgradeNowButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if let newVC = R.storyboard.popups.goProPopupVC() {
            newVC.delegate = self
            self.present(newVC, animated: true)
        }
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        AppInstance.instance.fetchUserProfile(isNew: true) { _ in
            
        }
        self.moneyLabel.text = "$\(ControlSettings.upgradeProAmount)"
    }
    
    private func purchaseGOPro() {
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background {
                UpgradeMemberShipManager.instance.purchase(AccessToken: accessToken, type: "go_pro") { success, sessionError, error in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                self.upgradeMemberShip()
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast(sessionError ?? "")
                                log.error("sessionError = \(sessionError ?? "")")
                            }
                        }
                    } else {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast(error?.localizedDescription ?? "")
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        }
                    }
                }
            }
        } else {
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
    private func upgradeMemberShip() {
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
            let userId = AppInstance.instance.userId ?? 0
            Async.background {
                UpgradeMemberShipManager.instance.upgradeMemberShip(userId: userId, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.data ?? "")")
                                AppInstance.instance.fetchUserProfile(isNew: true) { _ in }
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast(sessionError?.error ?? "")
                                log.error("sessionError = \(sessionError?.error ?? "")")
                            }
                        }
                    } else {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast(error?.localizedDescription ?? "")
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        }
                    }
                })
            }
        } else {
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
}

// MARK: - Extensions

// MARK: GoProPopupVCDelegate Methods
extension UpgradeProVC: GoProPopupVCDelegate {
    
    func handleWalletTap(_ sender: UIButton) {
        if Double(AppInstance.instance.userProfile?.data?.wallet ?? "0.0") ?? 0 < ControlSettings.upgradeProAmount {
            self.view.makeToast("Sorry You cannot buy because there is not enough balance in the wallet")
        } else {
            self.purchaseGOPro()
        }
    }
    
}
