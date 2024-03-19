//
//  SearchEventsVC.swift
//  DeepSoundiOS
//
//  Created by iMac on 11/07/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SwiftEventBus
import Async
import DeepSoundSDK

class SearchEventsVC: BaseVC {
    
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showStack: UIStackView!
    @IBOutlet weak var showImage: UIImageView!
    
    private let randomString:String = "\("abcdefghijklmnopqrstuvwxyz".randomElement()!)"
    var isLoading = true
    private var eventlistArray = [Events]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.topLabel.text = NSLocalizedString("Sad No Result", comment: "Sad No Result")
        self.bottomLabel.text = NSLocalizedString("We cannot find keyword you are searching for maybe a little spelling mistake?", comment: "We cannot find keyword you are searching for maybe a little spelling mistake?")
        self.searchBtn.setTitle(NSLocalizedString("Search Random", comment: "Search Random"), for: .normal)
        self.showImage.tintColor = .mainColor
        self.searchBtn.backgroundColor = .ButtonColor
         
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_RECEIVE_RESULT_FOR_SEARCH_TEXTFIELD) { result in
            self.dismissProgressDialog {
                if let isTyping = result?.userInfo?[AnyHashable("isTyping")] as? Bool, isTyping {
                    if !self.isLoading {
                        self.eventlistArray.removeAll()
                        self.isLoading = true
                        self.tableView.reloadData()
                        return
                    }
                }
                if let playlistResult = result?.userInfo?[AnyHashable("receiveResult")] as? SearchModel.DataClass {
//                    self.eventlistArray = playlistResult.events ?? []
                    self.eventlistArray = playlistResult.events?.filter({$0.user_data?.dataValue != nil}) ?? []
                    let isHidden = self.eventlistArray.count == 0
                    self.showImage.isHidden = !isHidden
                    self.showStack.isHidden = !isHidden
                    self.searchBtn.isHidden = !isHidden
                    log.verbose("SongsCount = \(playlistResult.events?.count ?? 0)")
                    self.isLoading = false
                    self.tableView.reloadData()
                    return
                }
            }
        }
        
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER) { result in
            log.verbose("To dismiss the popover")
            self.tabBarController?.dismissPopupBar(animated: true, completion: nil)
        }
        
        SwiftEventBus.onMainThread(self, name: "PlayerReload") { result in
            let stringValue = result?.object as? String
            self.view.makeToast(stringValue)
            log.verbose(stringValue ?? "")
        }
    }
    
    
    @IBAction func searchPressed(_ sender: UIButton) {
        self.showProgressDialog(text: "Loading...")
        SwiftEventBus.post( EventBusConstants.EventBusConstantsUtils.EVENT_SEARCH, userInfo: ["isRandomSearch": true])
    }
    
    private func setupUI() {
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib(resource: R.nib.eventShowTableItem), forCellReuseIdentifier: R.reuseIdentifier.eventShowTableItem.identifier)
    }
}

extension SearchEventsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isLoading {
            return 5
        }else {
            return self.eventlistArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isLoading {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.eventShowTableItem.identifier) as? EventShowTableItem
            cell?.startSkelting()
            return cell!
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.eventShowTableItem.identifier) as? EventShowTableItem
            cell?.stopSkelting()
            cell?.selectionStyle = .none
            let object = self.eventlistArray[indexPath.row]
            cell?.bind(object)
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isLoading {
            let vc = R.storyboard.products.eventDetailVC()
            vc?.eventDetailObject = self.eventlistArray[indexPath.row]
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300.0
    }
}

