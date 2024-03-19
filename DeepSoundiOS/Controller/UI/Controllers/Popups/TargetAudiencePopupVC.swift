//
//  TargetAudiencePopupVC.swift
//  DeepSoundiOS
//
//  Created by iMac on 19/08/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit

struct CountryList {
    let value: String
    let text: String
}

protocol TargetAudiencePopupDelegate {
    func selectdTargetAudience(_ selectedData: [CountryList])
}

class TargetAudiencePopupVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    var countryArray: [CountryList] = []
    var selectedCountry: [CountryList] = []
    var delegate: TargetAudiencePopupDelegate?
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialConfig()
    }
    
    // MARK: - Selectors -
    // Close Button Action
    @IBAction func selectAllButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if sender.currentTitle == "SELECT ALL" {
            self.selectedCountry.removeAll()
            self.countryArray.forEach { object in
                self.selectedCountry.append(object)
            }
            self.tableView.reloadData()
            sender.setTitle("UNSELECT ALL", for: .normal)
        }else {
            self.selectedCountry.removeAll()
            self.tableView.reloadData()
            sender.setTitle("SELECT ALL", for: .normal)
        }
    }
    
    // Close Button Action
    @IBAction func doneButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true) {
            self.delegate?.selectdTargetAudience(self.selectedCountry)
        }
    }
    
    // MARK: - Helper Functions -
    // Initial Config
    func initialConfig() {
        self.tableViewSetUp()
        self.fetchCountryList()
    }
    
    // TableView SetUp
    func tableViewSetUp() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(resource: R.nib.targetAudienceTableCell), forCellReuseIdentifier: R.reuseIdentifier.targetAudienceTableCell.identifier)
    }
    
    func fetchCountryList() {
        if let path = Bundle.main.path(forResource: "CountryList", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                print(jsonResult)
                if let json = jsonResult as? JSON {
                    if let data = json["option"] as? NSArray {
                        data.forEach { object in
                            if let obj = object as? NSDictionary {
                                if let value = obj["value"] as? String,
                                   let text = obj["text"] as? String {
                                    self.countryArray.append(CountryList(value: value, text: text))
                                }
                            }
                        }
                        self.tableView.reloadData()
                    }
                }
            } catch {
                // handle error
                self.view.makeToast(error.localizedDescription)
            }
        }
    }
}

// MARK: - Extensions

// MARK: TableView Setup
extension TargetAudiencePopupVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.countryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.targetAudienceTableCell.identifier, for: indexPath) as! TargetAudienceTableCell
        let rowPath = self.countryArray[indexPath.row]
        cell.lblTitle.text = rowPath.text
        let image = (self.selectedCountry.contains(where: {$0.value == rowPath.value})) ? R.image.icon_checkmark() : R.image.icon_uncheckmark()
        cell.selectionStyle = .none
        cell.imageSelected.image = image
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowPath = self.countryArray[indexPath.row]
        if self.selectedCountry.contains(where: {$0.value == rowPath.value}) {
            for (index,j) in selectedCountry.enumerated() {
                if rowPath.value == j.value {
                    self.selectedCountry.remove(at: index)
                }
            }
        }else {
            self.selectedCountry.append(rowPath)
        }
        
        self.selectedCountry = removeDuplicateElements(posts: selectedCountry)
        
        //        if self.selectedIndexPath.contains(indexPath) {
        //            for (index,j) in selectedIndexPath.enumerated() {
        //                if indexPath.row == j.row {
        //                    self.selectedIndexPath.remove(at: index)
        //                }
        //            }
        //        }else{
        //            self.selectedIndexPath.append(indexPath)
        //        }
        ////        self.selectedIndexPath = removeDuplicateElements
        
        self.tableView.reloadData()
    }
    
    func removeDuplicateElements(posts: [CountryList]) -> [CountryList] {
        var uniquePosts = [CountryList]()
        for post in posts {
            if !uniquePosts.contains(where: {$0.value == post.value}) {
                uniquePosts.append(post)
            }
        }
        return uniquePosts
    }
}
