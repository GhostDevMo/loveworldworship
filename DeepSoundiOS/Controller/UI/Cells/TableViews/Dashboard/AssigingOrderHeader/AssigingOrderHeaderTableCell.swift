//
//  AssigingOrderHeaderTableCell.swift
//  DeepSoundiOS
//
//  Created by Mac Pro on 26/08/2022.
//  Copyright © 2022 Moghees Idrees. All rights reserved.
//

import UIKit

class AssigingOrderHeaderTableCell: UITableViewCell {

    @IBOutlet weak var lblOrderName: UILabel!
    @IBOutlet weak var btnArrangOrder: UIButton!
    @IBOutlet weak var lblTotalSongs: UILabel!
    @IBOutlet weak var swapImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnArrangOrder.setTitleColor(.ButtonColor, for: .normal)
        swapImage.tintColor = .ButtonColor
        btnArrangOrder.tintColor = .ButtonColor
        lblOrderName.textColor = .ButtonColor 
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
