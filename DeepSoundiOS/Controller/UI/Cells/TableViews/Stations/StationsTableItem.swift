//
//  StationsTableItem.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 08/01/2022.
//  Copyright © 2022 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
class StationsTableItem: UITableViewCell {
    
    @IBOutlet weak var ShowImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    
    var delegate : addStationDelegate?
    var object = [String:Any]()
    var vc:StationsFullVC?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func bind(_ object:[String:Any]){
        self.object = object
        let name = object["name"] as? String
        let country = object["country"] as? String
        let genre = object["genre"] as? String
        let image = object["image"] as? String
        let url = URL.init(string:image ?? "")
        self.titleLabel.text = name ?? ""
        self.countryLabel.text = "Country: \(country ?? "")"
        self.genresLabel.text =  "Genres:\(genre ?? "")"
        self.ShowImage.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
        
    }
    
    @IBAction func addPressed(_ sender: Any) {
//        self.delegate?.addStation(object: self.object)
        let accessToken = AppInstance.instance.accessToken ?? ""
        let id = object["radio_id"] as? String
        let country = object["country"] as? String
        let genre = object["genre"] as? String
        let logo = object["logo"] as? String
        let name = object["name"] as? String
        let url = object["url"] as? String
        Async.background({
            stationManager.instance.addStations(AccessToken:accessToken , id: id ?? "", station: id ?? "", url: url ?? "", logo: logo ?? "", genre: genre ?? "", country: country ?? "") { success, sessionError, error in
                if success != nil{
                    Async.main({
                        self.vc?.dismissProgressDialog {
                            self.addBtn.isHidden = true
                            self.vc?.view.makeToast("Added Successfully")
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.vc?.dismissProgressDialog {
                            
                            self.vc?.view.makeToast((NSLocalizedString(sessionError ?? "", comment: "")))
                            log.error("sessionError = \(sessionError ?? "")")
                        }
                    })
                }else {
                    Async.main({
                        self.vc?.dismissProgressDialog {
                            
                            self.vc?.view.makeToast((NSLocalizedString(error?.localizedDescription ?? "", comment: "")))
                            log.error("error = \(error?.localizedDescription ?? "")")
                        }
                    })
                }
            }
        })
    }
    
}
