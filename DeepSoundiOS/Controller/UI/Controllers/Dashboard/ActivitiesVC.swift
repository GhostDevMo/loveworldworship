//
//  ActivitiesVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/10/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
import SwiftEventBus
import EmptyDataSet_Swift
import Toast_Swift

class ActivitiesVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    var activities: [Activity] = []
    var parentVC: BaseVC?
    var isOtherUser = false
    var userID: Int?
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.fetchUserProfile()
        self.tableView.addPullToRefresh {
            self.activities.removeAll()
            self.tableView.reloadData()
            self.fetchUserProfile()
        }
    }
    
    // MARK: - Helper Functions
    
    func setupUI() {
        tableView.separatorStyle = .none
        tableView.register(UINib(resource: R.nib.activities_TableCell), forCellReuseIdentifier: R.reuseIdentifier.activities_TableCell.identifier)
        tableView.register(UINib(resource: R.nib.noDataTableItem), forCellReuseIdentifier: R.reuseIdentifier.noDataTableItem.identifier)
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
    
    private func fetchUserProfile() {
        var userId = 0
        if isOtherUser {
            userId = self.userID ?? 0
        } else {
            userId = AppInstance.instance.userId ?? 0
        }
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background {
            ProfileManger.instance.getProfile(UserId: userId, fetch: "activities", AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                self.tableView.stopPullToRefresh()
                if success != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            self.activities = success?.data?.activities?.first ?? []
                            self.tableView.reloadData()
                        }
                    }
                } else if sessionError != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            log.error("sessionError = \(sessionError?.error ?? "")")
                            self.view.makeToast(NSLocalizedString(sessionError?.error ?? "", comment: ""))
                        }
                    }
                } else {
                    Async.main {
                        self.dismissProgressDialog {
                            log.error("error = \(error?.localizedDescription ?? "")")
                            // self.view.makeToast(NSLocalizedString(error?.localizedDescription ?? "", comment: ""))
                        }
                    }
                }
            })
        }
    }
    
}

// MARK: - Extensions

// MARK: TableView Setup
extension ActivitiesVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if activities.count == 0 {
            return 1
        }
        return activities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if activities.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.noDataTableItem.identifier, for: indexPath) as! NoDataTableItem
            cell.titleLabel.text = "No Activities"
            cell.noDataLabel.text = "You have no Activities in list"
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.activities_TableCell.identifier) as! Activities_TableCell
        cell.selectionStyle = .none
        let object = self.activities[indexPath.row]
        cell.vc = self
        cell.bind(object, index: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if activities.count != 0 {
            if activities[indexPath.row].trackData != nil {
                self.didSelectSong(songsArray: activities, indexPath: indexPath)
            }
        }
    }
    
    func didSelectSong(songsArray: [Activity], indexPath: IndexPath) {
        self.view.endEditing(true)
        var arrays: [Song] = []
        if let object = songsArray[indexPath.row].trackData {
            songsArray.forEach { (activity) in
                if let data = activity.trackData {
                    arrays.append(data)
                }
            }
            popupContentController?.popupItem.title = object.publisher?.name ?? ""
            popupContentController?.popupItem.subtitle = object.title?.htmlAttributedString ?? ""
            popupContentController?.popupBar.progressViewStyle = .bottom
            let cell = tableView.cellForRow(at: indexPath) as? Activities_TableCell
            popupContentController?.popupItem.image = cell?.thumbnailImage.image
            AppInstance.instance.popupPlayPauseSong = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
            }
            self.addToRecentlyWatched(trackId: object.id ?? 0)
            self.parentVC?.tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                popupContentController?.musicObject = object
                popupContentController?.musicArray = arrays
                popupContentController?.currentAudioIndex = indexPath.row
                popupContentController?.delegate = self
                popupContentController?.setup()
            })
        }
    }
    
}

// MARK: BottomSheetDelegate
extension ActivitiesVC: BottomSheetDelegate {
    
    func goToArtist(artist: Publisher) {
        self.view.endEditing(true)
        if let newVC = R.storyboard.discover.artistDetailsVC() {
            newVC.artistObject = artist
            self.navigationController?.pushViewController(newVC, animated: true)
        }
    }
    
    func goToAlbum() {
        let vc = R.storyboard.dashboard.albumsVC()
        self.parentVC?.navigationController?.pushViewController(vc!, animated: true)
    }
    
}
