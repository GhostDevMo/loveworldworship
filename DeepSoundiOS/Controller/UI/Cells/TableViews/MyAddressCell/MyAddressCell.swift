//
//  MyAddressCell.swift
//  DeepSoundiOS
//
//  Created by iMac on 26/07/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit

protocol MyAddressCellDelegate {
    func handleEditButtonTap(indexPath: IndexPath)
    func handleDeleteButtonTap(indexPath: IndexPath)
    func selectAddressButtonTap(indexPath: IndexPath)
}

extension MyAddressCellDelegate {
    func handleEditButtonTap(indexPath: IndexPath) {}
    func handleDeleteButtonTap(indexPath: IndexPath) {}
    func selectAddressButtonTap(indexPath: IndexPath) {}
}

class MyAddressCell: UITableViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var countryAndCityLabel: UILabel!
    
    var delegate: MyAddressCellDelegate?
    var indexPath = IndexPath(row: 0, section: 0)

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.mainView.addShadow()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
        
    // Edit Button Action
    @IBAction func editButtonAction(_ sender: UIButton) {
        self.delegate?.handleEditButtonTap(indexPath: self.indexPath)
    }
    
    // Delete Button Action
    @IBAction func deleteButtonAction(_ sender: UIButton) {
        self.delegate?.handleDeleteButtonTap(indexPath: self.indexPath)
    }
    
    func setData(object: AddressData) {
        self.nameLabel.text = object.name
        self.phoneLabel.text = object.phone
        self.addressLabel.text = object.address
        self.countryAndCityLabel.text = (object.country ?? "") + " / " + (object.city ?? "")
    }
    
}
