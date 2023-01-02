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
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var savePressed: UIButton!
    var status:Bool? = false
    private var genresArray = [GenresModel.Datum]()
    private var delegate : didSetInterestGenres?
    private var idsArray = [Int]()
    private var genresString:String? = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.savePressed.backgroundColor = .ButtonColor
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
    @IBAction func savePressed(_ sender: Any) {
        var stringArray = self.idsArray.map { String($0) }
        self.genresString = stringArray.joined(separator: ",")
        log.verbose("genresString = \(genresString)")
        self.save()
    }
    private func setupUI(){
        self.saveBtn.setTitle(NSLocalizedString("SAVE", comment: "SAVE"), for: .normal)
        self.topLabel.text = NSLocalizedString("Select your most favorite genres", comment: "Select your most favorite genres")
        self.bottomLabel.text = NSLocalizedString("You can change these later", comment: "You can change these later")
        self.title  = NSLocalizedString("Select Genre", comment: "Select Genre")
        collectionView.register(Genres_CollectionCell.nib, forCellWithReuseIdentifier: Genres_CollectionCell.identifier)
    }
    private func save(){
        
        self.showProgressDialog(text: "Loading...")
        let accessToken = AppInstance.instance.accessToken ?? ""
        let userId = AppInstance.instance.userId ?? 0
        let genresString = self.genresString ?? ""
        
        Async.background({
            GenresManager.instance.updateGenres(AccessToken: accessToken, Id: userId, Genres: genresString, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            
                            log.debug("userList = \(success?.message ?? "")")
                            self.view.makeToast(success?.message ?? "")
                            let vc = R.storyboard.dashboard.dashBoardTabbar()
                            if self.status!{
                                self.present(vc!, animated: true, completion: nil)
                            }else{
                                log.verbose("simple Navigation ")
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
    }
    
    private func fetchData(){
        self.genresArray.removeAll()
        self.showProgressDialog(text: "Loading...")
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background({
            GenresManager.instance.getGenres(AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            
                            log.debug("userList = \(success?.data ?? [])")
                            self.genresArray = success?.data ?? []
                            self.collectionView.reloadData()
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
    }
}
extension GenresVC:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.genresArray.count 
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Genres_CollectionCell.identifier, for: indexPath) as? Genres_CollectionCell
        cell?.delegate = self
        
        let object = genresArray[indexPath.row]
        cell?.genresIdArray = genresArray
        cell?.indexPath = indexPath.row
        cell?.nameLabel.text = object.cateogryName ?? ""
        let url = URL.init(string:object.backgroundThumb ?? "")
        cell?.backgroundImage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
        return cell!
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: 160.0, height: 80.0)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        log.verbose("genresArray[indexPath.row] \(genresArray[indexPath.row].id ?? 0)")
        self.idsArray.append(genresArray[indexPath.row].id ?? 0)
        log.verbose("genresArray[indexPath.row].id \(idsArray)")
    }
    
}
//
extension GenresVC:didSetInterestGenres{
    func didSetInterest(Label: UILabel, Image: UIImageView, status: Bool,idsArray:[GenresModel.Datum],Index:Int) {
        if status{
            Image.isHidden = false
            Label.isHidden = true
            self.idsArray.append(idsArray[Index].id ?? 0)
            log.verbose("genresIdArray = \(self.idsArray)")
            
        }else{
            
            Image.isHidden = true
            Label.isHidden = false
            
            for (index,values) in self.idsArray.enumerated(){
                if values == idsArray[Index].id{
                    self.idsArray.remove(at: index)
                    break
                }
            }
            
            log.verbose("genresString = \(genresString)")
            log.verbose("genresIdArray = \(self.idsArray)")
        }
    }
}
