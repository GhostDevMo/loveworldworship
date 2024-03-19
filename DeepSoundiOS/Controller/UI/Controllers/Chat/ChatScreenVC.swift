//
//  ChatScreenVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/21/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Toast_Swift
import Async
import DropDown
import DeepSoundSDK
import SwiftEventBus
import INSPhotoGallery
import IQKeyboardManagerSwift

class ChatScreenVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet var receiverNameLabel: UILabel!
    @IBOutlet var lastSeenLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var menuButton: UIButton!
    @IBOutlet var messageTextfield: EmojiTextField!
    @IBOutlet weak var bottomContant: NSLayoutConstraint!
    
    // MARK: - Properties
    
    var chatList: [GetMessage] = []
    var valueCount: Int = 0
    var userData: Publisher?
    private var messageCount: Int = 0
    private var scrollStatus: Bool = true
    private let moreDropdown = DropDown()
    private let imagePickerController = UIImagePickerController()
    lazy var photos: [INSPhoto] = {
        return []
    }()
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.customizeDropdown()
        self.fetchData()
        log.verbose("To USerId = \(self.userData?.id ?? 0)")
        IQKeyboardManager.shared.enable = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.textFieldClick(_:)))
        self.messageTextfield.addGestureRecognizer(tap)
        // Subscribe to a Notification which will fire before the keyboard will show
        subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShowOrHide(_:)))
        // Subscribe to a Notification which will fire before the keyboard will hide
        subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillShowOrHide(_:)))
        // We make a call to our keyboard handling function as soon as the view is loaded.
        initializeHideKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.dismissPopupBar(animated: true)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_CONNECTED) { result in
            self.fetchData()
        }
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_DIS_CONNECTED) { result in
            log.verbose("Internet dis connected!")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        if popupContentController?.musicObject != nil {
            self.tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true)
        }
        IQKeyboardManager.shared.enable = true
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
                animatedKeyBoard(scrollToBottom: true)
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
        self.messageTextfield.becomeFirstResponder()
    }
    
    @IBAction func stickerButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        isEmoji = true
        self.messageTextfield.becomeFirstResponder()
    }
    
    @IBAction func menuButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.moreDropdown.show()
    }
    
    @IBAction func sendButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.messageTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            self.view.makeToast("Please write somthing.....")
            return
        }
        self.sendMessage()
        self.messageTextfield.text = ""
    }
    
    @IBAction func imageButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.sendMedia()
    }
    
    // MARK: - Helper Functions
    
    private func setupUI() {
        if self.userData?.name == "" {
            self.receiverNameLabel.text = self.userData?.username
        } else {
            self.receiverNameLabel.text = self.userData?.name
        }
        
        let date = Date(timeIntervalSince1970: TimeInterval(self.userData?.last_active ?? 0))
        self.lastSeenLabel.text = date.timeAgoDisplay()//setTimestamp(epochTime: String(self.lastSeenString ?? 0))
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(UINib(resource: R.nib.chatSenderTableItem), forCellReuseIdentifier: R.reuseIdentifier.chatSenderTableItem.identifier)
        self.tableView.register(UINib(resource: R.nib.chatReceiverTableItem), forCellReuseIdentifier: R.reuseIdentifier.chatReceiverTableItem.identifier)
        self.tableView.register(UINib(resource: R.nib.senderImageTableItem), forCellReuseIdentifier: R.reuseIdentifier.senderImageTableItem.identifier)
        self.tableView.register(UINib(resource: R.nib.receiverImageTableItem), forCellReuseIdentifier: R.reuseIdentifier.receiverImageTableItem.identifier)
    }
    
    fileprivate func animatedKeyBoard(scrollToBottom: Bool) {
        UIView.animate(withDuration: 0, delay: 0,options: UIView.AnimationOptions.curveEaseOut) {
            if scrollToBottom {
                self.view.layoutIfNeeded()
            }
        } completion: { (completed) in
            if scrollToBottom {
                if !self.chatList.isEmpty {
                    let indexPath = IndexPath(item: self.chatList.count - 1, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
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
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissMyKeyboard))
        //Add this tap gesture recognizer to the parent view
        view.addGestureRecognizer(tap)
    }
    
    func customizeDropdown() {
        moreDropdown.dataSource = ["Block","Clear chat"]
        moreDropdown.backgroundColor = .white
        moreDropdown.textColor = UIColor.textColor
        moreDropdown.anchorView = self.menuButton
        moreDropdown.width = 150
        moreDropdown.direction = .bottom
        moreDropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            if index == 0 {
                self.blockUser()
            } else if index == 1 {
                self.clearChat()
            }
            print("Index = \(index)")
        }
    }
    
    private func fetchData() {
        var statusValue: Bool? = false
        if Connectivity.isConnectedToNetwork() {
            chatList.removeAll()
            let accessToken = AppInstance.instance.accessToken ?? ""
            let toID = self.userData?.id ?? 0
            Async.background {
                ChatManager.instance.getChatsMessages(AccessToken: accessToken, limit: 10, offset: 0, userID:toID) { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.data ?? [])")
                                for item in (success?.data)!{
                                    if item.apiType == "image"{
                                        if !statusValue!{
                                            if self.photos.count == self.valueCount{
                                                statusValue = true
                                            }else{
                                                self.photos.append(INSPhoto(imageURL: URL(string: item.fullImage ), thumbnailImage: nil))
                                                self.valueCount = self.valueCount + 1
                                            }
                                        }
                                    }
                                }
                                self.chatList = success?.data ?? []
                                self.tableView.reloadData()
                                if self.scrollStatus {
                                    if self.chatList.count == 0{
                                        log.verbose("Will not scroll more")
                                    } else {
                                        self.scrollStatus = false
                                        self.messageCount = self.chatList.count
                                        let indexPath = NSIndexPath(item: ((self.chatList.count) - 1), section: 0)
                                        self.tableView.scrollToRow(at: indexPath as IndexPath, at: UITableView.ScrollPosition.bottom, animated: true)
                                        
                                    }
                                } else {
                                    if self.chatList.count > self.messageCount {
                                        
                                        self.messageCount = self.chatList.count
                                        let indexPath = NSIndexPath(item: ((self.chatList.count) - 1), section: 0)
                                        self.tableView.scrollToRow(at: indexPath as IndexPath, at: UITableView.ScrollPosition.bottom, animated: true)
                                    } else {
                                        log.verbose("Will not scroll more")
                                    }
                                    log.verbose("Will not scroll more")
                                }
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
                }
            }
        } else {
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
    private func sendMedia() {
        let alert = UIAlertController(title: "", message: "Select Source", preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.imagePickerController.delegate = self
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let gallery = UIAlertAction(title: "Gallery", style: .default) { (action) in
            self.imagePickerController.delegate = self
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addAction(camera)
        alert.addAction(gallery)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func sendMessage() {
        let messageHashId = Int(arc4random_uniform(UInt32(100000)))
        let messageText = messageTextfield.text ?? ""
        let toID = self.userData?.id ?? 0
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background {
            ChatManager.instance.sendMessage(AccessToken: accessToken, userID: toID, HashID: messageHashId, newMessage: messageText) { (success, sessionError, error) in
                if success != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            log.debug("success = \(success?.status ?? 0)")
                            // self.view.makeToast(success?. ?? "")
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
            }
        }
    }
    
    private func clearChat() {
        if Connectivity.isConnectedToNetwork() {
            self.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            let toID = self.userData?.id ?? 0
            Async.background {
                ChatManager.instance.deleteChat(AccessToken: accessToken, userID: toID) { (success, sessionError, error) in
                    if success != nil{
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.data ?? "")")
                                self.view.makeToast(success?.data ?? "")
                                self.navigationController?.popViewController(animated: true)
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
                }
            }
        } else {
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
    private func blockUser() {
        if Connectivity.isConnectedToNetwork() {
            self.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            let toID = self.userData?.id ?? 0
            Async.background {
                BlockUsersManager.instance.blockUser(Id: toID, AccessToken: accessToken) { (success, sessionError, error) in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.status ?? 0)")
                                self.navigationController?.popViewController(animated: true)
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
                }
            }
        } else {
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
}

// MARK: TableView Setup
extension ChatScreenVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.chatList.isEmpty {
            return 0
        } else {
            return chatList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.chatList.isEmpty {
            return UITableViewCell()
        } else {
            let object = self.chatList[indexPath.row]
            switch object.apiType {
            case "text":
                switch object.apiPosition {
                case "left":
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.chatSenderTableItem.identifier) as! ChatSenderTableItem
                    cell.selectionStyle = .none
                    cell.bind(object)
                    return cell
                case "right":
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.chatReceiverTableItem.identifier) as! ChatReceiverTableItem
                    cell.selectionStyle = .none
                    cell.bind(object)
                    return cell
                default:
                    return UITableViewCell()
                }
            case "image":
                switch object.apiPosition {
                case "left":
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.senderImageTableItem.identifier) as! SenderImageTableItem
                    cell.selectionStyle = .none
                    cell.delegate = self
                    cell.showBtn.tag = indexPath.row
                    cell.bind(object)
                    return cell
                case "right":
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.receiverImageTableItem.identifier) as! ReceiverImageTableItem
                    cell.selectionStyle = .none
                    cell.delegate = self
                    cell.showBtn.tag = indexPath.row
                    cell.bind(object)
                    return cell
                default:
                    return UITableViewCell()
                }
            default:
                return UITableViewCell()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.chatList.count == 0 {
            log.verbose("Nothing to select")
        } else {
            let object = self.chatList[indexPath.row]
            if object.apiType == "image" {
                if object.apiPosition == "right" {
                    var urlSTR = ""
                    if object.image.contains(find: "https") {
                        urlSTR = object.image
                    } else {
                        urlSTR = "https://demo.deepsoundscript.com/" + object.image
                    }
                    let image = INSPhoto(imageURL: URL(string: urlSTR), thumbnailImage: nil)
                    let galleryPreview = INSPhotosViewController(photos: [image])
                    /*galleryPreview.referenceViewForPhotoWhenDismissingHandler = { [weak self] photo in
                     if let index = self?.photos.firstIndex(where: {$0 === photo}) {
                     let indexPath = IndexPath(item: index, section: 0)
                     return tableView.cellForRow(at: indexPath) as? ReceiverImageTableItem
                     }
                     return nil
                     }*/
                    present(galleryPreview, animated: true, completion: nil)
                } else if object.apiPosition == "left" {
                    // let cell = tableView.cellForRow(at: indexPath) as! SenderImageTableItem
                    var urlSTR = ""
                    if object.image.contains(find: "https") {
                        urlSTR = object.image
                    } else {
                        urlSTR = "https://demo.deepsoundscript.com/" + object.image
                    }
                    let image = INSPhoto(imageURL: URL(string: urlSTR), thumbnailImage: nil)
                    let galleryPreview = INSPhotosViewController(photos: [image])
                    /*galleryPreview.referenceViewForPhotoWhenDismissingHandler = { [weak self] photo in
                     if let index = self?.photos.firstIndex(where: {$0 === photo}) {
                     let indexPath = IndexPath(item: index, section: 0)
                     return tableView.cellForRow(at: indexPath) as? SenderImageTableItem
                     }
                     return nil
                     }*/
                    present(galleryPreview, animated: true, completion: nil)
                }
            }
        }
    }
}

extension ChatScreenVC: ChatImageShowDelegate {
    
    func showImageBtn(_ sender: UIButton, imageView: UIImageView) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        self.tableView(self.tableView, didSelectRowAt: indexPath)
    }
    
}

extension  ChatScreenVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let convertedImageData = image.jpegData(compressionQuality: 0.2)
        self.sendMedia(ImageData: convertedImageData!)
        self.dismiss(animated: true, completion: nil)
    }
    
    private func sendMedia(ImageData: Data) {
        let mediaHashId = Int(arc4random_uniform(UInt32(100000)))
        let toID = self.userData?.id ?? 0
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background {
            ChatManager.instance.sendMedia(AccesToken: accessToken, userID: toID, mediaData: ImageData,HashID:mediaHashId) { (success, sessionError, error) in
                if success != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.messageID ?? 0)")
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
            }
        }
    }
}

var isEmoji = false

class EmojiTextField: UITextField {
    
    // required for iOS 13
    override var textInputContextIdentifier: String? { "" } // return non-nil to show the Emoji keyboard ¯\_(ツ)_/¯
    
    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if isEmoji {
                if mode.primaryLanguage == "emoji" {
                    return mode
                }
            } else {
                return mode
            }
        }
        return nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    func commonInit() {
        NotificationCenter.default.addObserver(self, selector: #selector(inputModeDidChange), name: UITextInputMode.currentInputModeDidChangeNotification, object: nil)
    }
    
    @objc func inputModeDidChange(_ notification: Notification) {
        guard isFirstResponder else {
            return
        }
        DispatchQueue.main.async { [weak self] in
            self?.reloadInputViews()
        }
    }
    
}
