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

class CommentsVC: BaseVC {
    
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var showStack: UIStackView!
    
    private var commentsArray = [GetCommentModel.Datum]()
    private var refreshControl = UIRefreshControl()
    private var fetchSatus:Bool? = true
    var trackId:Int? = 0
    var trackIdString:String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sendBtn.backgroundColor = .ButtonColor
        self.showImage.tintColor = .mainColor
        SwiftEventBus.onMainThread(self, name:   EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER) { result in
            log.verbose("To dismiss the popover")
            AppInstance.instance.player = nil
            self.tabBarController?.dismissPopupBar(animated: true, completion: nil)
        }
        SwiftEventBus.onMainThread(self, name:   "PlayerReload") { result in
            let stringValue = result?.object as? String
            self.view.makeToast(stringValue)
            log.verbose(stringValue)
        }
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_COMMENT_DATA_FETCH) { result in

            self.fetchComments()
        }

        //Internet connectivity event subscription
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_DIS_CONNECTED) { result in

            self.view.makeToast(InterNetError)
        }
        
        
        self.setupUI()
        self.fetchComments()
    }
    
    @IBAction func sendPressed(_ sender: Any) {
        self.sendComment()
    }
    
    @IBAction func smilePressed(_ sender: Any) {
    }
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    private func setupUI(){
        self.showImage.isHidden = true
        self.showStack.isHidden = true
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        self.tableView.separatorStyle = .none
        tableView.register(Comments_TableCell.nib, forCellReuseIdentifier:Comments_TableCell.identifier)
        self.textViewPlaceHolder()
    }
    @objc func refresh(sender:AnyObject) {
        self.commentsArray.removeAll()
        self.tableView.reloadData()
        self.fetchComments()
        refreshControl.endRefreshing()
    }
    private func textViewPlaceHolder(){
        commentTextView.delegate = self
        commentTextView.text = "Your Comment here..."
        commentTextView.textColor = UIColor.lightGray
    }
    private func fetchComments(){
        if Connectivity.isConnectedToNetwork(){
              self.commentsArray.removeAll()
            if fetchSatus!{
                fetchSatus = false
                self.showProgressDialog(text: "Loading...")
            }else{
                log.verbose("will not show Hud more...")
            }
          
            let accessToken = AppInstance.instance.accessToken ?? ""
            let trackId = self.trackId ?? 0
            Async.background({
                CommentManager.instance.getComments(TrackId: trackId, AccessToken: accessToken, Limit: 10, Offset: 0, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                log.debug("userList = \(success?.data?.data ?? [])")
                                self.commentsArray = success?.data?.data ?? []
                                if self.commentsArray.isEmpty{
                                    self.showImage.isHidden = false
                                    self.showStack.isHidden = false
                                    self.tableView.reloadData()
                                }else{
                                    self.showImage.isHidden = true
                                    self.showStack.isHidden = true
                                    self.tableView.reloadData()
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
                })
               
            })
            
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    
    private func sendComment(){
        if Connectivity.isConnectedToNetwork(){
           log.verbose("trackIdString - \(trackId)")
            let accessToken = AppInstance.instance.accessToken ?? ""
            let trackId = self.trackIdString ?? ""
            let commentString = self.commentTextView.text ?? ""
            let timePercentage = 24
            Async.background({
                CommentManager.instance.postComment(TrackId: trackId, AccessToken: accessToken, TimePercentage: timePercentage, Value: commentString, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                self.textViewPlaceHolder()
                                self.dismissKeyboard()
                                SwiftEventBus.post(EventBusConstants.EventBusConstantsUtils.EVENT_COMMENT_DATA_FETCH)
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
                })
                
            })
            
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
}
extension CommentsVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.commentsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Comments_TableCell.identifier) as? Comments_TableCell
     
        cell?.selectionStyle = .none
        let object = self.commentsArray[indexPath.row]
       
        cell?.likeDislikeCommentDelegate = self
        cell?.commentDelegate = self
        cell?.indexPath = indexPath.row
        cell?.likeStatus = object.isLikedComment!
        cell?.commentId = object.id!
//       cell?.messegeTextView.text = "\(object.value ?? "")\n\n\(object.secondsFormated ?? "")"
        cell?.messegeTextView.text = object.value ?? ""
        cell?.likeCount.text = object.secondsFormated ?? ""
        let url = URL.init(string:object.userData?.avatar ?? "")
        cell?.nameLabel.text = object.userData?.name ?? ""
        cell?.profileImage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
        if object.isLikedComment!{
            cell?.likeBtn.setImage(R.image.ic_redHeart(), for: .normal)
        }else{
            cell?.likeBtn.setImage(R.image.ic_outlineHeart(), for: .normal)
       
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}


extension CommentsVC:likeDislikeCommentDelegate{
    func likeDisLikeComment(status: Bool, button: UIButton, commentId: Int) {
        if status{
            button.setImage(R.image.ic_outlineHeart(), for: .normal)
            self.disLikeComment(commentId: commentId, button: button)
        }else{
            button.setImage(R.image.ic_redHeart(), for: .normal)
           self.likeComment(commentId: commentId, button: button)
        }
    }
    
    
  
    
    private func likeComment(commentId:Int,button:UIButton){
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            let idComment = commentId ?? 0
            Async.background({
                CommentManager.instance.likeComment(CommentId: idComment, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                               
                                button.setImage(R.image.ic_redHeart(), for: .normal)
                                
                            }
                        })
                        
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.error ?? "")")
                                self.view.makeToast(sessionError?.error ?? "")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.view.makeToast(error?.localizedDescription ?? "")
                            }
                        })
                    }
                })
              
            })
        }else{
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
        
    }
    private func disLikeComment(commentId:Int,button:UIButton){
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            let idComment = commentId ?? 0
            Async.background({
                
                CommentManager.instance.disLikeComment(CommentId: idComment, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                                
                                button.setImage(R.image.ic_outlineHeart(), for: .normal)
                                
                            }
                        })
                        
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.error ?? "")")
                                self.view.makeToast(sessionError?.error ?? "")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.view.makeToast(error?.localizedDescription ?? "")
                            }
                        })
                    }
                })
                
            })
        }else{
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
        
    }
}


extension CommentsVC:UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            self.commentTextView.text = ""
            textView.textColor = UIColor.black
            
            
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Your Comment here..."
            textView.textColor = UIColor.lightGray
            
            
        }
    }
   
}


extension CommentsVC:commentProfileDelegate{
    func commentProfile(index: Int, status: Bool) {
        if status{
            let vc = R.storyboard.dashboard.showProfileVC()
            vc?.userID  = self.commentsArray[index].userData?.id ?? 0
            vc?.profileUrl = self.commentsArray[index].userData?.url ?? ""
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    } 
}
