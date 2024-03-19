//
//  EventDetailVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris But on 17/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK

class EventDetailVC: BaseVC {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var lblHeader: UILabel!
    
    var eventDetailObject: Events?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        table.register(UINib(resource: R.nib.eventDetailTableItem), forCellReuseIdentifier: R.reuseIdentifier.eventDetailTableItem.identifier)
        self.lblHeader.text = eventDetailObject?.name
    }
    
    @IBAction func moreButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let newVC = R.storyboard.popups.playlistPopUpVC()
        newVC?.isEvent = true
        newVC?.productDelegate = self
        self.present(newVC!, animated: true)
    }
}


extension EventDetailVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: R.reuseIdentifier.eventDetailTableItem.identifier) as! EventDetailTableItem
        if let eventDetailObject = eventDetailObject {
            cell.bind(object: eventDetailObject)
        }
        cell.vc = self
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension EventDetailVC: ProductDetailsDelegate {
    func addToCartBtn(_ sender: UIButton, qty: Int) { }
    
    func shareBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        self.share(shareString: self.eventDetailObject?.url)
    }
    
    private func share(shareString:String?) {
        // text to share
        let text = shareString ?? ""
        
        // set up activity view controller
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    func copyBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        UIPasteboard.general.string = self.eventDetailObject?.url ?? ""
        self.view.makeToast("Text copied to clipboard")
    }
}
