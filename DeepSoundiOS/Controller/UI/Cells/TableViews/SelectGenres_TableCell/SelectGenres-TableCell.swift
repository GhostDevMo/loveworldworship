//
//  SelectGenres-TableCell.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 24/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class SelectGenres_TableCell: UITableViewCell {
    
    @IBOutlet weak var genresNameLabel
    : UILabel!
    @IBOutlet weak var checkImage: UIImageView!

    private var status:Bool? = false
    var genresIdArray = [GenresModel.Datum]()
    var indexPath:Int? = 0
    var delegate: didSetGenrestDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    @IBAction func selectPressed(_ sender: Any) {
        self.status = !status!
        if status!{
            self.delegate?.didSetGenres(Image: self.checkImage, status: status ?? false, idsArray: genresIdArray, Index: indexPath!)
        }else{
            self.delegate?.didSetGenres(Image: self.checkImage, status: status ?? false, idsArray: genresIdArray, Index: indexPath!)
        }
    }
}
