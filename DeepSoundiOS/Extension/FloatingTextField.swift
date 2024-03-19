//
//  FloatingTextField.swift
//  QuickDate
//
//  Created by iMac on 03/10/22.
//  Copyright © 2022 ScriptSun. All rights reserved.
//

import Foundation
import UIKit

class FloatingTextField: UITextField {
    
    // MARK:- Properties
    var title = UILabel()
    private var titleLableText: String = ""
    private var isMandatory = false
    let animationDuration = 0.2
    
    private var attributedTitle: NSAttributedString? {
        let boldRange = (titleLableText as NSString).range(of: titleLableText)
        let fnameAttributedString = NSMutableAttributedString(string: titleLableText)
        fnameAttributedString.addAttribute(NSAttributedString.Key.font, value: R.font.urbanistRegular.callAsFunction(size: 16)! , range: boldRange)
        let fnametextRange = (titleLableText as NSString).range(of: "*")
        fnameAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red , range: fnametextRange)
        return fnameAttributedString
    }
    
    var titleFont: UIFont = R.font.urbanistRegular.callAsFunction(size: 16)! {
        didSet {
            title.font = titleFont
            title.sizeToFit()
        }
    }
    
    private var textfeildFont: UIFont {
        return R.font.urbanistRegular.callAsFunction(size: 16)!
    }
    
    private var titleYPadding: CGFloat {
        let hh = (self.frame.height / 2) - 3
        return hh - self.title.font.lineHeight
    }
    
    override var text: String? {
        didSet {
            showTitle(isFirstResponder)
        }
    }
    
    @IBInspectable var hintYPadding:CGFloat = 0.0
    
    
    @IBInspectable var titleTextColour:UIColor = #colorLiteral(red: 0.3019607843, green: 0.3019607843, blue: 0.3019607843, alpha: 1) {
        didSet {
            if !isFirstResponder {
                title.textColor = titleTextColour
            }
        }
    }
    
    @IBInspectable var titleActiveTextColour:UIColor = #colorLiteral(red: 0.3019607843, green: 0.3019607843, blue: 0.3019607843, alpha: 1) {
        didSet {
            if isFirstResponder {
                title.textColor = titleActiveTextColour
            }
        }
    }
    
    // MARK:- Init
    required init?(coder aDecoder:NSCoder) {
        super.init(coder:aDecoder)
        setup()
    }
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    // MARK:- Overrides
    override func layoutSubviews() {
        super.layoutSubviews()
        setTitlePositionForTextAlignment()
        let isResp = isFirstResponder
        if let txt = text , !txt.isEmpty && isResp {
            title.textColor = titleActiveTextColour
        } else {
            title.textColor = titleTextColour
        }
        
        if let txt = text , txt.isEmpty {
            hideTitle(isResp)
        } else {
            showTitle(isResp)
        }
    }
    
    override func textRect(forBounds bounds:CGRect) -> CGRect {
        title.sizeToFit()
        var r = super.textRect(forBounds: bounds)
        if let txt = text , !txt.isEmpty {
            var top = ceil(title.font.lineHeight + hintYPadding)
            top = min(top, maxTopInset())
            r = r.inset(by: UIEdgeInsets(top: top, left: 0.0, bottom: 0.0, right: 0.0))
        }
        return r.integral
    }
    
    override func editingRect(forBounds bounds:CGRect) -> CGRect {
        title.sizeToFit()
        var r = super.editingRect(forBounds: bounds)
        if let txt = text , !txt.isEmpty {
            var top = ceil(title.font.lineHeight + hintYPadding)
            top = min(top, maxTopInset())
            r = r.inset(by: UIEdgeInsets(top: top, left: 0.0, bottom: 0.0, right: 0.0))
        }
        return r.integral
    }
    
    override func clearButtonRect(forBounds bounds:CGRect) -> CGRect {
        title.sizeToFit()
        var r = super.clearButtonRect(forBounds: bounds)
        if let txt = text , !txt.isEmpty {
            var top = ceil(title.font.lineHeight + hintYPadding)
            top = min(top, maxTopInset())
            r = CGRect(x:r.origin.x, y:r.origin.y + (top * 0.5), width:r.size.width, height:r.size.height)
        }
        return r.integral
    }
    
    // MARK:- Public Methods
    func setTitle(title: String, isMandatory: Bool = false) {
        self.font = textfeildFont
        titleLableText = isMandatory ? title + "*" : title
        self.isMandatory = isMandatory
        if isMandatory {
            self.attributedPlaceholder = setAttributedTextPlaceholder(text: titleLableText)
        } else {
            self.title.text = title
            self.attributedPlaceholder = NSAttributedString(string: "title", attributes: [
                .font: R.font.urbanistRegular.callAsFunction(size: 16)!
            ])
            self.placeholder = title
        }
        
    }
    
    private func setAttributedTextPlaceholder(text: String) -> NSAttributedString {
        let fnametext = text
        let boldRange = (fnametext as NSString).range(of: fnametext)
        let fnameAttributedString = NSMutableAttributedString(string: fnametext)
        fnameAttributedString.addAttribute(NSAttributedString.Key.font, value: R.font.urbanistRegular.callAsFunction(size: 16)!, range: boldRange)
        let fnametextRange = (fnametext as NSString).range(of: "*")
        fnameAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red , range: fnametextRange)
        return fnameAttributedString
    }
    
    // MARK:- Private Methods
    fileprivate func setup() {
        borderStyle = .none
        title.alpha = 0.0
        title.font = titleFont
        title.sizeToFit()
        self.addSubview(title)
    }
    
    fileprivate func maxTopInset() -> CGFloat {
        if let fnt = font {
            return max(0, floor(bounds.size.height - fnt.lineHeight - 4.0))
        }
        return 0
    }
    
    fileprivate func setTitlePositionForTextAlignment() {
        let r = textRect(forBounds: bounds)
        var x = r.origin.x
        if textAlignment == NSTextAlignment.center {
            x = r.origin.x + (r.size.width * 0.5) - title.frame.size.width
        } else if textAlignment == NSTextAlignment.right {
            x = r.origin.x + r.size.width - title.frame.size.width
        }
        title.frame = CGRect(x:x, y:title.frame.origin.y, width:title.frame.size.width, height:title.frame.size.height)
    }
    
    fileprivate func showTitle(_ animated:Bool) {
        if isMandatory { title.attributedText = attributedTitle }
        title.sizeToFit()
        let dur = animated ? animationDuration : 0
        UIView.animate(withDuration: dur, delay:0, options: [.beginFromCurrentState, .curveEaseOut], animations: {
            // Animation
            self.title.alpha = 1.0
            var r = self.title.frame
            r.origin.y = self.titleYPadding
            self.title.frame = r
        }, completion:nil)
    }
    
    fileprivate func hideTitle(_ animated:Bool) {
        let dur = animated ? animationDuration : 0
        UIView.animate(withDuration: dur, delay:0, options: [.beginFromCurrentState, .curveEaseIn], animations: {
            // Animation
            self.title.alpha = 0.0
            var r = self.title.frame
            r.origin.y = self.title.font.lineHeight + self.hintYPadding
            self.title.frame = r
        }, completion:nil)
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
