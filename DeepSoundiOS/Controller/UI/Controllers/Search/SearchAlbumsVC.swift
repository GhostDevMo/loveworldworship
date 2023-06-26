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
    
    private let randomString:String? = "a"
    private var albumArray = [SearchModel.Album]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.topLabel.text = NSLocalizedString("Sad No Result", comment: "Sad No Result")
        self.bottomLabel.text = NSLocalizedString("We cannot find keyword you are searching for maybe a little spelling mistake?", comment: "We cannot find keyword you are searching for maybe a little spelling mistake?")
        self.searchBtn.setTitle(NSLocalizedString("Search Random", comment: "Search Random"), for: .normal)
        
        self.showImage.tintColor = .mainColor
        self.searchBtn.backgroundColor = .ButtonColor
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_RECEIVE_RESULT_FOR_SEARCH) { result in
            self.dismissProgressDialog {
                 self.albumArray.removeAll()
                self.showImage.isHidden = true
                self.showStack.isHidden = true
                self.searchBtn.isHidden = true
                log.verbose("Event StringArrvied  = \(result?.userInfo![AnyHashable("receiveResult")])")
                let result1 = result?.userInfo![AnyHashable("receiveResult")] as? SearchModel.DataClass
                let albumResult = result?.userInfo![AnyHashable("receiveResult")] as? SearchModel.DataClass
                log.verbose("AlbumCount = \(result1?.albums?.count)")
                self.albumArray = albumResult?.albums ?? []
                self.tableView.reloadData()
            }
        }
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_RECEIVE_RESULT_FOR_SEARCH_TEXTFIELD) { result in
            self.dismissProgressDialog {
                self.albumArray.removeAll()
                self.showImage.isHidden = true
                self.showStack.isHidden = true
                self.searchBtn.isHidden = true
                log.verbose("Event StringArrvied  = \(result?.userInfo![AnyHashable("receiveResult")])")
                let result1 = result?.userInfo![AnyHashable("receiveResult")] as? SearchModel.DataClass
                let albumResult = result?.userInfo![AnyHashable("receiveResult")] as? SearchModel.DataClass
                log.verbose("AlbumCount = \(result1?.albums?.count)")
                self.albumArray = albumResult?.albums ?? []
                self.tableView.reloadData()
            }
        }
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
    }
    

    @IBAction func searchPressed(_ sender: Any) {
        self.showProgressDialog(text: "Loading...")
        SwiftEventBus.post( EventBusConstants.EventBusConstantsUtils.EVENT_SEARCH, userInfo: ["keyword":randomString])
    }
    private func setupUI(){
//        self.tableView.isHidden = true
        self.tableView.separatorStyle = .none
        tableView.register(SearchAlbum_TableCell.nib, forCellReuseIdentifier: SearchAlbum_TableCell.identifier)
        self.tableView.register(ProfileAlbumsTableCell.nib, forCellReuseIdentifier: ProfileAlbumsTableCell.identifier)
    }
    
}
extension SearchAlbumsVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.albumArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileAlbumsTableCell.identifier) as! ProfileAlbumsTableCell
        cell.selectionStyle = .none
        let object = self.albumArray[indexPath.row]
        cell.searchAlbumBind(object)
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = R.storyboard.dashboard.showAlbumVC()
        vc?.searchAlbumObject = self.albumArray[indexPath.row]
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    
}
extension
SearchAlbumsVC:showReportScreenDelegate{
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
extension SearchAlbumsVC:showToastStringDelegate{
    func showToastString(string: String) {
        self.view.makeToast(string)
    }
}
extension SearchAlbumsVC:IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: NSLocalizedString("ALBUMS", comment: "ALBUMS"))
    }
}
