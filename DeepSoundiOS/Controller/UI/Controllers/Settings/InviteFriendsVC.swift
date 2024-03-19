//
//  InviteFriendsVC.swift
//  DeepSoundiOS
//
//  Created by hunain khan on 09/02/2022.
//  Copyright © 2022 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import MessageUI

struct FetchedContact {
    var firstName: String
    var lastName: String
    var telephone: String
}

class InviteFriendsVC: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialConfig()
    }
    
    // MARK: - Selectors
    
    // Back Button Action
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.registerCell()
    }
    
    // Register Cell
    func registerCell() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(resource: R.nib.contactCell), forCellReuseIdentifier: R.reuseIdentifier.contactCell.identifier)
    }
    
}

// MARK: - Extensions

// MARK: TableView Setup
extension InviteFriendsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppInstance.instance.contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.contactCell.identifier, for: indexPath) as! ContactCell
        cell.nameLabel?.text = AppInstance.instance.contacts[indexPath.row].firstName + " " + AppInstance.instance.contacts[indexPath.row].lastName
        cell.phoneNumberLabel?.text = AppInstance.instance.contacts[indexPath.row].telephone
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.sendSMSButtonAction(number: AppInstance.instance.contacts[indexPath.row].telephone)
    }
    
    private func sendSMSButtonAction(number: String) {
        guard MFMessageComposeViewController.canSendText() else {
            print("Unable to send messages.")
            return
        }
        let controller = MFMessageComposeViewController()
        controller.messageComposeDelegate = self
        controller.recipients = [number]
        controller.body = "Hi, let is meet on DeepSound for your smart phone"
        present(controller, animated: true)
    }
    
}

// MARK: MFMessageComposeViewControllerDelegate Methods
extension InviteFriendsVC: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
