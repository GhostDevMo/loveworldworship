//
//  FilterPopUPController.swift
//  DeepSoundiOS
//
//  Created by Mac Pro on 02/09/2022.
//  Copyright © 2022 Moghees Idrees. All rights reserved.
//

import UIKit

protocol FilterTable {
    func filterData(order: Int)
}

class FilterPopUPController: UIViewController {
    
    // MARK: - IBOutlets

    @IBOutlet weak var tableView: UITableView!
    
    var filter: FilterData = .ascending
    var delegate: FilterTable?
    
    init(dele: FilterTable) {
        delegate = dele
        super.init(nibName: FilterPopUPController.name, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(resource: R.nib.filterPopUpCell), forCellReuseIdentifier: R.reuseIdentifier.filterPopUpCell.identifier)
    }
    
    // MARK: - Selectors
    
    @objc func didTapRadioButton(_ sender: UIButton) {
        sender.isSelected = true
        self.delegate?.filterData(order: sender.tag)
        self.dismiss(animated: true)
    }
    
}

// MARK: - Extensions

// MARK: TableView Setup
extension FilterPopUPController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FilterData.allCases.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.filterPopUpCell.identifier) as! FilterPopUpCell
        let filter = FilterData(rawValue: indexPath.row)!
        cell.lblFilterName.text = filter.type
        cell.btnRadio.tag = indexPath.row
        cell.btnRadio.isSelected = self.filter == filter
        cell.btnRadio.addTarget(self, action: #selector(self.didTapRadioButton), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
}
