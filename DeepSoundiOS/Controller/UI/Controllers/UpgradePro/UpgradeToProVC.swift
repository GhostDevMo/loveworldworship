//
//  UpgradeToProVC.swift
//  DeepSoundiOS
//
//  Created by Moghees on 21/10/2022.
//  Copyright © 2022 Moghees Idrees. All rights reserved.
//

import UIKit

class UpgradeToProVC: BaseVC {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UpgradeProHeaderCell.nib, forCellReuseIdentifier: UpgradeProHeaderCell.identifier)
        tableView.register(UpgradeOneMonthCell.nib, forCellReuseIdentifier: UpgradeOneMonthCell.identifier)
        tableView.register(UpgradethreeMonthCell.nib, forCellReuseIdentifier: UpgradethreeMonthCell.identifier)
        tableView.register(UpgradeSixMonthCell.nib, forCellReuseIdentifier: UpgradeSixMonthCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    



}
extension UpgradeToProVC:UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row{
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: UpgradeProHeaderCell.identifier) as! UpgradeProHeaderCell
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: UpgradeOneMonthCell.identifier) as! UpgradeOneMonthCell
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: UpgradethreeMonthCell.identifier) as! UpgradethreeMonthCell
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: UpgradeSixMonthCell.identifier) as! UpgradeSixMonthCell
            return cell
        default:
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1{
            let storyBoard: UIStoryboard = UIStoryboard(name: "Upgrade", bundle: nil)
             let vc = storyBoard.instantiateViewController(withIdentifier: "PaymentOptionVC") as! PaymentOptionVC
            vc.selectedPakgeAmount = 9.99
             self.navigationController?.pushViewController(vc, animated: true)
        }
        else if indexPath.row == 2{
            let storyBoard: UIStoryboard = UIStoryboard(name: "Upgrade", bundle: nil)
             let vc = storyBoard.instantiateViewController(withIdentifier: "PaymentOptionVC") as! PaymentOptionVC
            vc.selectedPakgeAmount = 19.99
             self.navigationController?.pushViewController(vc, animated: true)
        }
        else if indexPath.row == 3{
            let storyBoard: UIStoryboard = UIStoryboard(name: "Upgrade", bundle: nil)
             let vc = storyBoard.instantiateViewController(withIdentifier: "PaymentOptionVC") as! PaymentOptionVC
            vc.selectedPakgeAmount = 39.99
             self.navigationController?.pushViewController(vc, animated: true)
        }
       
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
}
