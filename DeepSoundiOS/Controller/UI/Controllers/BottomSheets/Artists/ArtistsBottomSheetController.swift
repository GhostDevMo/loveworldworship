//
//  ArtistsBottomSheetController.swift
//  DeepSoundiOS
//
//  Created by Mac Pro on 02/09/2022.
//  Copyright © 2022 Moghees Idrees. All rights reserved.
//

import UIKit
import PanModal
class ArtistsBottomSheetController: UIViewController,PanModalPresentable {
    @IBOutlet weak var lblAlbumCount: UILabel!
    @IBOutlet weak var lblSongCount: UILabel!
    @IBOutlet weak var lblArtistName: UILabel!
    @IBOutlet weak var imgArtist: UIImageView!
    private var artistData:ArtistModel.Datum
    var panScrollable: UIScrollView?
    var isShortFormEnabled = true
    var shortFormHeight: PanModalHeight {
        return isShortFormEnabled ? .contentHeight(450) : longFormHeight
    }
    
    init(artist: ArtistModel.Datum) {
        artistData = artist
        super.init(nibName: ArtistsBottomSheetController.name, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if artistData.name  == ""{
            lblArtistName.text = artistData.name
        }else{
            lblArtistName.text =  artistData.username
        }
        let url = URL.init(string:artistData.avatar ?? "" )
            imgArtist.sd_setImage(with: url , placeholderImage:R.image.imagePlacholder())
    }
    @IBAction func didTapPlay(_ sender: Any) {
        
    }
    @IBAction func didTapPlayNext(_ sender: Any) {
        
    }
    @IBAction func didTapAddToQueue(_ sender: Any) {
    }
    @IBAction func didTapAddToPlayList(_ sender: Any) {
    }
    @IBAction func didTapShare(_ sender: Any) {
    }
}
