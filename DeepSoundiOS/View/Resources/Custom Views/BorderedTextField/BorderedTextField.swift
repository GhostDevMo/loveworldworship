//
//  UnderLineTextField.swift
//  EDYOU
//
//  Created by  Mac on 03/09/2021.
//


import UIKit
import IQKeyboardManagerSwift

protocol EDTextField {
    var errorLabel: UILabel! { get }
    var textField: UITextField! { get }
    func setError(_ text: String?)
    func validate() -> Bool
}

@IBDesignable
class BorderedTextField: UIView, EDTextField {
    
    
    var view: UIView!
    var datePicker =  UIDatePicker()
    var selectedDate: Date?
    var dateFormat: String = "dd MMM yyyy"
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var leftIconImageView: UIImageView!
    @IBOutlet weak var rightIconImageView: UIImageView!
    @IBOutlet weak var viewBgActivityIndicator: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var leftSeparatorView: UIView!
    @IBOutlet weak var rightButton: UIButton!
    
    @IBOutlet weak var cstLeftIconImageViewLeading: NSLayoutConstraint!
    @IBOutlet weak var cstLeftIconImageViewTrailing: NSLayoutConstraint!
    @IBOutlet weak var cstLeftIconImageViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var cstRightIconImageViewTrailing: NSLayoutConstraint!
    @IBOutlet weak var cstRightIconImageViewHeight: NSLayoutConstraint!
    
    
    private var leftIconHeight: CGFloat = 18
    private var rightIconHeight: CGFloat = 18
    private var leftIconLeading: CGFloat = 4
    private var rightIconTrailing: CGFloat = 4
    
    public var validations = [Validation]()
    public var validateTrimmedText = false
    
    public var rightButtonHandler: ((_ sender: UIButton, _ imageView: UIImageView) -> Void)?
    
    struct BTColors {
        static let separator = UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1)
        static let red = UIColor.red
    }
    
    // MARK: - Inspectable Properties
    @IBInspectable var text: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
            setError(nil)
        }
    }
    
    @IBInspectable var textColor: UIColor? {
        get {
            return textField.textColor
        }
        set {
            return textField.textColor = newValue ?? UIColor.white
        }
    }
    
    @IBInspectable var placeholder: String? {
        get {
            return textField.placeholder
        }
        set {
            return textField.placeholder = newValue ?? ""
        }
    }
    @IBInspectable var leftIconLeftPadding: CGFloat {
        get {
            return leftIconLeading
        }
        set {
            leftIconLeading = newValue
            cstLeftIconImageViewLeading.constant = leftIconImage != nil ? leftIconLeading : 0
            cstLeftIconImageViewTrailing.constant = leftIconImage != nil ? leftIconLeading : 0
            
            view?.layoutIfNeeded()
        }
    }
    @IBInspectable var leftIconImage: UIImage? {
        get {
            return leftIconImageView.image
        }
        set {
            leftIconImageView.image = newValue
            cstLeftIconImageViewHeight.constant = newValue != nil ? leftIconHeight : 0
            //leftSeparatorView.isHidden = leftIconImage == nil
            view?.layoutIfNeeded()
        }
    }
    @IBInspectable var leftIconSize: CGFloat {
        get {
            return leftIconHeight
        }
        set {
            leftIconHeight = newValue
            cstLeftIconImageViewHeight.constant = leftIconImage != nil ? leftIconHeight : 0
            view?.layoutIfNeeded()
        }
    }
    @IBInspectable var rightIconRightPadding: CGFloat {
        get {
            return rightIconTrailing
        }
        set {
            rightIconTrailing = newValue
            print(rightIconImage != nil ? rightIconTrailing : 0)
            cstRightIconImageViewTrailing.constant = rightIconImage != nil ? rightIconTrailing : 0
            view?.layoutIfNeeded()
        }
    }
    @IBInspectable var rightIconImage: UIImage? {
        get {
            return rightIconImageView.image
        }
        set {
            rightIconImageView.image = newValue
            cstRightIconImageViewHeight.constant = newValue != nil ? rightIconHeight : 0
            cstRightIconImageViewTrailing.constant = newValue != nil ? rightIconTrailing : 0
            view?.layoutIfNeeded()
        }
    }
    @IBInspectable var rightIconSize: CGFloat {
        get {
            return rightIconHeight
        }
        set {
            rightIconHeight = newValue
            cstRightIconImageViewHeight.constant = rightIconImage != nil ? rightIconHeight : 0
            view?.layoutIfNeeded()
        }
    }
    
    
    // MARK: - View Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    func xibSetup() {
//        backgroundColor = .clear
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        addSubview(view)
        
        view.layoutIfNeeded()
        
    }
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return nibView
    }
    
    @IBAction func didEditingChanged(_ sender: UITextField) {
        setError(nil)
    }
    
    @IBAction func rightButtonAction(_ sender: UIButton) {
        self.rightButtonHandler?(sender, self.rightIconImageView)
    }
    
    
}

// MARK: - Utility Methods
extension BorderedTextField {
    func setError(_ text: String?) {
        if text == nil {
//            view.layer.borderColor = BTColors.separator
            errorLabel.text = text
        } else {
//            view.layer.borderColor = BTColors.red
            errorLabel.text = text
        }
        view.layoutIfNeeded()
    }
    func validate() -> Bool {
        let text = (validateTrimmedText ? textField.text?.trimmed : textField.text) ?? ""
        for validation in validations {
            let result = validation.validate(text: text)
            if result == false {
                setError(validation.error)
                return false
            }
        }
        setError(nil)
        return true
    }
    func startLoading() {
        viewBgActivityIndicator.backgroundColor = UIColor.white
        viewBgActivityIndicator.isHidden = false
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    func stopLoading() {
        viewBgActivityIndicator.isHidden = true
    }
}

extension BorderedTextField {
    func setupDatePicker(maximumDate: Date, minimumDate: Date?, dateFormat: String? = nil) {
        self.datePicker.maximumDate = maximumDate
        self.datePicker.minimumDate = minimumDate
        if let dateFormat = dateFormat {
            self.dateFormat = dateFormat
        }
        if #available(iOS 13.4, *) {
            self.datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
            //self.datePicker.datePickerStyle = .wheels
            
        }
        self.datePicker.datePickerMode = .date
        self.datePicker.removeTarget(self, action: nil, for: .allEvents)
        self.datePicker.addTarget(self, action: #selector(didChangeDate), for: .valueChanged)
        self.textField.iq.addDone(target: self, action: #selector(didDoneTapped))
        self.textField.inputView = self.datePicker
        self.textField.iq.toolbar.doneBarButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: UIControl.State.normal)

    }
    
    @objc func didChangeDate() {
        self.text = self.datePicker.date.stringValue(format: dateFormat)
    }
    @objc func didDoneTapped() {
        self.text = self.datePicker.date.stringValue(format: dateFormat)
        self.textField.resignFirstResponder()
    }
    
    func updateRightImageTint(tintColor: UIColor) {
        self.rightIconImageView.image = self.rightIconImage?.withRenderingMode(.alwaysTemplate)
        self.rightIconImageView.tintColor = tintColor
    }
    func updateLeftImageTint(tintColor: UIColor) {
        self.leftIconImageView.image = self.leftIconImage?.withRenderingMode(.alwaysTemplate)
        self.leftIconImageView.tintColor = tintColor
    }
}
