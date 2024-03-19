//
//  SelectProductCategoryPopupVC.swift
//  DeepSoundiOS
//
//  Created by iMac on 10/07/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit

struct CategoryModel {
    var id: String?
    var title: String?
}

protocol SelectProductCategoryDelegate {
    func selectCategory(category: CategoryModel)
}


class SelectProductCategoryPopupVC: BaseVC {
    
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var categoryID: String?
    var delegate: SelectProductCategoryDelegate?
    private var categoryArray:[CategoryModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    private func setupUI() {
        self.tableView.separatorStyle = .none
        let XIB = UINib(resource: R.nib.categoryTableViewCell)
        self.tableView.register(XIB, forCellReuseIdentifier: R.reuseIdentifier.categoryTableViewCell.identifier)
        let category = AppInstance.instance.optionsData?.products_categories
        for (key,value ) in category?.dictionaryValue ?? [:] {
            categoryArray.append(CategoryModel(id: key, title: value))
        }
        self.categoryArray = self.categoryArray.sorted(by: {($0.title ?? "") < ($1.title ?? "")})
        self.tableView.reloadData()
    }
}

extension SelectProductCategoryPopupVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categoryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.categoryTableViewCell.identifier) as? CategoryTableViewCell
        cell?.selectImage.isHidden = !(self.categoryID == self.categoryArray[indexPath.row].id)
        cell?.lblTitle.text = self.categoryArray[indexPath.row].title
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            self.delegate?.selectCategory(category: self.categoryArray[indexPath.row])
        }
    }
}
