//
//  PremiumPopupVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 7/3/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class PremiumPopupVC: UIViewController {
    @IBOutlet weak var expirationDateLabel: UILabel!
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var SkipLabel: UIButton!
    @IBOutlet weak var proLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.bgView.backgroundColor = .mainColor
    }
    
    private func setupUI(){
        self.expirationDateLabel.text  = "Expiration Date : \(getDate(unixdate: AppInstance.instance.userProfile?.data?.proTime ?? 0 , timezone: "GMT"))"
        self.SkipLabel.setTitle((NSLocalizedString("Skip", comment: "")), for: .normal)
        self.proLabel.text = (NSLocalizedString("You are Premium User", comment: ""))
    }
    
    private func getDate(unixdate: Int, timezone: String) -> String {
        if unixdate == 0 {return ""}
        let date = NSDate(timeIntervalSince1970: TimeInterval(unixdate))
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "EEEE, MMM d, yyyy"
        dayTimePeriodFormatter.timeZone = .current
        let dateString = dayTimePeriodFormatter.string(from: date as Date)
        return "Updated: \(dateString)"
    }
    
    
    @IBAction func skipPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
