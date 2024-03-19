//
//  ReportCommentPopupVC.swift
//  DeepSoundiOS
//
//  Created by iMac on 17/08/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit

protocol ReportCommentPopupDelegate {
    func dismissView(_ success: Bool, reportSTR: String)
}

class ReportCommentPopupVC: UIViewController {
    
    @IBOutlet weak var cmtTextView: UITextView!
    
    var delegate: ReportCommentPopupDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true) {
            self.delegate?.dismissView(false, reportSTR: "")
        }
    }
    
    @IBAction func submitBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if cmtTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            self.view.makeToast("Please describe your request.")
            return
        }
        self.dismiss(animated: true) {
            self.delegate?.dismissView(true, reportSTR: self.cmtTextView.text ?? "")
        }
    }
}
