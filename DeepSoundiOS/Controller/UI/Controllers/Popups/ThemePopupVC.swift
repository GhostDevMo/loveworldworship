//
//  ThemePopupVC.swift
//  DeepSoundiOS
//
//  Created by iMac on 25/05/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import Foundation
import UIKit

class ThemePopupVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    let optionArray = [
        "Light",
        "Dark",
        "Set by Battery saver (Auto)"
    ]
    
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
        self.dismiss(animated: true)
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.view.backgroundColor = .black.withAlphaComponent(0.4)
        self.registerCell()
    }
    
    // Register Cell
    func registerCell() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(resource: R.nib.themePopupCell), forCellReuseIdentifier: R.reuseIdentifier.themePopupCell.identifier)
    }
    
    private func theme() {
        let alert = UIAlertController(title: (NSLocalizedString("Select Theme", comment: "")), message: "", preferredStyle: .alert)
        let light = UIAlertAction(title: (NSLocalizedString("Light", comment: "")), style: .destructive) { (action) in
            if #available(iOS 13.0, *) {
                self.appDelegate.window?.overrideUserInterfaceStyle = .light
                UserDefaults.standard.setDarkMode(value: false, ForKey: "darkMode")
            }
        }
        let dark = UIAlertAction(title: "Dark", style: .destructive) { (action) in
            if #available(iOS 13.0, *) {
                self.appDelegate.window?.overrideUserInterfaceStyle = .dark
                UserDefaults.standard.setDarkMode(value: true, ForKey: "darkMode")
            }
        }
        let cancel = UIAlertAction(title: (NSLocalizedString("Cancel", comment: "")), style: .cancel, handler: nil)
        alert.addAction(light)
        alert.addAction(dark)
        alert.addAction(cancel)
        alert.popoverPresentationController?.sourceView = self.view
        self.present(alert, animated:true, completion: nil)
    }
    
}

// MARK: - Extensions

// MARK: TableView Setup
extension ThemePopupVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.optionArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.themePopupCell.identifier, for: indexPath) as! ThemePopupCell
        cell.titleLabel.text = optionArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let keyWindow = UIApplication.shared.connectedScenes
               .filter({$0.activationState == .foregroundActive})
               .compactMap({$0 as? UIWindowScene})
               .first?.windows
               .filter({$0.isKeyWindow}).first
        if indexPath.row == 0 {
            keyWindow?.overrideUserInterfaceStyle = .light
            UserDefaults.standard.setDarkMode(value: false, ForKey: "darkMode")
            UserDefaults.standard.setSystemTheme(value: false, ForKey: "SystemTheme")
        } else if indexPath.row == 1 {
            keyWindow?.overrideUserInterfaceStyle = .dark
            UserDefaults.standard.setDarkMode(value: true, ForKey: "darkMode")
            UserDefaults.standard.setSystemTheme(value: false, ForKey: "SystemTheme")
        } else {
            keyWindow?.overrideUserInterfaceStyle = UIScreen.main.traitCollection.userInterfaceStyle
            UserDefaults.standard.setSystemTheme(value: true, ForKey: "SystemTheme")
        }
        self.dismiss(animated: true)
    }
}
