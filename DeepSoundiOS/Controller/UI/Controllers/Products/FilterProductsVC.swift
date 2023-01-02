//
//  FilterProductsVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 20/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit

protocol FilterProductDelegate {
    func filterProducts(categoryID:Int, priceMin:String,PriceMax:String)
}
class FilterProductsVC: UIViewController {
    
    @IBOutlet weak var priceMaxTextField: UITextField!
    @IBOutlet weak var priceMinTextField: UITextField!
    @IBOutlet weak var categoryBtn: UIButton!
    
    var delegate:FilterProductDelegate?
    var categoryID:Int? = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
       @IBAction func categoryPressed(_ sender: Any) {
        let category = AppInstance.instance.options["products_categories"] as? [String:Any]
        let alert = UIAlertController(title: "Category", message: "", preferredStyle: .actionSheet)
        for (key,value ) in category ?? [:] {
            let button = UIAlertAction(title: value as? String, style: .default) { action in
              print("value = \(value as? String)")
                print("key = \(key )")
                self.categoryBtn.setTitle(value as! String , for: .normal)
                self.categoryID = Int(key)
            }
            alert.addAction(button)
            
        }
        let close = UIAlertAction(title: "Close", style: .destructive, handler: nil)
        alert.addAction(close)
        self.present(alert, animated: true, completion: nil)
 
    }
    @IBAction func filterPressed(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.filterProducts(categoryID: self.categoryID ?? 0, priceMin: self.priceMinTextField.text ?? "", PriceMax: self.priceMaxTextField.text ?? "")
        }
    }
}
