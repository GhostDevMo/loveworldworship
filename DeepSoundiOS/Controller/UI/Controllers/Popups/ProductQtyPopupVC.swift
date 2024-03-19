//
//  ProductQtyPopupVC.swift
//  DeepSoundiOS
//
//  Created by iMac on 04/09/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit

protocol ProductQtyPopupDelegate {
    func selectedQTY(_ selected: Int)
}

class ProductQtyPopupVC: BaseVC {
    
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var categoryID: String?
    var delegate: ProductQtyPopupDelegate?
    private var qtyArray:[Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    private func setupUI() {
        self.tableView.separatorStyle = .none
        let XIB = UINib(resource: R.nib.categoryTableViewCell)
        self.tableView.register(XIB, forCellReuseIdentifier: R.reuseIdentifier.categoryTableViewCell.identifier)
        self.qtyArray = Array(1...100)
        self.tableView.reloadData()
    }
}

extension ProductQtyPopupVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.qtyArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.categoryTableViewCell.identifier) as? CategoryTableViewCell
        cell?.selectImage.isHidden = true
        cell?.lblTitle.text = "\(self.qtyArray[indexPath.row])"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            self.delegate?.selectedQTY(self.qtyArray[indexPath.row])
        }
    }
}
