//
//  ProfilePlaylistVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/10/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import EmptyDataSet_Swift
import EzPopup
class ProfilePlaylistVC: UIViewController{
    
    
    @IBOutlet weak var showLabel: UILabel!
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var playlistArray = [ProfileModel.Playlist]()
    var status:Bool? = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        //showLabel.text = (NSLocalizedString("There are no activity by this user ", comment: ""))
    }
    func setupUI(){
     
        tableView.register(SongsTableCells.nib, forCellReuseIdentifier: SongsTableCells.identifier)
        tableView.register(AssigingOrderHeaderTableCell.nib, forCellReuseIdentifier: AssigingOrderHeaderTableCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
    }
    @objc func didTapSongsMore(sender:UIButton){
      
            
     
     //       let panVC: PanModalPresentable.LayoutType = TopSongBottomSheetController(song: musicObject, delegate: self)
    //     presentPanModal(panVC)
       
    }
    @objc func didTapFilterData(sender:UIButton){
        let filterVC = FilterPopUPController(dele: self)
        
        let popupVC = PopupViewController(contentController: filterVC, position: .topLeft(CGPoint(x: self.tableView.frame.width - 230, y: 350)), popupWidth: 200, popupHeight: 200)
        popupVC.canTapOutsideToDismiss = true
        popupVC.cornerRadius = 10
        popupVC.shadowEnabled = true
        popupVC.delegate = self
        present(popupVC, animated: true, completion: nil)
        
    }
}
extension ProfilePlaylistVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if status!{
            return playlistArray.count
        }else{
            if playlistArray.isEmpty{
                return AppInstance.instance.playlistArray?.count ?? 0
                
            }else{
                return playlistArray.count
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SongsTableCells.identifier) as? SongsTableCells
        cell?.selectionStyle = .none
        
        let object = AppInstance.instance.playlistArray?[indexPath.row]
        cell?.btnPlayPause.tag = indexPath.row
        cell?.btnPlayPause.isHidden = true
        cell?.btnMore.tag = indexPath.row
        cell?.btnMore.addTarget(self, action: #selector(didTapSongsMore(sender:)), for: .touchUpInside)
        cell?.bindProfilePlayList(object!, index: indexPath.row)
        return cell!
        
        
    }
    
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
            let vc = R.storyboard.playlist.showPlaylistDetailsVC()
            vc?.ProfilePlaylistObject = AppInstance.instance.playlistArray?[indexPath.row]
                  self.navigationController?.pushViewController(vc!, animated:true)
    
}
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       
        let headerView = tableView.dequeueReusableCell(withIdentifier: AssigingOrderHeaderTableCell.identifier) as!  AssigingOrderHeaderTableCell
        headerView.lblTotalSongs.text = "\(AppInstance.instance.likedArray.count ) Songs"
        headerView.btnArrangOrder.addTarget(self, action: #selector(didTapFilterData(sender:)), for: .touchUpInside)
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      
        return 43
        
    }
}
    extension ProfilePlaylistVC: EmptyDataSetSource, EmptyDataSetDelegate {
        
        func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
            return NSAttributedString(string: "No Liked songs", attributes: [NSAttributedString.Key.font : R.font.poppinsBold(size: 30) ?? UIFont.boldSystemFont(ofSize: 24)])
        }
        func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
            return NSAttributedString(string: "You have not liked any song yet! ", attributes: [NSAttributedString.Key.font : R.font.poppinsMedium(size: 14) ?? UIFont.systemFont(ofSize: 14)])
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
extension ProfilePlaylistVC:FilterTable {
    func filterData(order: Int) {
        let order = FilterData(rawValue: order)
        switch order {
        case .ascending:
            playlistArray = playlistArray.sorted(by: { $0.name ?? "" > $1.name ?? "" })
            tableView.reloadData()
            break
        case .descending:
            playlistArray = playlistArray.sorted(by: { $0.name ?? "" < $1.name ?? "" })
            tableView.reloadData()
            break
        case .dateAdded:
            playlistArray = playlistArray.sorted(by: { $0.name ?? "" > $1.name ?? "" })
            tableView.reloadData()
            break
        case .none:
            break
        }
        
    }
}
extension ProfilePlaylistVC:PopupViewControllerDelegate {
    func popupViewControllerDidDismissByTapGesture(_ sender: PopupViewController) {
        
    }
}
    extension ProfilePlaylistVC:IndicatorInfoProvider{
        func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
            return IndicatorInfo(title: (NSLocalizedString("Playlist", comment: "Playlist")))
        }
    }
