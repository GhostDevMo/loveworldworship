//
//  Genres-CollectionCell.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 15/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit

protocol GenresCellDelegate {
    func handleGenresTap(indexPath: IndexPath)
}

class Genres_CollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var shadowView: UIView! {
        didSet {
            self.shadowView.addShadow(offset: CGSize(width: 0, height: 1))
        }
    }
    @IBOutlet weak var tickImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var backgroundImageTrailingConst: NSLayoutConstraint!
    @IBOutlet weak var backgroundImageBottomConst: NSLayoutConstraint!
    
    var indexPath = IndexPath(row: 0, section: 0)
    var delegate: GenresCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
        
    @IBAction func genresPressed(_ sender: UIButton) {
        self.delegate?.handleGenresTap(indexPath: self.indexPath)
    }
    
}
