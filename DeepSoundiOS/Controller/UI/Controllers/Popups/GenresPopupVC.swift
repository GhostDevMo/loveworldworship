//
//  GenresPopupVC.swift
//  DeepSoundiOS
//
//  Created by iMac on 26/07/23.
//  Copyright © 2023 Moghees Idrees. All rights reserved.
//

import UIKit
import Toast_Swift
import DeepSoundSDK
import Async

protocol GenresPopupVCDelegate {
    func handleGenresSelection(id: Int, cateogryName: String)
}

class GenresPopupVC: BaseVC {
    
    // MARK: - IBOutlets
        
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var closeButton: UIButton!
    
    // MARK: - Properties
    
    private var genresArray = [GenresModel.Datum]()
    var delegate: GenresPopupVCDelegate?
    
    // MARK: - View Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.initialConfig()
    }
    
    // MARK: - Selectors
    
    // Close Button Action
    @IBAction func closeButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.tableViewSetUp()
        self.fetchGenres()
    }
    
    // TableView SetUp
    func tableViewSetUp() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(resource: R.nib.genresPopupCell), forCellReuseIdentifier: R.reuseIdentifier.genresPopupCell.identifier)
    }

}

// MARK: - Extensions

// MARK: Api Call
extension GenresPopupVC {
    
    private func fetchGenres() {
        self.genresArray.removeAll()
        self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background {
            GenresManager.instance.getGenres(AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                if success != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.data ?? [])")
                            self.genresArray = success?.data ?? []
                            self.tableView.reloadData()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                self.tableViewHeight.constant = self.tableView.contentSize.height
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
            })
        }
    }    
}

// MARK: TableView Setup
extension GenresPopupVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.genresArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.genresPopupCell.identifier, for: indexPath) as! GenresPopupCell
        cell.genresNameLabel.text = self.genresArray[indexPath.row].cateogryName ?? ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let genres = self.genresArray[indexPath.row]
        self.dismiss(animated: true) {
            self.delegate?.handleGenresSelection(id: genres.id ?? 0, cateogryName: genres.cateogryName ?? "")
        }
    }
    
}
