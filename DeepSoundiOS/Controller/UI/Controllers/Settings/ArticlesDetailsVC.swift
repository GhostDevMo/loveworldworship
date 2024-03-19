//
//  ArticlesDetailsVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/10/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
import IQKeyboardManagerSwift

class ArticlesDetailsVC: BaseVC {
    
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var messageTextfield: EmojiTextField!
    @IBOutlet weak var bottomContant: NSLayoutConstraint!
    
    var object:Blog? = nil
    var articlesCommentsArray = [BlogComment]()
    var selectedComment: BlogComment?
    var selectedCommentText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.getArticleComments()
        self.messageTextfield.delegate = self
        IQKeyboardManager.shared.enable = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.textFieldClick(_:)))
        self.messageTextfield.addGestureRecognizer(tap)
        
        //Subscribe to a Notification which will fire before the keyboard will show
        subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShowOrHide(_:)))
        
        //Subscribe to a Notification which will fire before the keyboard will hide
        subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillShowOrHide(_:)))
        
        //We make a call to our keyboard handling function as soon as the view is loaded.
        initializeHideKeyboard()
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
        unsubscribeFromAllNotifications()
    }
    
    //MARK: - Actions
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
            }else {
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
        self.messageTextfield.becomeFirstResponder()
    }
    
    @IBAction func stickerButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        isEmoji = true
        self.messageTextfield.becomeFirstResponder()
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.messageTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            self.view.makeToast("Please write somthing.....")
            return
        }
        self.createArticleComments()
        self.messageTextfield.text = nil
    }
    
    private func setupUI() {
        self.lblHeader.text = self.object?.title ?? ""
        self.tableView.separatorStyle = .none
        tableView.register(UINib(resource: R.nib.articlesSectionOneTableItem), forCellReuseIdentifier: R.reuseIdentifier.articlesSectionOneTableItem.identifier)
        tableView.register(UINib(resource: R.nib.articlesSectionTwoTableItem), forCellReuseIdentifier: R.reuseIdentifier.articlesSectionTwoTableItem.identifier)
        tableView.register(UINib(resource: R.nib.articleSectionThreeTableItem), forCellReuseIdentifier: R.reuseIdentifier.articleSectionThreeTableItem.identifier)
        tableView.register(UINib(resource: R.nib.articlesSectionFourTableItem), forCellReuseIdentifier: R.reuseIdentifier.articlesSectionFourTableItem.identifier)
        tableView.register(UINib(resource: R.nib.articleSectionFiveTableItem), forCellReuseIdentifier: R.reuseIdentifier.articleSectionFiveTableItem.identifier)
    }
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func initializeHideKeyboard(){
        //Declare a Tap Gesture Recognizer which will trigger our dismissMyKeyboard() function
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissMyKeyboard))
        //Add this tap gesture recognizer to the parent view
        view.addGestureRecognizer(tap)
    }
    
    private func getArticleComments(){
        if Connectivity.isConnectedToNetwork() {
            let accessToken = AppInstance.instance.accessToken ?? ""
            let id = object?.id ?? "0"
            Async.background({
                ArticlesManager.instance.getArticlesComments(AccessToken: accessToken, id: Int(id)!, limit: 20, offset: 0) { (success, sessionError, error) in
                    if success != nil {
                        Async.main({
                            self.dismissProgressDialog {
                                self.articlesCommentsArray = success?.data ?? []
                                log.debug("userList = \(success?.data ?? [])")
                                self.tableView.reloadData()
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(sessionError?.error ?? "")
                                log.error("sessionError = \(sessionError?.error ?? "")")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(error?.localizedDescription ?? "")
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        })
                    }
                }
            })
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
    private func createArticleComments(){
        if Connectivity.isConnectedToNetwork(){
            self.articlesCommentsArray.removeAll()
            self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
            let accessToken = AppInstance.instance.accessToken ?? ""
            let id = object?.id ?? "0"
            let text = self.messageTextfield.text ?? ""
            
            Async.background({
                ArticlesManager.instance.createArticleComment(AccessToken: accessToken, id: Int(id)!, text: text) { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                self.messageTextfield.text = ""
                                self.getArticleComments()
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(sessionError?.error ?? "")
                                log.error("sessionError = \(sessionError?.error ?? "")")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(error?.localizedDescription ?? "")
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        })
                    }
                }
            })
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
}
extension ArticlesDetailsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 1
        case 3:
            return 1
        case 4:
            return self.articlesCommentsArray.count
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.articlesSectionOneTableItem.identifier, for: indexPath) as! ArticlesSectionOneTableItem
            cell.selectionStyle = .none
            if let object = self.object {
                cell.bind(object)
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.articlesSectionTwoTableItem.identifier, for: indexPath) as! ArticlesSectionTwoTableItem
            cell.selectionStyle = .none
            if let object = self.object {
                cell.bind(object)
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.articleSectionThreeTableItem.identifier, for: indexPath) as! ArticleSectionThreeTableItem
            cell.selectionStyle = .none
            if let object = self.object {
                cell.bind(object)
            }
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.articlesSectionFourTableItem.identifier, for: indexPath) as! ArticlesSectionFourTableItem
            cell.delegate = self
            cell.selectionStyle = .none
            cell.bind(self.object?.view ?? "")
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.articleSectionFiveTableItem.identifier, for: indexPath) as! ArticleSectionFiveTableItem
            cell.parentVC = self
            cell.selectionStyle = .none
            let object = self.articlesCommentsArray[indexPath.row]
            cell.successHandler = {
                self.getArticleComments()
            }
            cell.bind(object)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension ArticlesDetailsVC: ArticleSectionDelegate {
    func commentPopupAction(_ object: BlogComment, commentText: String) {
        self.view.endEditing(true)
        self.selectedComment = object
        self.selectedCommentText = commentText
        let isCurrentUser = object.userID == AppInstance.instance.userId
        guard let newVC = R.storyboard.popups.articalPopupVC() else { return }
        newVC.delegate = self
        newVC.isComment = true
        newVC.isDelete = isCurrentUser
        newVC.isReported = object.is_reported
        self.present(newVC, animated: true)
    }
    
    func moreBtnAction(_ sender: UIButton) {
        self.selectedComment = nil
        self.selectedCommentText = nil
        self.view.endEditing(true)
        guard let newVC = R.storyboard.popups.articalPopupVC() else { return }
        newVC.delegate = self
        self.present(newVC, animated: true)
    }
}

extension ArticlesDetailsVC: ArticalPopupDelegate, ReportCommentPopupDelegate {
    func dismissView(_ success: Bool, reportSTR: String) {
        IQKeyboardManager.shared.enable = false
        //Subscribe to a Notification which will fire before the keyboard will show
        subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShowOrHide(_:)))
        //Subscribe to a Notification which will fire before the keyboard will hide
        subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillShowOrHide(_:)))
        //We make a call to our keyboard handling function as soon as the view is loaded.
        initializeHideKeyboard()
        if success {
            self.reportCommentAPI(text: reportSTR)
        }
    }
    
    func reportCommentAPI(text: String) {
        if Connectivity.isConnectedToNetwork() {
            self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
            let id = self.selectedComment?.id ?? 0
            Async.background({
                CommentManager.instance.reportCommentAPI(id: id,
                                                         text: text) { success, sessionError, error in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(success)
                                log.debug("success = \(success ?? "")")
                                self.getArticleComments()
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(sessionError ?? "")
                                log.error("sessionError = \(sessionError ?? "")")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(error?.localizedDescription ?? "")
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        })
                    }
                }
            })
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
    func unreportCommentAPI() {
        if Connectivity.isConnectedToNetwork() {
            self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
            let id = self.selectedComment?.id ?? 0
            Async.background({
                CommentManager.instance.unreportCommentAPI(id: id) { success, sessionError, error in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(success)
                                log.debug("success = \(success ?? "")")
                                self.getArticleComments()
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(sessionError ?? "")
                                log.error("sessionError = \(sessionError ?? "")")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(error?.localizedDescription ?? "")
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        })
                    }
                }
            })
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
    func reportBtnAction(_ sender: UIButton) {
        if sender.currentTitle == "Report" {
            self.view.endEditing(true)
            IQKeyboardManager.shared.enable = true
            unsubscribeFromAllNotifications()
            guard let newVC = R.storyboard.popups.reportCommentPopupVC() else { return }
            newVC.delegate = self
            self.present(newVC, animated: true)
        }else {
            self.unreportCommentAPI()
        }
    }
    
    func copyBtnAction(_ sender: UIButton, isLink: Bool) {
        if isLink {
            UIPasteboard.general.string = object?.url
            self.view.makeToast("Link Copied Successfully!.")
        } else {
            UIPasteboard.general.string = self.selectedCommentText
            self.view.makeToast("Comment Copied Successfully!.")
        }
    }
    
    func shareBtnAction(_ sender: UIButton) {
        let someText:String = object?.url ?? ""
        let objectsToShare:URL = URL(string: someText)!
        let sharedObjects:[AnyObject] = [objectsToShare as AnyObject,someText as AnyObject]
        let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook,UIActivity.ActivityType.postToTwitter,UIActivity.ActivityType.mail,UIActivity.ActivityType.postToTencentWeibo]
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func deleteBtnAction(_ sender: UIButton) {
        if Connectivity.isConnectedToNetwork() {
            self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
            let id = self.selectedComment?.id ?? 0
            Async.background({
                ArticlesManager.instance.deleteCommentAPI(id: id) { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(success)
                                log.debug("success = \(success ?? "")")
                                self.getArticleComments()
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(sessionError ?? "")
                                log.error("sessionError = \(sessionError ?? "")")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(error?.localizedDescription ?? "")
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        })
                    }
                }
            })
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
}

extension ArticlesDetailsVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
