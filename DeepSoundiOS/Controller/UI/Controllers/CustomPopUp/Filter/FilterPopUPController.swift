//
//  FilterPopUPController.swift
//  DeepSoundiOS
//
//  Created by Mac Pro on 02/09/2022.
//  Copyright © 2022 Moghees Idrees. All rights reserved.
//

import UIKit

protocol FilterTable{
    func filterData(order:Int)
}
class FilterPopUPController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var filter:FilterData = .ascending
    var delegate:FilterTable?
    
    init(dele: FilterTable ) {
        delegate = dele
        super.init(nibName: FilterPopUPController.name, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(FilterPopUpCell.nib, forCellReuseIdentifier: FilterPopUpCell.identifier)

    }
    @objc func didTapRadioButton (sender:UIButton){
        delegate?.filterData(order: sender.tag)
        sender.isSelected = true
        self.dismiss(animated: true)
    }


}
extension FilterPopUPController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FilterData.allCases.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let filter = FilterData(rawValue: indexPath.row)!
        switch filter {
        case .ascending:
            let cell = tableView.dequeueReusableCell(withIdentifier: FilterPopUpCell.identifier) as! FilterPopUpCell
            cell.btnRadio.tag = indexPath.row
            cell.btnRadio.isSelected = true
            cell.btnRadio.addTarget(self, action: #selector(didTapRadioButton(sender:)), for: .touchUpInside)
            
            cell.lblFilterName.text = filter.type
            return cell
        case .descending:
            let cell = tableView.dequeueReusableCell(withIdentifier: FilterPopUpCell.identifier) as! FilterPopUpCell
            cell.btnRadio.tag = indexPath.row
            cell.btnRadio.addTarget(self, action: #selector(didTapRadioButton(sender:)), for: .touchUpInside)
            cell.lblFilterName.text = filter.type
            return cell
   
        case .dateAdded:
            let cell = tableView.dequeueReusableCell(withIdentifier: FilterPopUpCell.identifier) as! FilterPopUpCell
            cell.btnRadio.tag = indexPath.row
            cell.btnRadio.addTarget(self, action: #selector(didTapRadioButton(sender:)), for: .touchUpInside)
            cell.lblFilterName.text = filter.type
            cell.sepratorView.isHidden = true
            return cell
      
        }
        
      
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath,animated: false)
    }
}

