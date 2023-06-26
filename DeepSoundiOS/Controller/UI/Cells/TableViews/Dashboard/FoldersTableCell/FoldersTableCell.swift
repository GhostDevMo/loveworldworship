//
//  FoldersTableCell.swift
//  DeepSoundiOS
//
//  Created by Mac Pro on 25/08/2022.
//  Copyright © 2022 Moghees Idrees. All rights reserved.
//

import UIKit

class FoldersTableCell: UITableViewCell {

    @IBOutlet weak var btnMoreOption: UIButton!
    @IBOutlet weak var lblSongsCount: UILabel!
    @IBOutlet weak var lblFoldeerTittle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
