//
//  CommentsVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 18/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import SwiftEventBus
import DeepSoundSDK
import EmptyDataSet_Swift
import IQKeyboardManagerSwift
import Toast_Swift

class CommentsVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var commentTF: EmojiTextField!
    @IBOutlet weak var bottomContant: NSLayoutConstraint!
    
    // MARK: - Properties
    
    private var commentsArray = [Comment]()
    private var fetchSatus = true
    var trackId: Int = 0
    var trackIdString: String = ""
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTF.becomeFirstResponder()
        self.setupUI()
        self.fetchComments()
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER) { result in
            log.verbose("To dismiss the popover")
            self.tabBarController?.dismissPopupBar(animated: true, completion: nil)
        }
        
        SwiftEventBus.onMainThread(self, name: "PlayerReload") { result in
            let stringValue = result?.object as? String
            self.view.makeToast(stringValue)
            log.verbose(stringValue ?? "")
        }
        
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_COMMENT_DATA_FETCH) { result in
            self.fetchComments()
        }
        
        //Internet connectivity event subscription
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_DIS_CONNECTED) { result in
            self.view.makeToast(InterNetError)
        }
        
        IQKeyboardManager.shared.enable = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.textFieldClick(_:)))
        self.commentTF.addGestureRecognizer(tap)
        
        //Subscribe to a Notification which will fire before the keyboard will show
        subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShowOrHide(_:)))
        
        //Subscribe to a Notification which will fire before the keyboard will hide
        subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillShowOrHide(_:)))
        
        //We make a call to our keyboard handling function as soon as the view is loaded.
        initializeHideKeyboard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        IQKeyboardManager.shared.enable = true
        unsubscribeFromAllNotifications()
    }
    
    // MARK: - Selectors
    
    @objc func dismissMyKeyboard() {
        //endEditing causes the view (or one of its embedded text fields) to resign the first responder status.
        //In short- Dismiss the active keyboard.
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShowOrHide(_ notification: NSNotification) {
        // Get required info out of the notification
        if let userInfo = notification.userInfo, let endValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey], let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey], let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] {
            // Transform the keyboard's frame into our view's coordinate system
            let endRect = view.convert((endValue as AnyObject).cgRectValue, from: view.window)
            if notification.name == UIResponder.keyboardWillShowNotification {
                self.bottomContant.constant = endRect.size.height-34.0
            } else {
                self.bottomContant.constant = 0
            }
            let duration = (durationValue as AnyObject).doubleValue
            let options = UIView.AnimationOptions(rawValue: UInt((curveValue as AnyObject).integerValue << 16))
            UIView.animate(withDuration: duration!, delay: 0, options: options, animations: {
                self.view.layoutIfNeeded()
                self.view.updateConstraints()
            }, completion: nil)
        }
    }
    
    @objc func textFieldClick(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
        isEmoji = false
        self.commentTF.becomeFirstResponder()
    }
    
    @IBAction func stickerButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        isEmoji = true
        self.commentTF.becomeFirstResponder()
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if self.commentTF.text?.trimmingCharacters(in: .whitespaces).count == 0 {
            self.view.makeToast("Please write somthing")
            return
        }
        self.sendComment()
        self.commentTF.text = nil
    }
    
    // MARK: - Helper Functions
    
    private func setupUI() {
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib(resource: R.nib.comments_TableCell), forCellReuseIdentifier: R.reuseIdentifier.comments_TableCell.identifier)
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.addPullToRefresh {
            self.commentsArray.removeAll()
            self.tableView.reloadData()
            self.fetchComments()
        }
    }
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func initializeHideKeyboard() {
        //Declare a Tap Gesture Recognizer which will trigger our dismissMyKeyboard() function
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissMyKeyboard))
        //Add this tap gesture recognizer to the parent view
        view.addGestureRecognizer(tap)
    }
    
    private func fetchComments() {
        if Connectivity.isConnectedToNetwork() {
            self.commentsArray.removeAll()
            if fetchSatus {
                fetchSatus = false
                self.showProgressDialog(text: "Loading...")
            } else {
                log.verbose("will not show Hud more...")
            }
            let accessToken = AppInstance.instance.accessToken ?? ""
            let trackId = self.trackId
            Async.background {
                CommentManager.instance.getComments(TrackId: trackId, AccessToken: accessToken, Limit: 20, Offset: 0, completionBlock: { (success, sessionError, error) in
                    Async.main {
                        self.tableView.stopPullToRefresh()
                    }
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.data?.data ?? [])")
                                self.commentsArray = success?.data?.data ?? []
                                self.tableView.reloadData()
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast(sessionError?.error ?? "")
                                log.error("sessionError = \(sessionError?.error ?? "")")
                            }
                        }
                    } else {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast(error?.localizedDescription ?? "")
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        }
                    }
                })
            }
        } else {
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
    private func sendComment() {
        if Connectivity.isConnectedToNetwork() {
            log.verbose("trackIdString - \(trackId)")
            let accessToken = AppInstance.instance.accessToken ?? ""
            let trackId = self.trackIdString
            let commentString = self.commentTF.text ?? ""
            let timePercentage = 24
            Async.background {
                CommentManager.instance.postComment(TrackId: trackId, AccessToken: accessToken, TimePercentage: timePercentage, Value: commentString, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                self.dismissKeyboard()
                                SwiftEventBus.post(EventBusConstants.EventBusConstantsUtils.EVENT_COMMENT_DATA_FETCH)
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast(sessionError?.error ?? "")
                                log.error("sessionError = \(sessionError?.error ?? "")")
                            }
                        }
                    } else {
                        Async.main {
                            self.dismissProgressDialog {
                                self.view.makeToast(error?.localizedDescription ?? "")
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        }
                    }
                })
            }
        } else {
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
}

// MARK: - Extensions

// MARK: TableView Setup
extension CommentsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.commentsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.comments_TableCell.identifier) as! Comments_TableCell
        cell.selectionStyle = .none
        let object = self.commentsArray[indexPath.row]
        cell.likeDislikeCommentDelegate = self
        cell.commentDelegate = self
        cell.indexPath = indexPath.row
        cell.messegeTextView.text = object.value
        cell.likeCount.text = "\(object.countLiked)"
        let url = URL.init(string: object.userData?.avatar ?? "")
        cell.profileImage.sd_setImage(with: url, placeholderImage:R.image.imagePlacholder())
        if object.isLikedComment {
            cell.likeBtn.setImage(R.image.ic_redHeart(), for: .normal)
        } else {
            cell.likeBtn.setImage(R.image.ic_outlineHeart(), for: .normal)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

// MARK: likeDislikeCommentDelegate
extension CommentsVC: likeDislikeCommentDelegate {
    
    func likeDisLikeComment(_ sender: UIButton, indexPath: Int) {
        let object = self.commentsArray[indexPath]
        if object.isLikedComment {
            self.disLikeComment(commentId: object.id ?? 0, button: sender)
            self.commentsArray[indexPath].countLiked -= 1
        } else {
            self.likeComment(commentId: object.id ?? 0, button: sender)
            self.commentsArray[indexPath].countLiked += 1
        }
        self.commentsArray[indexPath].isLikedComment = !(self.commentsArray[indexPath].isLikedComment)
        self.tableView.reloadData()
    }
    
    func likeDisLikeComment(status: Bool, button: UIButton, commentId: Int) {
        if status {
            button.setImage(R.image.ic_outlineHeart(), for: .normal)
            self.disLikeComment(commentId: commentId, button: button)
        } else {
            button.setImage(R.image.ic_redHeart(), for: .normal)
            self.likeComment(commentId: commentId, button: button)
        }
    }
    
    private func likeComment(commentId: Int, button: UIButton) {
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
            let idComment = commentId
            Async.background {
                CommentManager.instance.likeComment(CommentId: idComment, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("success = \(success ?? false)")
                                // button.setImage(R.image.ic_redHeart(), for: .normal)
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError ?? false)")
                                self.view.makeToast("sessionError")
                            }
                        }
                    } else {
                        Async.main {
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.view.makeToast(error?.localizedDescription ?? "")
                            }
                        }
                    }
                })
            }
        } else {
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
    private func disLikeComment(commentId: Int, button: UIButton) {
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
            let idComment = commentId
            Async.background {
                CommentManager.instance.disLikeComment(CommentId: idComment, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                                // button.setImage(R.image.ic_outlineHeart(), for: .normal)
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.error ?? "")")
                                self.view.makeToast(sessionError?.error ?? "")
                            }
                        }
                    } else {
                        Async.main {
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.view.makeToast(error?.localizedDescription ?? "")
                            }
                        }
                    }
                })
            }
        } else {
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
}

// MARK: commentProfileDelegate
extension CommentsVC: commentProfileDelegate {
    
    func commentProfile(index: Int, status: Bool) {
        if status{
            self.view.endEditing(true)
            let vc = R.storyboard.dashboard.showProfile2VC()
            vc?.userID  = self.commentsArray[index].userData?.id ?? 0
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
}

// MARK: EmptyDataSetSource, EmptyDataSetDelegate
extension CommentsVC: EmptyDataSetSource, EmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No Comments Yet", attributes: [NSAttributedString.Key.font : R.font.urbanistBold(size: 24) ?? UIFont.boldSystemFont(ofSize: 24), .foregroundColor : UIColor.textColor])
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Get the conversation started by leaving the first comment.", attributes: [NSAttributedString.Key.font : R.font.urbanistMedium(size: 14) ?? UIFont.systemFont(ofSize: 14)])
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        let width = UIScreen.main.bounds.width - 100
        return R.image.emptyData()?.resizeImage(targetSize: CGSize(width: width, height: width))
    }
    
}
