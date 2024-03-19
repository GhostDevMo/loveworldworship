//
//  FilterProductsVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 20/12/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit

protocol FilterProductDelegate {
    func filterProducts(categoryID: String, priceMin:String,PriceMax:String)
}

class FilterProductsVC: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var priceMaxTextField: UITextField!
    @IBOutlet weak var priceMinTextField: UITextField!
    @IBOutlet weak var categoryLabel: UILabel!
    
    // MARK: - Properties
    
    var delegate: FilterProductDelegate?
    var categoryID: String?
    var sheetHeight: CGFloat = 0
    var sheetBackgroundColor: UIColor = .white
    var sheetCornerRadius: CGFloat = 20
    private var hasSetOriginPoint = false
    private var originPoint: CGPoint?
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialConfig()
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetOriginPoint {
            hasSetOriginPoint = true
            originPoint = view.frame.origin
        }
    }
    
    // MARK: - Selectors
    
    @IBAction func categoryPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        let alert = R.storyboard.popups.selectProductCategoryPopupVC()
        alert?.delegate = self
        alert?.categoryID = categoryID
        self.present(alert!, animated: true, completion: nil)
    }
    
    @IBAction func filterPressed(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.filterProducts(categoryID: self.categoryID ?? "", priceMin: self.priceMinTextField.text ?? "", PriceMax: self.priceMaxTextField.text ?? "")
        }
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.sheetHeight = 378 + self.view.safeAreaBottom
        view.frame.size.height = sheetHeight
        view.isUserInteractionEnabled = true
        view.backgroundColor = sheetBackgroundColor
        view.roundCorners(corners: [.topLeft, .topRight], radius: sheetCornerRadius)
        self.setPanGesture()
        self.setData()
    }
    
    // SetData
    func setData() {
        let category = AppInstance.instance.optionsData?.products_categories
        for (key, value) in category?.dictionaryValue ?? [:] {
            if self.categoryID == key {
                self.categoryLabel.text = value
                break
            } else {
                self.categoryLabel.text = "Category"
            }
        }
    }
    
    // Set Pan Gesture
    func setPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
    }
    
    // Gesture Recognizer
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        // Not allowing the user to drag the view upward
        guard translation.y >= 0 else { return }
        view.frame.origin = CGPoint(
            x: 0,
            y: self.originPoint!.y + translation.y
        )
        if sender.state == .ended {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}

// MARK: - Extensions

// MARK: SelectProductCategoryDelegate
extension FilterProductsVC: SelectProductCategoryDelegate {
    
    func selectCategory(category: CategoryModel) {
        self.categoryID = category.id
        self.categoryLabel.text = category.title
    }
    
}
