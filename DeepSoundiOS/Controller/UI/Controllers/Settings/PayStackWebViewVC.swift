//
//  PayStackWebViewVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 11/01/2022.
//  Copyright © 2022 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import WebKit

protocol PaystackWalletWebViewDelegate {
    func webView(_ isSuccess: Bool, referanceID: String)
}

class PayStackWebViewVC: BaseVC {
    
    @IBOutlet weak var webView: WKWebView!
    
    var webLink: String? = ""
    var paymentType = PaymentName.paysera
    var paystackDelegate: PaystackWalletWebViewDelegate?
    var delegate: DidReceivePaystackReferenceIDDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: webLink ?? "")
        webView.navigationDelegate = self
        webView.load(URLRequest(url: url!))
    }
    
}

extension PayStackWebViewVC: WKNavigationDelegate {
 
    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let urlStr = navigationAction.request.url?.absoluteString {
            log.verbose("URL String = \(urlStr)")
            if urlStr.contains(find: "reference") {
                let reference = self.getQueryStringParameter(url: urlStr, param: "reference")//urlStr.components(separatedBy: "reference=")
                log.verbose("reference = \(reference ?? "")")
                self.delegate?.didReceivePaystackReferenceID(refID: reference ?? "")
                self.navigationController?.popViewController(animated: true)
            }
            
            /*if urlStr.hasPrefix("https://demo.deepsoundscript.com/endpoints/paystack") {
                let reference = getQueryStringParameter(url: urlStr, param: "reference")
                if let reference = reference {
                    print("reference ID :--- \(reference)")
                    self.dismiss(animated: true) {
                        self.paystackDelegate?.webView(true, referanceID: reference)
                    }
                }
            }*/
        }
        decisionHandler(.allow)
    }
    
}
