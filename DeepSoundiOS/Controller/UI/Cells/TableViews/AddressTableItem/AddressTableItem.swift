//
//  AddressTableItem.swift
//  DeepSoundiOS
//
//  Created by iMac on 04/09/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit

class AddressTableItem: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var btnSelect: UIButton!
    
    var delegate: MyAddressCellDelegate?
    var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.mainView.addShadow()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func selectAddressBtnAction(_ sender: UIButton) {
        if let indexPath = indexPath {
            self.delegate?.selectAddressButtonTap(indexPath: indexPath)
        }
    }
    
    func bind(_ object: AddressData) {
        self.lblName.text = object.name
        self.lblPhone.text = object.phone
        self.lblAddress.text = object.address
        self.lblCity.text = (object.country ?? "") + " / " + (object.city ?? "")
    }
}
