//
//  ChatScreenVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/21/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit


import Async
import DropDown
import FittedSheets
import DeepSoundSDK
import SwiftEventBus
import INSPhotoGallery

class ChatScreenVC: BaseVC {
    
    @IBOutlet weak var videoBtn: UIButton!
    @IBOutlet weak var audioBtn: UIButton!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var receiverNameLabel: UILabel!
    @IBOutlet var lastSeenLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var menuButton: UIButton!
    @IBOutlet var inputMessageView: UIView!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var imageButton: UIButton!
    @IBOutlet var emoButton: UIButton!
    @IBOutlet var giftButton: UIButton!
    @IBOutlet var stickerButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    
    var chatList: [GetChatMessagesModel.Datum] = []
    var valueCount:Int? = 0
    var toUserId:Int? = 0
    var usernameString:String? = ""
    var lastSeenString:Int? =  0
    var lastSeen:String? = ""
    var profileImageString:String? = ""
    private var messageCount:Int? = 0
    private var scrollStatus:Bool? = true
    private let moreDropdown = DropDown()
    private let imagePickerController = UIImagePickerController()
    
    lazy var photos: [INSPhoto] = {
        return []
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.sendButton.backgroundColor = .ButtonColor
        self.sendBtn.backgroundColor = .ButtonColor
        self.customizeDropdown()
        self.fetchData()
        log.verbose("To USerId = \(self.toUserId ?? 0)")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_CONNECTED) { result in
            self.fetchData()
            
        }
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_DIS_CONNECTED) { result in
            log.verbose("Internet dis connected!")
        }
        
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = false
        
    }
    
    
    
    
    //MARK: - Methods
    
    private func setupUI(){
        
        self.receiverNameLabel.text = self.usernameString ?? ""
        self.lastSeenLabel.text = setTimestamp(epochTime: String(self.lastSeenString ?? 0))
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register( ChatSenderTableItem.nib, forCellReuseIdentifier: ChatSenderTableItem.identifier)
        self.tableView.register( ChatReceiverTableItem.nib, forCellReuseIdentifier: ChatReceiverTableItem.identifier)
        self.tableView.register( SenderImageTableItem.nib, forCellReuseIdentifier: SenderImageTableItem.identifier)
        self.tableView.register( ReceiverImageTableItem.nib, forCellReuseIdentifier: ReceiverImageTableItem.identifier)
    }
    func customizeDropdown(){
        moreDropdown.dataSource = ["Block","Clear chat"]
        moreDropdown.backgroundColor = UIColor.hexStringToUIColor(hex: "454345")
        moreDropdown.textColor = UIColor.white
        moreDropdown.anchorView = self.menuButton
        //        moreDropdown.bottomOffset = CGPoint(x: 312, y:-270)
        moreDropdown.width = 200
        moreDropdown.direction = .any
        moreDropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            if index == 0{
                self.blockUser()
                
            }else if index == 1{
                self.clearChat()
            }
            
            print("Index = \(index)")
        }
        
    }
    private func getDate(unixdate: Int, timezone: String) -> String {
               if unixdate == 0 {return ""}
               let date = NSDate(timeIntervalSince1970: TimeInterval(unixdate))
               let dayTimePeriodFormatter = DateFormatter()
               dayTimePeriodFormatter.dateFormat = "h:mm"
               dayTimePeriodFormatter.timeZone = .current
               let dateString = dayTimePeriodFormatter.string(from: date as Date)
               return "\(dateString)"
           }
    
    private func fetchData(){
        var statusValue:Bool? = false
        if Connectivity.isConnectedToNetwork(){
            chatList.removeAll()
            let accessToken = AppInstance.instance.accessToken ?? ""
            let toID = self.toUserId ?? 0
            Async.background({
                ChatManager.instance.getChatsMessages(AccessToken: accessToken, limit: 10, offset: 0, userID:toID) { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                log.debug("userList = \(success?.data ?? [])")
                                for item in (success?.data)!{
                                    if item.apiType == "image"{
                                        if !statusValue!{
                                            if self.photos.count == self.valueCount{
                                                statusValue = true
                                            }else{
                                                self.photos.append(INSPhoto(imageURL: URL(string: item.fullImage ?? ""), thumbnailImage: nil))
                                                                                          self.valueCount = self.valueCount! + 1
                                            }
                                          
                                        }else {
                                            
                                        }
                                        
                                    }
                                }
                                //                                for item in stride(from: (success?.data!.count)!, through: -1, by: -1){
                                //                                    self.chatList.append((success?.data![item])!)
                                //                                }
                                
                                self.chatList = success?.data ?? []
                                self.tableView.reloadData()
                                if self.scrollStatus!{
                                    
                                    if self.chatList.count == 0{
                                        log.verbose("Will not scroll more")
                                    }else{
                                        self.scrollStatus = false
                                        self.messageCount = self.chatList.count ?? 0
                                        let indexPath = NSIndexPath(item: ((self.chatList.count) - 1), section: 0)
                                        self.tableView.scrollToRow(at: indexPath as IndexPath, at: UITableView.ScrollPosition.bottom, animated: true)
                                        
                                    }
                                }else{
                                    if self.chatList.count > self.messageCount!{
                                        
                                        self.messageCount = self.chatList.count ?? 0
                                        let indexPath = NSIndexPath(item: ((self.chatList.count) - 1), section: 0)
                                        self.tableView.scrollToRow(at: indexPath as IndexPath, at: UITableView.ScrollPosition.bottom, animated: true)
                                    }else{
                                        log.verbose("Will not scroll more")
                                    }
                                    log.verbose("Will not scroll more")
                                }
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
    private func sendMessage(){
        let messageHashId = Int(arc4random_uniform(UInt32(100000)))
        let messageText = messageTextfield.text ?? ""
        let toID = self.toUserId ??  0
        let accessToken = AppInstance.instance.accessToken ?? ""
        
        Async.background({
            ChatManager.instance.sendMessage(AccessToken: accessToken, userID: toID, HashID: messageHashId, newMessage: messageText) { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            
                            log.debug("success = \(success?.status ?? 0)")
                            //                                                self.view.makeToast(success?. ?? "")
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
    }
    //
    //
    
    private func clearChat(){
        if Connectivity.isConnectedToNetwork(){
            
            self.showProgressDialog(text: "Loading...")
            let accessToken = AppInstance.instance.accessToken ?? ""
            let toID = self.toUserId  ?? 0
            
            Async.background({
                ChatManager.instance.deleteChat(AccessToken: accessToken, userID: toID) { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                log.debug("userList = \(success?.data ?? "")")
                                self.view.makeToast(success?.data ?? "")
                                self.navigationController?.popViewController(animated: true)
                                
                                
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
    private func blockUser(){
        if Connectivity.isConnectedToNetwork(){
            
            self.showProgressDialog(text: "Loading...")
            
            let accessToken = AppInstance.instance.accessToken ?? ""
            let toID = self.toUserId ?? 0
            
            Async.background({
                BlockUsersManager.instance.blockUser(Id: toID, AccessToken: accessToken) { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                log.debug("userList = \(success?.status ?? 0)")
                                self.navigationController?.popViewController(animated: true)
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
    func setTimestamp(epochTime: String) -> String {
        let currentDate = Date()
        
        let epochDate = Date(timeIntervalSince1970: TimeInterval(epochTime) as! TimeInterval)
        
        let calendar = Calendar.current
        
        let currentDay = calendar.component(.day, from: currentDate)
        let currentHour = calendar.component(.hour, from: currentDate)
        let currentMinutes = calendar.component(.minute, from: currentDate)
        let currentSeconds = calendar.component(.second, from: currentDate)
        
        let epochDay = calendar.component(.day, from: epochDate)
        let epochMonth = calendar.component(.month, from: epochDate)
        let epochYear = calendar.component(.year, from: epochDate)
        let epochHour = calendar.component(.hour, from: epochDate)
        let epochMinutes = calendar.component(.minute, from: epochDate)
        let epochSeconds = calendar.component(.second, from: epochDate)
        
        if (currentDay - epochDay < 30) {
            if (currentDay == epochDay) {
                if (currentHour - epochHour == 0) {
                    if (currentMinutes - epochMinutes == 0) {
                        if (currentSeconds - epochSeconds <= 1) {
                            return String(currentSeconds - epochSeconds) + " second ago"
                        } else {
                            return String(currentSeconds - epochSeconds) + " seconds ago"
                        }
                        
                    } else if (currentMinutes - epochMinutes <= 1) {
                        return String(currentMinutes - epochMinutes) + " minute ago"
                    } else {
                        return String(currentMinutes - epochMinutes) + " minutes ago"
                    }
                } else if (currentHour - epochHour <= 1) {
                    return String(currentHour - epochHour) + " hour ago"
                } else {
                    return String(currentHour - epochHour) + " hours ago"
                }
            } else if (currentDay - epochDay <= 1) {
                return String(currentDay - epochDay) + " day ago"
            } else {
                return String(currentDay - epochDay) + " days ago"
            }
        } else {
            return String(epochDay) + " " + getMonthNameFromInt(month: epochMonth) + " " + String(epochYear)
        }
    }
    func getMonthNameFromInt(month: Int) -> String {
        switch month {
        case 1:
            return "Jan"
        case 2:
            return "Feb"
        case 3:
            return "Mar"
        case 4:
            return "Apr"
        case 5:
            return "May"
        case 6:
            return "Jun"
        case 7:
            return "Jul"
        case 8:
            return "Aug"
        case 9:
            return "Sept"
        case 10:
            return "Oct"
        case 11:
            return "Nov"
        case 12:
            return "Dec"
        default:
            return ""
        }
    }
    
   
    
    
    //MARK: - Actions
    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func menuButtonAction(_ sender: Any) {
        self.moreDropdown.show()
        
    }
    
    @IBAction func sendButtonAction(_ sender: Any) {
        self.sendMessage()
        
        self.messageTextfield.text = ""
        
    }
    
    @IBAction func imageButtonAction(_ sender: Any) {
        self.sendMedia()
    }
    
}

extension ChatScreenVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.chatList.isEmpty{
            return UITableView.automaticDimension
        }else{
            let object = self.chatList[indexPath.row] ?? nil
            switch object?.apiType {
            case "image":
                return 200
            default:
                return UITableView.automaticDimension
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.chatList.isEmpty{
            return 1
        }else{
            return chatList.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.chatList.isEmpty{
            return UITableViewCell()
        }else{
            let object = self.chatList[indexPath.row] ?? nil
            switch object?.apiType {
            case "text":
                switch object?.apiPosition {
                case "left":
                    let cell = tableView.dequeueReusableCell(withIdentifier: ChatSenderTableItem.identifier) as? ChatSenderTableItem
                    cell?.selectionStyle = .none
                    cell?.bind(object!)
                    return cell!
                case "right":
                    let cell = tableView.dequeueReusableCell(withIdentifier: ChatReceiverTableItem.identifier) as? ChatReceiverTableItem
                    cell?.selectionStyle = .none
                    cell?.bind(object!)
                    return cell!
                default:
                    return UITableViewCell()
                }
            case "image":
                switch object?.apiPosition {
                case "left":
                    let cell = tableView.dequeueReusableCell(withIdentifier: SenderImageTableItem.identifier) as? SenderImageTableItem
                    cell?.selectionStyle = .none
                    cell?.bind(object!)
                    return cell!
                case "right":
                    let cell = tableView.dequeueReusableCell(withIdentifier: ReceiverImageTableItem.identifier) as? ReceiverImageTableItem
                    cell?.selectionStyle = .none
                    cell?.bind(object!)
                    return cell!
                default:
                    return UITableViewCell()
                }
            default:
                return UITableViewCell()
            }
        }
    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if self.chatList.count == 0{
//            log.verbose("Nothing to select")
//        }else{
//            let object = self.chatList[indexPath.row]
//            if object.apiType == "image"{
//                if object.apiPosition == "right"{
//                    let cell = tableView.cellForRow(at: indexPath) as! ReceiverImageTableItem
//                    let currentPhoto = photos[(indexPath).row]
//                    let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto , referenceView: cell)
//                    
//                    galleryPreview.referenceViewForPhotoWhenDismissingHandler = { [weak self] photo in
//                        if let index = self?.photos.firstIndex(where: {$0 === photo}) {
//                            let indexPath = IndexPath(item: index, section: 0)
//                            return tableView.cellForRow(at: indexPath) as? ReceiverImageTableItem
//                        }
//                        return nil
//                    }
//                    present(galleryPreview, animated: true, completion: nil)
//                }else if object.apiPosition == "left"{
//                    let cell = tableView.cellForRow(at: indexPath) as! SenderImageTableItem
//                    let currentPhoto = photos[(indexPath).row]
//                    let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto , referenceView: cell)
//                    
//                    galleryPreview.referenceViewForPhotoWhenDismissingHandler = { [weak self] photo in
//                        if let index = self?.photos.firstIndex(where: {$0 === photo}) {
//                            let indexPath = IndexPath(item: index, section: 0)
//                            return tableView.cellForRow(at: indexPath) as? SenderImageTableItem
//                        }
//                        return nil
//                    }
//                    present(galleryPreview, animated: true, completion: nil)
//                }
//                
//            }
//        }
//        
//    }
}
extension  ChatScreenVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let convertedImageData = image.jpegData(compressionQuality: 0.2)
        self.sendMedia(ImageData: convertedImageData!)
        self.dismiss(animated: true, completion: nil)
        
        
    }
    
    private func sendMedia(ImageData:Data){
        let mediaHashId = Int(arc4random_uniform(UInt32(100000)))
        let toID = self.toUserId  ?? 0
        let accessToken = AppInstance.instance.accessToken ?? ""
        
        Async.background({
            ChatManager.instance.sendMedia(AccesToken: accessToken, userID: toID, mediaData: ImageData,HashID:mediaHashId) { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.messageID ?? 0)")
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
    }
    
}

