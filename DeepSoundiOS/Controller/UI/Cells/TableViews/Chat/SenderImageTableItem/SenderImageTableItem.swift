//
//  SenderImageTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/21/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import SDWebImage

class SenderImageTableItem: UITableViewCell {

    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var showBtn: UIButton!
    
    var delegate: ChatImageShowDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func bind(_ object: GetMessage) {
        var urlSTR = ""
        if object.image.contains(find: "https") {
            urlSTR = object.image
        }else {
            urlSTR = "https://demo.deepsoundscript.com/" + object.image
        }
        let thumbnailURL = URL.init(string: urlSTR)
        let indicator = SDWebImageActivityIndicator.medium
        self.thumbnailImage.sd_imageIndicator = indicator
        DispatchQueue.global(qos: .userInteractive).async {
            self.thumbnailImage.sd_setImage(with: thumbnailURL , placeholderImage:R.image.imagePlacholder())
        }
        let seen = object.time
        self.dateLabel.text = getDate(unixdate: seen, timezone: "GMT")
    }
    
    @IBAction func showImageAction(_ sender: UIButton) {
        if let image = self.thumbnailImage {
            self.delegate?.showImageBtn(sender, imageView: image)
        }
    }
}
