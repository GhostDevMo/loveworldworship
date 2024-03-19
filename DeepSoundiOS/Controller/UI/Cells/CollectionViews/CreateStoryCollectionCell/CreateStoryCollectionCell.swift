//
//  CreateStoryCollectionCell.swift
//  DeepSoundiOS
//
//  Created by iMac on 23/08/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit
import SDWebImage

class CreateStoryCollectionCell: UICollectionViewCell {

    @IBOutlet weak var thumbailImage: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var paidView: UIButton!
    @IBOutlet weak var shapeView: CustomShapeView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.thumbailImage.image = nil
    }

    func bind(_ object: Story) {
        let thumbnailURL = URL.init(string: object.image)
        let indicator = SDWebImageActivityIndicator.medium
        self.thumbailImage.sd_imageIndicator = indicator
        DispatchQueue.global(qos: .userInteractive).async {
            self.thumbailImage.sd_setImage(with: thumbnailURL, placeholderImage:R.image.icn_boy())
        }
        self.shapeView.imageURL = object.user_data.avatar
        self.shapeView.title = object.user_data.name_v
        self.paidView.isHidden = object.paid == 0
    }
}

public final class CustomShapeView: UIView {
    
    public var padding: CGFloat = 2.0
    public var centerButtonHeight: CGFloat = 30.0
    
    public var title: String?
    public var imageURL: String?
    public var image: UIImage?
    
    private var shapeLayer: CALayer?
    
    override public func draw(_ rect: CGRect) {
        self.addShape()
    }
    
    private func setupMiddleButton() {
        let centerButton = UIImageView(frame: CGRect(x: (self.bounds.width / 2)-(30/2), y: -15.0, width: 30.0, height: 30.0))
        centerButton.image = R.image.image.callAsFunction()
        centerButton.layer.cornerRadius = centerButton.frame.size.width / 2.0
        centerButton.layer.borderColor = UIColor.white.cgColor
        centerButton.layer.borderWidth = 2.0
        centerButton.clipsToBounds = true
        //add to the tabbar and add click event
        if let image = imageURL {
            let thumbnailURL = URL.init(string: image)
            DispatchQueue.global(qos: .userInteractive).async {
                centerButton.sd_setImage(with: thumbnailURL, placeholderImage:R.image.icn_boy())
            }
        }else {
            centerButton.image = image
        }
        
        self.addSubview(centerButton)
//        centerButton.addTarget(self, action: #selector(self.centerButtonAction), for: .touchUpInside)
        
        let label = UILabel()
        label.text = title
        label.textColor = .white
        label.font = R.font.urbanistSemiBold.callAsFunction(size: 12.0)
        label.clipsToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        
        label.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5.0).isActive = true
        
        self.clipsToBounds = false
    }
    
    
    private func addShape() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = createPath()
        shapeLayer.strokeColor = UIColor.clear.cgColor
        shapeLayer.fillColor = UIColor.black.withAlphaComponent(0.3).cgColor
        shapeLayer.lineWidth = 0
        shapeLayer.cornerRadius = 10.0
        
        if let oldShapeLayer = self.shapeLayer {
            self.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
            self.layer.insertSublayer(shapeLayer, at: 0)
        }
        self.shapeLayer = shapeLayer
        self.setupMiddleButton()
    }
    
    private func createPath() -> CGPath {
        let f = CGFloat(centerButtonHeight / 2.0) + padding
        let h = frame.height
        let w = frame.width
        let halfW = frame.width/2.0
        let r = CGFloat(10)
        let path = UIBezierPath()
        path.move(to: .zero)
        
        path.addLine(to: CGPoint(x: halfW-f-(r/2.0), y: 0))
        
        path.addQuadCurve(to: CGPoint(x: halfW-f, y: 0), controlPoint: CGPoint(x: halfW-f, y: 0))
        
        path.addArc(withCenter: CGPoint(x: halfW, y: (2.0)), radius: f, startAngle: .pi, endAngle: 0, clockwise: false)
        
        path.addQuadCurve(to: CGPoint(x: halfW+f+(r/2.0), y: 0), controlPoint: CGPoint(x: halfW+f, y: 0))
        
        path.addLine(to: CGPoint(x: w, y: 0))
        path.addLine(to: CGPoint(x: w, y: h))
        path.addLine(to: CGPoint(x: 0.0, y: h))
        
        return path.cgPath
    }
}

