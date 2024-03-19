//
//  NoLoginTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/22/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class NoLoginTableItem: UITableViewCell {

    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var topLabel: UILabel!
    
    var delegate: NoLoginTableDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.topLabel.text = NSLocalizedString("Enjoy your favorite songs", comment: "Enjoy your favorite songs")
        self.bottomLabel.text = NSLocalizedString("Sign in to access song that you have liked or saved", comment: "Sign in to access song that you have liked or saved")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        self.delegate?.buttonPressed(sender)
    }
}
