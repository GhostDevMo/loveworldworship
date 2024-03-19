//
//  ViewController.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 13/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import WebKit
import Async
import DeepSoundSDK

class GenresVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var topLabel: UILabel!
    
    // MARK: - Properties
    
    var status : Bool = false
    private var genresArray = [GenresModel.Datum]()
    private var delegate : didSetInterestGenres?
    private var idsArray: [Int] = []
    private var genresString: String? = ""
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Selectors
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func savePressed(_ sender: UIButton) {
        self.view.endEditing(true)
        UserDefaults.standard.setGenreIDs(value: self.idsArray, key: "GenreIDs")
//        self.navigationController?.popViewController(animated: true)
        let stringArray = self.idsArray.map { String($0) }
        self.genresString = stringArray.joined(separator: ",")
        log.verbose("genresString = \(String(describing: genresString))")
        self.save()
    }
    
    // MARK: - Helper Functions
    
    private func setupUI() {
        self.saveBtn.addShadow(offset: CGSize(width: 0, height: 1))
        let XIB = UINib(resource: R.nib.genresCollectionCell)
        self.collectionView.register(XIB, forCellWithReuseIdentifier: R.reuseIdentifier.genres_CollectionCell.identifier)
        self.saveBtn.backgroundColor = .ButtonColor
    }
    
    // Set User Genres Data
    func setUserGenresData() {
        
    }
    
}

// MARK: - Extensions

// MARK: API Services
extension GenresVC {
    
    private func save() {
        self.showProgressDialog(text: "Loading...")
        let accessToken = AppInstance.instance.accessToken ?? ""
        let userId = AppInstance.instance.userId ?? 0
        let genresString = self.genresString ?? ""
        Async.background {
            GenresManager.instance.updateGenres(AccessToken: accessToken, Id: userId, Genres: genresString, completionBlock: { (success, sessionError, error) in
                if success != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.message ?? "")")
                            self.view.makeToast(success?.message ?? "")
                            if self.status {
                                let newVC =  R.storyboard.dashboard.tabBarNav()
                                self.appDelegate.window?.rootViewController = newVC
                            } else {
                                self.navigationController?.popViewController(animated: true)
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
    
    private func fetchData() {
        self.genresArray.removeAll()
        self.showProgressDialog(text: "Loading...")
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background {
            GenresManager.instance.getGenres(AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                if success != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.data ?? [])")
                            self.genresArray = success?.data ?? []
                            if let ids = UserDefaults.standard.getGenreIDs(key: "GenreIDs") {
                                self.idsArray = ids
                            }
                            self.collectionView.reloadData()
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

//MARK: CollectionView Setup
extension GenresVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.genresArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.genres_CollectionCell.identifier, for: indexPath) as! Genres_CollectionCell
        cell.delegate = self
        cell.indexPath = indexPath
        let object = genresArray[indexPath.row]
        cell.bgView.backgroundColor = UIColor.hexStringToUIColor(hex: object.color ?? "")
        cell.nameLabel.text = object.cateogryName ?? ""
        let url = URL.init(string: object.backgroundThumb ?? "")
        cell.backgroundImage.transform = .init(rotationAngle: .pi/3.25)
        cell.backgroundImage.sd_setImage(with: url, placeholderImage: R.image.imagePlacholder(), completed: { image, error, type, url in
            let finalImage = image?.rotate(radians: -(.pi)/2)
            cell.backgroundImage.image = finalImage
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let size = cell.backgroundImage.frame.size
            cell.backgroundImageBottomConst.constant = -(size.width*0.175)
            cell.backgroundImageTrailingConst.constant = -(size.width*0.15)
        }
        if self.idsArray.contains(object.id ?? 0) {
            cell.tickImage.isHidden = false
        } else {
            cell.tickImage.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size
        return CGSize(width: (size.width/2.0) - 25.0, height: size.width/3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15.0, bottom: 0, right: 15.0)
    }
    
}

//MARK: Genre Configure Cell Delegate Methods
extension GenresVC: GenresCellDelegate {
    
    func handleGenresTap(indexPath: IndexPath) {
        let id = self.genresArray[indexPath.row].id ?? 0
        if self.idsArray.contains(id) {
            for (index, value) in self.idsArray.enumerated() {
                if value == id {
                    self.idsArray.remove(at: index)
                    break
                }
            }
        } else {
            self.idsArray.append(id)
        }
        log.verbose("genresIdArray = \(self.idsArray)")
        self.collectionView.reloadItems(at: [indexPath])
    }
}

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
}
