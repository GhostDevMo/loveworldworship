//
//  EventTableCell.swift
//  DeepSoundiOS
//
//  Created by hunain khan on 17/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit

protocol EventTableCellDelegate {
    func selectEvent(_ eventsArray:[Events], indexPath: IndexPath, cell: EventTableCell)
    func selectArticle(_ articleArray:[Blog], indexPath: IndexPath, cell: EventTableCell)
}

class EventTableCell: UITableViewCell {
    
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var object = [Events]()
    var object2 = [Blog]()
    var isEvent = false {
        didSet {            
            self.collectionViewHeight.constant = isEvent ? 260 : 220
            self.needsUpdateConstraints()
        }
    }
    var isLoading = true {
        didSet {
            if isLoading {
                self.object.removeAll()
                self.collectionView.reloadData()
            }
        }
    }
    var delegate: EventTableCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }
    
    func setupUI(){
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(resource: R.nib.eventsCollectionCell), forCellWithReuseIdentifier: R.reuseIdentifier.eventsCollectionCell.identifier)
        self.collectionView.register(UINib(resource: R.nib.articlesCollectionItem), forCellWithReuseIdentifier: R.nib.articlesCollectionItem.identifier)
    }
    
    func bind(_ object:[Events]){
        self.object = object
        self.collectionView.reloadData()
    }
    
    func bind(_ object:[Blog]){
        self.object2 = object
        self.collectionView.reloadData()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension EventTableCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isLoading {
            return 5
        } else {
            if isEvent {
                return self.object.count
            }else{
                return self.object2.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isLoading {
            if isEvent {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.eventsCollectionCell.identifier, for: indexPath) as! EventsCollectionCell
                cell.startSkelting()
                cell.eventView.backgroundColor = .systemGray4
                return cell
            }else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.articlesCollectionItem.identifier, for: indexPath) as! ArticlesCollectionItem
                cell.startSkelting()
                return cell
            }
        }else {
            if !isEvent {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.articlesCollectionItem.identifier, for: indexPath) as! ArticlesCollectionItem
                cell.stopSkelting()
                let object = self.object2[indexPath.row]
                cell.bind(object)
                return cell
            }else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.eventsCollectionCell.identifier, for: indexPath) as! EventsCollectionCell
                cell.stopSkelting()
                let object = self.object[indexPath.row]
                cell.bind(object)
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width
        return CGSize(width: width, height: isEvent ? 260 : 220)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEvent {
            self.delegate?.selectEvent(self.object, indexPath: indexPath, cell: self)
        }else {
            self.delegate?.selectArticle(self.object2, indexPath: indexPath, cell: self)
        }
    } 
}
