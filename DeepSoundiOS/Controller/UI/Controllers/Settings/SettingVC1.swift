//
//  SettingVC1.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 08/12/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class SettingVC1: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    private func setupUI(){
        self.tableView.separatorStyle = .none
        tableView.register(Settings_TableCell.nib, forCellReuseIdentifier: Settings_TableCell.identifier)
        
    }
    
}
extension SettingVC1: UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
         return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0: return 6
        case 1: return 1
        case 2: return 4
       
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: Settings_TableCell.identifier) as! Settings_TableCell
                cell.descriptionLabel.isHidden = true
                cell.titleLabel.text = (NSLocalizedString("General", comment: ""))
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: Settings_TableCell.identifier) as! Settings_TableCell
                cell.descriptionLabel.isHidden = true
                cell.titleLabel.text = (NSLocalizedString("My Account", comment: ""))
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: Settings_TableCell.identifier) as! Settings_TableCell
                cell.descriptionLabel.isHidden = false
                cell.titleLabel.text = (NSLocalizedString("Password", comment: ""))
                cell.descriptionLabel.text = (NSLocalizedString("Change your password", comment: ""))
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: Settings_TableCell.identifier) as! Settings_TableCell
                cell.descriptionLabel.isHidden = true
                cell.titleLabel.text = (NSLocalizedString("Widthdrawals", comment: ""))
                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: Settings_TableCell.identifier) as! Settings_TableCell
                cell.descriptionLabel.isHidden = true
                cell.titleLabel.text = (NSLocalizedString("Go Pro", comment: ""))
                return cell
            case 5:
                let cell = tableView.dequeueReusableCell(withIdentifier: Settings_TableCell.identifier) as! Settings_TableCell
                cell.descriptionLabel.isHidden = true
                cell.titleLabel.text = (NSLocalizedString("Blocked Users", comment: ""))
                return cell
            default:
                return UITableViewCell()
            }
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: Settings_TableCell.identifier) as! Settings_TableCell
            cell.descriptionLabel.isHidden = true
            cell.descriptionLabel.isHidden = false
            cell.titleLabel.text = (NSLocalizedString("Interest", comment: ""))
            cell.descriptionLabel.text = (NSLocalizedString("Select Your Music Preference", comment: ""))
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: Settings_TableCell.identifier) as! Settings_TableCell
           
            switch indexPath.row {
            case 0:
                cell.descriptionLabel.isHidden = true
                cell.titleLabel.text = (NSLocalizedString("Help", comment: ""))
            case 1:
                cell.descriptionLabel.isHidden = true
                cell.titleLabel.text = (NSLocalizedString("About", comment: ""))
            case 2:
                cell.descriptionLabel.isHidden = true
                cell.titleLabel.text = (NSLocalizedString("Delete Account", comment: ""))
            case 2:
                cell.descriptionLabel.isHidden = true
                cell.titleLabel.text = (NSLocalizedString("Logout", comment: ""))
            default:
                break
            }
            return cell
      
        default:
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            return nil
        } else {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 56))
            view.backgroundColor = .systemBackground
            
            let separatorView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 8))
            separatorView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
            
            let label = UILabel(frame: CGRect(x: 16, y: 8, width: view.frame.size.width, height: 48))
            label.font = UIFont(name: "ChalkboardSE-Light", size: 17)
            label.textColor = UIColor.hexStringToUIColor(hex: "FFA143")
            if section == 1 {
                label.text = (NSLocalizedString("Interest", comment: ""))
            } else if section == 2 {
                label.text = (NSLocalizedString("Support", comment: ""))
            }
            view.addSubview(separatorView)
            view.addSubview(label)
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return 56
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath == IndexPath(row: 1, section: 0) {
            return 88
        } else {
            return 56
        }
    }
}
