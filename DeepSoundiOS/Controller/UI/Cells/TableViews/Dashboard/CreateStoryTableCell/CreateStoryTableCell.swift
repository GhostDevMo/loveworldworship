//
//  CreateStoryTableCell.swift
//  DeepSoundiOS
//
//  Created by iMac on 30/06/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit

protocol CreateStoryDelegate {
    func createStoryPressed()
    func storyView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
}

class CreateStoryTableCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var delegate: CreateStoryDelegate?
    var storysArray: [Story] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupCollectionView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(resource: R.nib.createStoryCollectionCell), forCellWithReuseIdentifier: R.reuseIdentifier.createStoryCollectionCell.identifier)
    }
    
    func bind(_ object: [Story]) {
        self.storysArray = object
        self.collectionView.reloadData()
    }
}

extension CreateStoryTableCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1+self.storysArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.createStoryCollectionCell.identifier, for: indexPath) as! CreateStoryCollectionCell
        cell.lblTitle.isHidden = true
        if indexPath.row != 0 {
            cell.bind(self.storysArray[indexPath.row-1])
        }else {
            cell.thumbailImage.image = R.image.icn_boy()
            cell.shapeView.image = R.image.icn_boy()
            cell.shapeView.title = "Create Story"
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.delegate?.createStoryPressed()
        }else {
            self.delegate?.storyView(self.collectionView, didSelectItemAt: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 150, height: 200)
    }
}
