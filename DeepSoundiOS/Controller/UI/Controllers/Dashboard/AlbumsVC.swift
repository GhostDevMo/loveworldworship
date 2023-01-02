//
//  AlbumsVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/10/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import EmptyDataSet_Swift
class AlbumsVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var albumsArray = [ProfileModel.AlbumElement]()
    var status:Bool? = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    func setupUI(){
        tableView.separatorStyle = .none
        tableView.register(ProfileAlbumsTableCell.nib, forCellReuseIdentifier: ProfileAlbumsTableCell.identifier)
        tableView.register(NoDataTableItem.nib, forCellReuseIdentifier: NoDataTableItem.identifier)
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}
extension AlbumsVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if status!{
            if albumsArray.isEmpty{
                return 1
            }else{
                return albumsArray.count ?? 0
                
            }
        }else{
            if albumsArray.isEmpty{
                if AppInstance.instance.userProfile?.data?.albums?.count ==  0{
                    return 1
                }else{
                    return AppInstance.instance.userProfile?.data?.albums?.count ?? 0
                    
                }
                
            }else{
                if albumsArray.isEmpty{
                    return 1
                }else{
                    return albumsArray.count ?? 0
                    
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if status!{
            if (self.albumsArray.count == 0){
                let cell = tableView.dequeueReusableCell(withIdentifier: NoDataTableItem.identifier) as? NoDataTableItem
                cell?.selectionStyle = .none
                return cell!
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: ProfileAlbumsTableCell.identifier) as? ProfileAlbumsTableCell
                cell?.selectionStyle = .none
                
                let object = albumsArray[indexPath.row]
                cell?.bind(object)
                return cell!
            }
        }else{
            if albumsArray.isEmpty{
                if (AppInstance.instance.userProfile?.data?.albums?.count == 0){
                    let cell = tableView.dequeueReusableCell(withIdentifier: NoDataTableItem.identifier) as? NoDataTableItem
                    cell?.selectionStyle = .none
                    return cell!
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: ProfileAlbumsTableCell.identifier) as? ProfileAlbumsTableCell
                    cell?.selectionStyle = .none
                    
                    let object = AppInstance.instance.userProfile?.data?.albums![indexPath.row]
                    cell?.bind(object!)
                    return cell!
                }
            }else{
                if (self.albumsArray.count == 0){
                    let cell = tableView.dequeueReusableCell(withIdentifier: NoDataTableItem.identifier) as? NoDataTableItem
                    cell?.selectionStyle = .none
                    return cell!
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: ProfileAlbumsTableCell.identifier) as? ProfileAlbumsTableCell
                    cell?.selectionStyle = .none
                    
                    let object = albumsArray[indexPath.row]
                    cell?.bind(object)
                    return cell!
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if status!{
            if albumsArray.isEmpty{
                return 300.0
            }else{
                return 120.0
                
            }
        }else{
            if albumsArray.isEmpty{
                if AppInstance.instance.userProfile?.data?.albums?.count ==  0{
                    return 300.0
                }else{
                    return 120.0
                }
                
            }else{
                if albumsArray.isEmpty{
                    return 300.0
                }else{
                    return 120.0
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = R.storyboard.dashboard.showAlbumVC()
        vc?.profileAlbumObject = AppInstance.instance.userProfile?.data?.albums![indexPath.row]
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
extension AlbumsVC: EmptyDataSetSource, EmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No Albums", attributes: [NSAttributedString.Key.font : R.font.poppinsBold(size: 30) ?? UIFont.boldSystemFont(ofSize: 24)])
    }
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "You have no Albums in list", attributes: [NSAttributedString.Key.font : R.font.poppinsMedium(size: 14) ?? UIFont.systemFont(ofSize: 14)])
    }
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return resizeImage(image:  R.image.emptyData()!, targetSize:  CGSize(width: 200.0, height: 200.0))
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(origin: .zero, size: newSize)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
extension AlbumsVC:IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: (NSLocalizedString("Albums", comment: "Albums")))
    }
}
