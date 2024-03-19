//
//  Extension+UIView.swift
//  Urban Clap
//
//  Created by JPLoft_2 on 05/10/21.
//

import Foundation
import UIKit


//MARK: - Add Shadow to view

extension UIView {

    func addShadow(offset: CGSize = .zero, color: UIColor = .gray, radius: CGFloat = 2.0, opacity: Float = 0.50) {
        
        layer.masksToBounds = false
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.cornerRadius = self.cornerRadiusV

        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor = nil
        layer.backgroundColor =  backgroundCGColor
        
    }
}


//MARK: - Set Corner Radius to view

extension UIView{
    
    func setCornerRadiusWithBorder(cornerRadius:CGFloat = 10, clipsToBound:Bool = true, borderWidth:CGFloat = 0.0, borderColor:CGColor? = UIColor.clear.cgColor){
        
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = clipsToBound
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor ?? UIColor().cgColor
        
    }
    
}



//MARK: - UIView Hide/Show Animation

extension UIView {
    
    func fadeIn(backView:UIView?, duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in }) {
        self.alpha = 0.0
        
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            backView?.isHidden = false
            self.isHidden = false
            self.alpha = 1.0
        }, completion: completion)
    }
    
    func fadeOut(backView:UIView?, duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in }) {
        self.alpha = 1.0
        
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.alpha = 0.0
            backView?.isHidden = true
        }) { (completed) in
            self.isHidden = true
            completion(true)
        }
    }
    
}
