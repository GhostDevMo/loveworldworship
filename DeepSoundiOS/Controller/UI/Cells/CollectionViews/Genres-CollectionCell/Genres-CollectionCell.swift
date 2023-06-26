//
//  Genres-CollectionCell.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 15/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class Genres_CollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var tickImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    private var status:Bool? = false
    var genresIdArray = [GenresModel.Datum]()
    var indexPath:Int? = 0
    var delegate: didSetInterestGenres?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

    @IBAction func genresPressed(_ sender: Any) {
        self.status = !status!
        if status!{
            self.delegate?.didSetInterest(Label:self.nameLabel , Image: self.tickImage, status: status ?? false,idsArray:genresIdArray,Index:indexPath!)
        }else{
            self.delegate?.didSetInterest(Label:self.nameLabel , Image: self.tickImage, status: status ?? false,idsArray:genresIdArray,Index:indexPath!)
        }
    }
}
