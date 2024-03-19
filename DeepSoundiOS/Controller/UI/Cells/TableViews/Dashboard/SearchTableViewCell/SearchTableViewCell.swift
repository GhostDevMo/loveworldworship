//
//  SearchTableViewCell.swift
//  DeepSoundiOS
//
//  Created by iMac on 07/07/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit

protocol SearchTableViewCellDelegate {
    func searchBtnPressed(_ sender: UIButton)
}

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var searchTF: UITextField!
    
    var delegate: SearchTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func searchBtnPressed(_ sender: UIButton) {
        self.delegate?.searchBtnPressed(sender)
    }
    
}
