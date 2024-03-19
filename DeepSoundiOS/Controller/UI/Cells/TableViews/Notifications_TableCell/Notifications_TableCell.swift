//
//  Notifications_TableCell.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 15/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class Notifications_TableCell: UITableViewCell {

    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var lblType: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(_ object: Notifiations) {
        let str = NSMutableAttributedString().attributedStringWithFont(object.uSER_DATA?.name?.htmlAttributedString ?? "", font: R.font.urbanistBold.callAsFunction(size: 18.0)!, color: UIColor.black).attributedStringWithFont(" \(object.n_text ?? "")", font: R.font.urbanistRegular.callAsFunction(size: 18.0)!, color: UIColor.black)
        self.lblName.attributedText = str
        self.lblTime.text = object.n_time ?? ""
        self.lblType.text = object.n_type?.replacingOccurrences(of: "_", with: " ").uppercased()
        let url = URL.init(string: object.uSER_DATA?.avatar ?? "")
        self.profileImage.sd_setImage(with: url , placeholderImage: R.image.imagePlacholder())
    }
}
