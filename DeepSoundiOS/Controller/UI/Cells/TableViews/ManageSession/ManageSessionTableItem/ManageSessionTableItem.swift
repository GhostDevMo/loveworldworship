//
//  ManageSessionTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/9/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async

class ManageSessionTableItem: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var alphaLabel: UILabel!
    @IBOutlet weak var lastSeenlabel: UILabel!
    @IBOutlet weak var browserLabel: UILabel!
    @IBOutlet weak var iPAddressLabel: UILabel!
    @IBOutlet weak var crossBtn: UIButton!
    @IBOutlet weak var bgVIew: UIView!
    
    var object : SessionModel.Datum?
    var singleCharacter :String?
    var indexPath:Int? = 0
    var vc: ManageSessionsVC?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bgVIew.backgroundColor = .mainColor
        self.crossBtn.backgroundColor = .ButtonColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func bind(_ object:SessionModel.Datum, index:Int){
        
        self.object = object
        self.indexPath = index
        self.nameLabel.text = "\(object.platform ?? "")"
        self.iPAddressLabel.text = "\(NSLocalizedString("IP Address", comment: "IP Address")) : \(object.ipAddress ?? "")"
        self.browserLabel.text = "\(NSLocalizedString("Browser", comment: "Browser")) : \(object.browser ?? "")"
        self.lastSeenlabel.text = "\(NSLocalizedString("Last seen", comment: "Last seen")) : \(object.time ?? "")"
        if object.browser == nil{
            self.alphaLabel.text = self.singleCharacter ?? ""
        }else{
            for (index, value) in (object.browser?.enumerated())!{
                if index == 0{
                    self.singleCharacter = String(value)
                    break
                }
            }
            self.alphaLabel.text = self.singleCharacter ?? ""
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.deleteSession()
        
    }
    private func deleteSession(){
        let id = self.object?.id ?? 0
        
        let accessToken = AppInstance.instance.accessToken ?? ""
        
        Async.background({
            SessionManager.instance.deleteSession(AccessToken: accessToken, id: id) { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        
                        self.vc?.sessionArray.remove(at: self.indexPath ?? 0)
                        self.vc?.tableView.reloadData()
                        
                        
                    })
                }else if sessionError != nil{
                    Async.main({
                        
                        self.vc!.view.makeToast(sessionError?.error ?? "")
                        log.error("sessionError = \(sessionError?.error ?? "")")
                        
                        
                    })
                }else {
                    Async.main({
                        
                        self.vc!.view.makeToast(error?.localizedDescription ?? "")
                        log.error("error = \(error?.localizedDescription ?? "")")
                        
                    })
                }
            }
        })
    }
}
