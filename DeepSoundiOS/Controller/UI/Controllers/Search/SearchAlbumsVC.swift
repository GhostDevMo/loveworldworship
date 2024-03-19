//
//  SearchAlbumsVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 11/07/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import SwiftEventBus
import XLPagerTabStrip
import DeepSoundSDK

class SearchAlbumsVC: BaseVC {
    
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showStack: UIStackView!
    @IBOutlet weak var showImage: UIImageView!
    
    private let randomString: String = "\("abcdefghijklmnopqrstuvwxyz".randomElement()!)"
    private var albumArray = [Album]()
    private var isLoading = true
    
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
                        self.albumArray.removeAll()
                        self.isLoading = true
                        self.tableView.reloadData()
                        return
                    }
                }
                if let albumResult = result?.userInfo?[AnyHashable("receiveResult")] as? SearchModel.DataClass {
                    self.albumArray = albumResult.albums ?? []
                    let isHidden = self.albumArray.count == 0
                    self.showImage.isHidden = !isHidden
                    self.showStack.isHidden = !isHidden
                    self.searchBtn.isHidden = !isHidden
                    log.verbose("SongsCount = \(albumResult.albums?.count ?? 0)")
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
        self.tableView.register(UINib(resource: R.nib.searchAlbumTableCell), forCellReuseIdentifier: R.reuseIdentifier.searchAlbum_TableCell.identifier)
        self.tableView.register(UINib(resource: R.nib.profileAlbumsTableCell), forCellReuseIdentifier: R.reuseIdentifier.profileAlbumsTableCell.identifier)
    }
    
}

extension SearchAlbumsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 10
        } else {
            return self.albumArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.profileAlbumsTableCell.identifier) as! ProfileAlbumsTableCell
            cell.selectionStyle = .none
            cell.startSkelting()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.profileAlbumsTableCell.identifier) as! ProfileAlbumsTableCell
            cell.stopSkelting()
            cell.selectionStyle = .none
            let object = self.albumArray[indexPath.row]
            cell.searchAlbumBind(object)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isLoading {
            let vc = R.storyboard.dashboard.showAlbumVC()
            vc?.albumObject = self.albumArray[indexPath.row]
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension SearchAlbumsVC: showReportScreenDelegate {
    
    func showReportScreen(Status: Bool, IndexPath: Int,songLink:String) {
        if Status{
            let vc = R.storyboard.popups.reportVC()
            vc?.Id = self.albumArray[IndexPath].id ?? 0
            vc?.songLink = self.albumArray[IndexPath].url ?? ""
            vc?.delegate = self
            self.present(vc!, animated: true, completion: nil)
        }
    }
    
}

extension SearchAlbumsVC: showToastStringDelegate {
    
    func showToastString(string: String) {
        self.view.makeToast(string)
    }
    
}

extension SearchAlbumsVC: IndicatorInfoProvider {
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: NSLocalizedString("ALBUMS", comment: "ALBUMS"))
    }
    
}
