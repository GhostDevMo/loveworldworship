//
//  TimePickerView.swift
//  DeepSoundiOS
//
//  Created by iMac on 24/07/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit

protocol TimePickerViewDelegate {
    func timePickerOkButtonAction(view: TimePickerView, sender: UIButton, date: Date)
    func timePickerCancelButtonAction(view: TimePickerView, sender: UIButton)
}

class TimePickerView: UIView {
    
    // MARK: - IBOutlets
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var timePickerBackgroundView: UIView!
    
    // MARK: - Properties
    var delegate: TimePickerViewDelegate?
    
    // MARK: - View Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: - Helper Functions
    
    private func commonInit() {
        self.initialConfig()
        self.setDatePickerUI()
    }
    
    func initialConfig() {
        Bundle.main.loadNibNamed("TimePickerView", owner: self, options: nil)
        contentView.isOpaque = false
        contentView.backgroundColor = .clear
        addSubview(contentView)
        contentView.frame = self.bounds
    }
    
    // SetUp Date Picker UI
    func setDatePickerUI() {
        self.timePickerBackgroundView.layer.cornerRadius = 20
        self.timePickerBackgroundView.layer.masksToBounds = true
        if #available(iOS 13.0, *) {
            self.timePicker.overrideUserInterfaceStyle = .light
        }
    }
    
    // MARK: - Selectors
    
    // Ok Button Action
    @IBAction func okButtonAction(_ sender: UIButton) {
        let date = timePicker.date
        self.delegate?.timePickerOkButtonAction(view: self, sender: sender, date: date)
    }
    
    // Cancel Button Action
    @IBAction func cancelButtonAction(_ sender: UIButton) {
        self.delegate?.timePickerCancelButtonAction(view: self, sender: sender)
    }
    
}
