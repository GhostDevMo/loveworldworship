//
//  WebViewVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 11/01/2022.
//  Copyright © 2022 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import WebKit
class WebViewVC: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    var webLink:String? = ""
    
    var delegate:didReceivePaystackReferenceIDDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: webLink ?? "")
        webView.navigationDelegate = self
        webView.load(URLRequest(url: url!))
    }
}
extension WebViewVC:WKNavigationDelegate{
 
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let urlStr = navigationAction.request.url?.absoluteString{
            log.verbose("URL String = \(urlStr)")
            
            if urlStr.contains(find: "reference"){
                let reference = urlStr.components(separatedBy: "reference=")
                log.verbose("reference = \(reference)")
                self.delegate?.didReceivePaystackReferenceID(refID: reference[1])
                self.navigationController?.popViewController(animated: true)
            }
        }
        decisionHandler(.allow)
    }
}
