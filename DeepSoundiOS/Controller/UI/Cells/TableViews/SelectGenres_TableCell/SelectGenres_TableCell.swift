//
//  SelectGenres_TableCell.swift
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

    private var status:Bool = false
    var genresIdArray = [GenresModel.Datum]()
    var indexPath:Int = 0
    var delegate: didSetGenrestDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    @IBAction func selectPressed(_ sender: UIButton) {
        self.status = !status
        self.delegate?.didSetGenres(Image: self.checkImage, status: status , idsArray: genresIdArray, Index: indexPath)
    }
}
