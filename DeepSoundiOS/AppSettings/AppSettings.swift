//
//  AppSettings.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 26/06/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import UIKit
import DeepSoundSDK

struct AppConstant {
    
    //deepsound key
    /*
    static let key = "3GdpANVLcyeACVbPI/H9qlxUjBZSjTf8IN5oJ+3BZL64W4u/JLJb3DVEgPym2CZ0GN+vzDWwvNzLkyxcPznqDZe2xDs1gkDXZ9h8MEiQz+I5ssM7y36vOrjCPQkTqfHQTsrVQ/tq0whzb/sTNOVzSJ92QHh1n8airiaVDygTLpfcOtHhjfYEg2aEVbo07jy1SWomMEpgoqzUBh1LVucChVBtEopudbNlmUmmzlibDWNgj+aQKta6MGbxYev667MEC7Yjf4URiAXRSAUwBMtT/xvwPd21hiG+3UbP4Zzy1zx+FlXNJ3pr+QfSkKdLz9SPAfPjQxeryyt76upVy9iIGN7cyfpJVvjqStyBA9U1E1dh4dVDUPguiBvPOk0Ylh35YT2Wq4NWxE1YerR+VkUjKEDW0h6ThP4cy0Frrw6lcTYe6HJ/LhY+nbSOiCx70I266vOPvRcXPqqfhku1QuN0xSBpmcvi0tBlFP6jy7E3uv0Bv88ECDb/etqkag7JFwJt+hnmU5ORd7Am+6p9q8TOy4/oWApraKCDjm6fo5hYKhBik7PdNUe4ZkPigGWQ/zO7BCigRPqiQwwMe9tVFeKDvtAmM41wUis0/dgVObgc6/P2bmaCz0e1mmy9EO05c04y9mDshpeLjEKY8n1WQfVl7F5u1U8ksAk/iLpuH+I5hOwq626UYFZH2n7549xrJjOnQWATo8jXKcNKIviq9IdgT28w2Cu5qCL2+7mOl9Xx5PEg7lPElPq2QkABdC6wmvUGECVFnEwCokvlJccWXOBNycN1SdoyiDkfS6gqqkgRnO9SHCWgA8sZnovJpLdNxvtEwWpy4qQawgRpOeFaDcz1GlJJWk8RVwdYZ/a16yLYSzAQlcu74cDuCsMUj486Xjk0I3wY0kLg50CZyWyJMO0jBfarjh3Y7/7sWq+OPV1qOek/F+tc1gmbLJeMJKjGfO9eJFPMXzBw6Ts2wOjnqRoCaA=="
    */
    //Customer key
    static let key = "3GdpANVLcyeACVbPI/H9qlxUjBZSjTf8IN5oJ+3BZL7biNK29DeqBPUbBV34TuXQD1hU3oqekuBOrL1QHY/0E4cU5vtevgeIpK4eF/AQauJSeVEvOwTonUqrQ0zD0y6butoTKU81JRKWfFc9Lj34w7W7ItnLfgUx3zcp2YnlOSmE2/DDJOmRkgB0MGeckYRXli58TSKbfi/YxJkDZM9gaxOLksRDVQKDTfxDHu/G9//HGZrt8Itph8WJmRIf/fCS9pYVLdKM0AJQlOe6T4OKWRwTirwqKdEg4GoTZsNHFobrF79mDkKy0QYFQ0hkLlUQoSZRFE8D7ablfT1on8Q7y2rageDEE4k3mFZvdzUD38B3W/j67naYxSC74yR2Kd8/+7rcaKLkBvDhQcMtYay7AUPX8PRamAePqL2xRAIbl20TSO/EzW5JZQujuKoLOoBEXZ4ytq+doTYtouow2yNRCRmvey5yOaYY7LWhZnk8rTVksgzCiMhxKBHeUuNT5HLm1QGyQyn9NgP9cOdxgZPbm4X/dP5s4RG6HXU2GtTYed+00Jr3aeJR8CUpU/XO6XLn2ifBqGQMulx2ROPNNuqIgi+MJeJe2MYZ9SKCuPBjnEy/ENycFaQiE96Xne6MkWHiq3dXxoOuIw5hCpT7GMcJ03d1FIh5qkEOGnSLM1/ZL52Yqx8T0aQAfhvqXI1j4eZW/TWP0Umy8oQbPlwC+oaYaoFpQuA4rUx/WM+hydklu4eSfFCvklgFoiy+gYmVLGYsEaToJAZOEVFzZ7q5u6jDNXGLc9qwvKYb2ov4LkO1HltD1Eyb7VpXwwNVJ8MQy1u1FzqhWK80pho+pjSMlXPGgFJJWk8RVwdYZ/a16yLYSzAQlcu74cDuCsMUj486Xjk0XPs+sgCdUQTJRw0nWVs0TKghXMcOwO8U3wJLV1eJSaJ8F7WhsOXOSppNm/uGmv5tr0OsfuNvqL4VIB1VufpksA=="
    
}

struct ControlSettings {
    
    static let showSocicalLogin = false
    static let hideFacebookLogin = false
    static let hideGoogleLogin = false
    static let hideWoWonderLogin = false
    static let showHideDownloadBtn = false
    static let  appName = "DeepSound"
    static let googleClientKey = "497109148599-u0g40f3e5uh53286hdrpsj10v505tral.apps.googleusercontent.com"
    static let wowonder_ServerKey = "35bf23159ca898e246e5e84069f4deba1b81ee97-60b93b3942f269c7a29a1760199642ec-46595136"
    static let wowonder_URL = "https://demo.wowonder.com/"
    static let oneSignalAppId = "69bc0a81-71c3-409f-921d-01c01a44c278"
    static let isPurchase = true
    static let addUnitId = "ca-app-pub-3940256099942544/2934735716"
    static let  interestialAddUnitId = "ca-app-pub-3940256099942544/4411468910"
    static let paypalAuthorizationToken = "sandbox_zjzj7brd_fzpwr2q9pk2m568s"
    static let BrainTreeURLScheme = "com.DeepSound.ScripSun.App.payments"
    static let googleApiKey = "AIzaSyB9hBrJwdQM3oycf_j-53XKrG-hxW9rYt0"
    static let  HelpLink = "\(API.baseURL)/contact"
    static let  reportlink = "\(API.baseURL)/contact"
    static let  termsOfUse = "\(API.baseURL)/terms/terms"
    static let  privacyPolicy = "\(API.baseURL)/terms/privacy"
    static let  inviteFriendText = "Please vist our website \(API.baseURL)"
    //Only for extended customer you can't easily open it
    static let  applyPayMerchchat = "merchant.com.DeepSound.ScripSun.App"
    //Payments
    static let  razorPayInitialkey = "rzp_test_ruzI7R7AkonOIi"
    static let  securionPayPublicKey = "pk_test_WoOlrf6NeiNsQkq9UBDz9Fsn"
    static let  securionBundleID = "com.securionpay.sdk.SecurionPay.Examples"
    
    static var shouldShowAddMobBanner:Bool = true
    static var interestialCount:Int? = 3
    static var isApplePay: Bool = true
    static var isGoProEnabled:Bool = true
    static var IsPaypalEnabled:Bool = true
    static var isBankTransferEnabled:Bool = true
    static var IsCreditEnabled:Bool = true
    static var IsRazorPayEnabled:Bool = true
    static var IsPayStackEnabled:Bool = true
    static var IsCashFreeEnabled:Bool = true
    static var IsSecurionPayEnabled:Bool = true
    static var IsAuthorizeEnabled:Bool = true
    static var upgradeProAmount: Double = 12
    
}
extension UIColor {
    @nonobjc class var mainColor: UIColor {
        return UIColor.hexStringToUIColor(hex: "#FF9800")
        //        return UIColor.hexStringToUIColor(hex: "#FF0000")
    }
    @nonobjc class var ButtonColor: UIColor {
        return UIColor.hexStringToUIColor(hex: "#FF981F")
        //        return UIColor.hexStringToUIColor(hex: "#FF0000")
    }
    
    @nonobjc class var unselectedTextFieldTintColor: UIColor {
        return UIColor.hexStringToUIColor(hex: "#9E9E9E")
    }
    
    @nonobjc class var textColor: UIColor {
        return UIColor.hexStringToUIColor(hex: "#212121")
    }
    
    @nonobjc class var unselectedTextFieldBackGroundColor: UIColor {
        return UIColor.hexStringToUIColor(hex: "#FAFAFA")
    }
    
    @nonobjc class var selectedTextFieldBackGroundColor: UIColor {
        return UIColor.hexStringToUIColor(hex: "#FFF8ED")
    }
    
    
    @nonobjc class var lightButtonColor: UIColor {
        // return UIColor.hexStringToUIColor(hex: "#FF8216")
        return UIColor.ButtonColor.withAlphaComponent(0.25)
    }
    @nonobjc class var lightMainColor: UIColor {
        //        return UIColor.hexStringToUIColor(hex: "#FF8216")
        return UIColor.mainColor.withAlphaComponent(0.25)
    }
}
