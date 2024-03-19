//
//  DatePickerView.swift
//  DailyHoroscope
//
//  Created by iMac on 22/09/22.
//

import UIKit

protocol DatePickerViewDelegate {
    func datePickerOkButtonAction(view: DatePickerView, sender: UIButton, date: Date)
    func datePickerCancelButtonAction(view: DatePickerView, sender: UIButton)
}

class DatePickerView: UIView {
    
    // MARK: - IBOutlets
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var datePickerBackgroundView: UIView!
    
    // MARK: - Properties
    var delegate: DatePickerViewDelegate?
    
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
        Bundle.main.loadNibNamed("DatePickerView", owner: self, options: nil)
        contentView.isOpaque = false
        contentView.backgroundColor = .clear
        addSubview(contentView)
        contentView.frame = self.bounds
    }
    
    // SetUp Date Picker UI
    func setDatePickerUI() {
        self.datePickerBackgroundView.layer.cornerRadius = 20
        self.datePickerBackgroundView.layer.masksToBounds = true
        if #available(iOS 13.0, *) {
            self.datePicker.overrideUserInterfaceStyle = .light
        }
    }
    
    // MARK: - Selectors
    
    // Ok Button Action
    @IBAction func okButtonAction(_ sender: UIButton) {
        let date = datePicker.date
        delegate?.datePickerOkButtonAction(view: self, sender: sender, date: date)
    }
    
    // Cancel Button Action
    @IBAction func cancelButtonAction(_ sender: UIButton) {
        delegate?.datePickerCancelButtonAction(view: self, sender: sender)
    }
    
}
