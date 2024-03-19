//
//  ShowStoryVC.swift
//  DeepSoundiOS
//
//  Created by iMac on 24/08/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit
import SDWebImage
import Async
import DeepSoundSDK

class ShowStoryVC: BaseVC {
    
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imageUser: UIImageView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var buttonStack: UIStackView!
    @IBOutlet weak var imagePreview: UIImageView!
    
    var spb: SegmentedProgressBar!
    var storyArray: [Story] = []
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.progressViewSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.spb.startAnimation()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func viewsBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        
    }
    
    @IBAction func deleteBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
    }
    
    private func progressViewSetup() {
        let height = UIApplication.shared.statusBarFrame.size.height
        spb = SegmentedProgressBar(numberOfSegments: self.storyArray.count, duration: 5)
        spb.topColor = UIColor.white
        spb.bottomColor = UIColor.white.withAlphaComponent(0.25)
        spb.isPaused = true
        spb.delegate = self
        spb.padding = 2
        spb.frame = CGRect(x: 15, y: height+15, width: view.frame.width - 30, height: 4)
        imagePreview.addSubview(spb)
    }
}

//MARK: - API Services -
extension ShowStoryVC {
    func startStoryAPI(story_id: Int) {
        if Connectivity.isConnectedToNetwork() {
            let id = AppInstance.instance.userId ?? 0
            Async.background {
                StoryManager.instance.startStoryAPI(user_id: id, story_id: story_id) { success, sessionError, error in
                    Async.main {
                        if success != nil {
                            self.dismissProgressDialog {
                                log.verbose("Success")
                            }
                        }else if sessionError != nil {
                            self.dismissProgressDialog {
                                log.error("sessionError")
                            }
                        }else {
                            self.dismissProgressDialog {
                                log.error("error")
                            }
                        }
                    }
                }
            }
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast((NSLocalizedString(InterNetError, comment: "")))
        }
    }
}

extension ShowStoryVC : SegmentedProgressBarDelegate {
    
    func segmentedProgressBarChangedIndex(index: Int) {
        log.debug("segmentedProgressBarChangedIndex:--- \(index)")
        let object = self.storyArray[index]
        self.startStoryAPI(story_id: object.id)
        self.buttonStack.isHidden = object.user_id != AppInstance.instance.userId
        self.lblTitle.text = object.user_data.name_v
        let date = Date(timeIntervalSince1970: TimeInterval(object.time))
        self.lblTime.text = date.timeAgoDisplay()
        let thumbnailURL = URL.init(string: object.image)
        let indicator = SDWebImageActivityIndicator.medium
        self.imagePreview.sd_imageIndicator = indicator
        self.imageUser.sd_imageIndicator = indicator
        DispatchQueue.global(qos: .userInteractive).async {
            self.imageUser.sd_setImage(with: URL(string: object.user_data.avatar ?? ""), placeholderImage: R.image.icn_boy())
            self.imagePreview.sd_setImage(with: thumbnailURL, placeholderImage: R.image.icPlaceholderImage())
        }
    }

    func segmentedProgressBarFinished() {
        log.debug("finished:---")
    }
}
