//
//  UIViewExtension.swift
//  ScanQR
//
//  Created by Dev. Mohmd on 8/6/20.
//  Copyright © 2020 Dev. Mohmd. All rights reserved.
//

import Foundation
import UIKit

extension UIView: Reusable {
    
    var safeAreaBottom: CGFloat {
        if #available(iOS 11, *) {
            if let window = UIApplication.shared.keyWindowInConnectedScenes {
                return window.safeAreaInsets.bottom
            }
        }
        return 0
    }
    
    var safeAreaTop: CGFloat {
        if #available(iOS 11, *) {
            if let window = UIApplication.shared.keyWindowInConnectedScenes {
                return window.safeAreaInsets.top
            }
        }
        return 0
    }
    
    var safeAreaHeight: CGFloat {
        if #available(iOS 11, *) {
            return self.height - safeAreaTop - safeAreaBottom
        }
        return bounds.height
    }
    
    var width: CGFloat {
        return self.frame.size.width
    }
    
    var height: CGFloat {
        return self.frame.size.height
    }
    
    var top: CGFloat {
        return self.frame.origin.y
    }
    
    var bottom: CGFloat {
        return self.frame.origin.y + self.height
    }
    
    var left: CGFloat {
        return self.frame.origin.x
    }
    
    var right: CGFloat {
        return self.frame.origin.x + self.width
    }
    
    var origin: CGPoint {
        return self.frame.origin
    }
    
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    // MARK: - FUNCTIONS ...
    
    @objc func imageWasSaved(_ image: UIImage, error: Error?, context: UnsafeMutableRawPointer) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        print("Image was saved in the photo gallery")
        
        /// To open photos app after take the shot ...
//        UIApplication.shared.open(URL(string:"photos-redirect://")!)
    }

    public func createDottedLine(width: CGFloat, color: UIColor) {
        
        let caShapeLayer = CAShapeLayer()
        caShapeLayer.strokeColor = color.cgColor
        caShapeLayer.lineWidth = width
        caShapeLayer.lineDashPattern = [2,5]
        let cgPath = CGMutablePath()
        let cgPoint = [CGPoint(x: 0, y: 0), CGPoint(x: self.frame.width, y: 0)]
        cgPath.addLines(between: cgPoint)
        caShapeLayer.path = cgPath
        layer.addSublayer(caShapeLayer)
    }
    
    public func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        
        if #available(iOS 11, *) {
            var cornerMask = CACornerMask()
            if(corners.contains(.topLeft)){
                cornerMask.insert(.layerMinXMinYCorner)
            }
            if(corners.contains(.topRight)){
                cornerMask.insert(.layerMaxXMinYCorner)
            }
            if(corners.contains(.bottomLeft)){
                cornerMask.insert(.layerMinXMaxYCorner)
            }
            if(corners.contains(.bottomRight)){
                cornerMask.insert(.layerMaxXMaxYCorner)
            }
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = cornerMask
            
        } else {
            let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }
}

extension UIView {
    
    func addWhatsAppStatusDottedBorder(color: UIColor, storyCount: Int) {
        let dashedBorder = CAShapeLayer()
        dashedBorder.strokeColor = color.cgColor
        dashedBorder.fillColor = nil
        dashedBorder.lineWidth = 4.0
        let dashLength: CGFloat = 10.0
        let gapLength: CGFloat = 5.0
        let totalLength = (dashLength + gapLength) * CGFloat(storyCount)
        dashedBorder.lineDashPattern = [dashLength as NSNumber, gapLength as NSNumber]
        let borderPath = UIBezierPath(roundedRect: bounds, cornerRadius: (bounds.height / 2)).cgPath
        dashedBorder.path = borderPath
        layer.addSublayer(dashedBorder)
    }
    
}

extension UIView {
    
    func addSubViewWithAutolayout(subView: UIView) {
        addSubview(subView)
        subView.translatesAutoresizingMaskIntoConstraints = false
        subView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        subView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        subView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        subView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        subView.layoutIfNeeded()
        self.layoutIfNeeded()
    }
    
}

func takeSnapshotOfView(view: UIView) -> UIImage {
    let screenSize = UIScreen.main.bounds.size
    let scale = UIScreen.main.scale
    let format = UIGraphicsImageRendererFormat.default()
    format.scale = scale
    return UIGraphicsImageRenderer(size: screenSize, format: format).image { _ in
        view.drawHierarchy(in: UIScreen.main.bounds, afterScreenUpdates: true)
    }
}
