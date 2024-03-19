//
//  SettingsWebViewVC.swift
//  DeepSoundiOS
//
//  Created by iMac on 03/07/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import WebKit
import DeepSoundSDK

class SettingsWebViewVC: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var webView: WKWebView!
    
    // MARK: - Properties
    
    var headerText = ""
    
    // MARK: - View Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.initialConfig()
    }
    
    // MARK: - Selectors
    
    // Back Button Action
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.headerLabel.text = self.headerText
        self.setUpWebView()
    }
    
    // Setup WebView
    func setUpWebView() {
        var urlString = ""
        switch self.headerText {
        case "Terms of use":
            urlString = ControlSettings.termsOfUse
        case "Help":
            urlString = ControlSettings.HelpLink
        default:
            break
        }
        if let url = URL(string: urlString) {
            let urlRequest = URLRequest(url: url)
            self.webView.load(urlRequest)
        }
    }

}
