//
//  ArticleSectionFiveTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 7/29/21.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK

class ArticleSectionFiveTableItem: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    var isLike = false
    var object: BlogComment?
    var successHandler:(() -> Void)?
    var delegate: ArticleSectionDelegate?
    var parentVC: ArticlesDetailsVC?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        self.addGestureRecognizer(longPressRecognizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // TableView longPressed Click
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            if let object = self.object {
                log.debug("UILongPressGestureRecognizer : ------ \(object.id ?? 0)")
                self.parentVC?.commentPopupAction(object, commentText: self.titleLabel.text ?? "")
            }
        }
    }
    
    func bind(_ object: BlogComment) {
        self.object = object
        self.usernameLabel.text = object.userData?.username
        self.titleLabel.text = object.value ?? ""
        let url = URL.init(string:object.userData?.avatar ?? "")
        profileImage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
        self.isLike = object.isLikedComment ?? false
        let newImage = self.isLike ? R.image.icn_cmt_fill() : R.image.icn_cmt_unfill()
        self.button.setImage(newImage, for: .normal)
    }
    
    @IBAction func likeBtnAction(_ sender: UIButton) {
        self.isLike = !self.isLike
        self.animateButton()
        self.addLikeOrUnlikeAPI()
    }
    
    // ⬇︎⬇︎⬇︎ animation happens here ⬇︎⬇︎⬇︎
    func animateButton() {
        button.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.5, delay: 0,
                       options: .allowUserInteraction) {
            let newImage = self.isLike ? R.image.icn_cmt_fill() : R.image.icn_cmt_unfill()
            self.button.setImage(newImage, for: .normal)
            self.button.transform = .identity
        }
    }
}

//MARK: - API Services -
extension ArticleSectionFiveTableItem {
    private func addLikeOrUnlikeAPI(){
        if Connectivity.isConnectedToNetwork() {
            let id = self.object?.id ?? 0
            Async.background({
                ArticlesManager.instance.addLikeOrUnlikeComment(id: id, like: self.isLike) { (success, sessionError, error) in
                    if success != nil {
                        Async.main({
                            appDelegate.window?.rootViewController?.view.makeToast(success, duration: 0.25)
                            log.debug("Success = \(success ?? "")")
                            self.successHandler?()
                        })
                    }else if sessionError != nil {
                        Async.main({
                            appDelegate.window?.rootViewController?.view.makeToast(sessionError)
                            log.error("sessionError = \(sessionError ?? "")")
                        })
                    }else {
                        Async.main({
                            appDelegate.window?.rootViewController?.view.makeToast(error?.localizedDescription)
                            log.error("error = \(error?.localizedDescription ?? "")")
                        })
                    }
                }
            })
        }else{
            log.error("internetError = \(InterNetError)")
            appDelegate.window?.rootViewController?.view.makeToast(InterNetError)
        }
    }
}
