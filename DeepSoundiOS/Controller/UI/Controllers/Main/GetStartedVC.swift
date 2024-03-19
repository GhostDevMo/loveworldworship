//
//  GetStartedVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 14/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import DeepSoundSDK

class GetStartedVC: BaseVC {
    
    //MARK: - Properties -
    @IBOutlet weak var getStartBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var scrollNextBtn: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
        }
    }
    
    var slides:[IntroItem] = []
    var status:Bool = false
    
    //MARK: - Life Cycle Functions -
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getStartBtn.setTitle(NSLocalizedString("Get Started", comment: "Get Started"), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    //MARK: - Selectors -
    @IBAction func getStartedPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if status {
            let vc = R.storyboard.login.genresVC()
            vc?.status = true
            self.navigationController?.pushViewController(vc!, animated: true)
            return
        }
        
        let vc = R.storyboard.login.loginVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func skipToNotLoggedInStoryBoard(_ sender: UIButton) {
        self.view.endEditing(true)
        if status {
            let vc = R.storyboard.login.genresVC()
            vc?.status = true
            self.navigationController?.pushViewController(vc!, animated: true)
            return
        }
        let vc = R.storyboard.dashboard.tabBarNav()
        self.appDelegate.window?.rootViewController = vc
    }
    
    @IBAction func moveToNextPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        scrollToNextSlide()
    }
}

//MARK: - Helper Functions -
extension GetStartedVC {
    func setupUI(){
        slides = createSlides()
        setupSlideScrollView(slides: slides)
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        view.bringSubviewToFront(pageControl)
        self.scrollNextBtn.layer.cornerRadius = self.scrollNextBtn.frame.height / 2
        self.getStartBtn.isHidden = true
        
    }
    
    private func createSlides() -> [IntroItem] {
        let slide1:IntroItem = Bundle.main.loadNibNamed("IntroItemView", owner: self, options: nil)?.first as! IntroItem
        slide1.imageLabel.image = UIImage(named: "bgWalkthrough")
        slide1.image2Label.isHidden = true
        slide1.firstLabel.text = (NSLocalizedString("Listen to the best\n audio & music with\n deepsound now!", comment: ""))
        
        let slide3:IntroItem = Bundle.main.loadNibNamed("IntroItemView", owner: self, options: nil)?.first as! IntroItem
        slide3.image2Label.image = UIImage(named: "bgWalkthrough2")
        slide3.imageLabel.isHidden = true
        slide3.firstLabel.text = NSLocalizedString("We provide a better\n audio experience\n than others", comment: "")
        
        return [slide1,slide3]
    }
    
    private func setupSlideScrollView(slides : [IntroItem]) {
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height)
        scrollView.isPagingEnabled = true
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
            scrollView.addSubview(slides[i])
        }
    }
    
    func scrollToNextSlide() {
        let cellSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        let contentOffset = scrollView.contentOffset
        scrollView.scrollRectToVisible(CGRect(x: contentOffset.x + cellSize.width, y: contentOffset.y, width: cellSize.width, height: cellSize.height), animated: true)
    }
    func scrollToPresviousSlide() {
        let cellSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        let contentOffset = scrollView.contentOffset
        scrollView.scrollRectToVisible(CGRect(x: contentOffset.x - cellSize.width, y: contentOffset.y, width: cellSize.width, height: cellSize.height), animated: true)
    }
    
    func showButton() {
        UIView.animate(withDuration: 0.3, delay: 0.3, options: .transitionFlipFromTop, animations: {
            self.getStartBtn.alpha = 1.0
        })
    }
    
    func hideButton() {
        UIView.animate(withDuration: 0.3, delay: 0.3, options: .transitionFlipFromBottom, animations: {
            self.getStartBtn.alpha = 0.0
        })
    }
}

//MARK: - UIScrollView Delegate Methods -
extension GetStartedVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 || scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0
        }
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
        if pageControl.currentPage == 0 {
            self.hideButton()
            self.scrollNextBtn.isHidden = false
        } else if pageControl.currentPage == 1 {
            self.scrollNextBtn.isHidden = true
            self.showButton()
            self.getStartBtn.isHidden = false
        }
    }
    
    func scrollView(_ scrollView: UIScrollView, didScrollToPercentageOffset percentageHorizontalOffset: CGFloat) {
        if(pageControl.currentPage == 0) {
            let pageUnselectedColor: UIColor = fade(fromRed: 255/255, fromGreen: 255/255, fromBlue: 255/255, fromAlpha: 1, toRed: 103/255, toGreen: 58/255, toBlue: 183/255, toAlpha: 1, withPercentage: percentageHorizontalOffset * 3)
            pageControl.pageIndicatorTintColor = pageUnselectedColor
            
            let bgColor: UIColor = fade(fromRed: 103/255, fromGreen: 58/255, fromBlue: 183/255, fromAlpha: 1, toRed: 255/255, toGreen: 255/255, toBlue: 255/255, toAlpha: 1, withPercentage: percentageHorizontalOffset * 3)
            slides[pageControl.currentPage].backgroundColor = bgColor
            
            let pageSelectedColor: UIColor = fade(fromRed: 81/255, fromGreen: 36/255, fromBlue: 152/255, fromAlpha: 1, toRed: 103/255, toGreen: 58/255, toBlue: 183/255, toAlpha: 1, withPercentage: percentageHorizontalOffset * 3)
            pageControl.currentPageIndicatorTintColor = pageSelectedColor
        }
    }
    
    
    func fade(fromRed: CGFloat,
              fromGreen: CGFloat,
              fromBlue: CGFloat,
              fromAlpha: CGFloat,
              toRed: CGFloat,
              toGreen: CGFloat,
              toBlue: CGFloat,
              toAlpha: CGFloat,
              withPercentage percentage: CGFloat) -> UIColor {
        let red: CGFloat = (toRed - fromRed) * percentage + fromRed
        let green: CGFloat = (toGreen - fromGreen) * percentage + fromGreen
        let blue: CGFloat = (toBlue - fromBlue) * percentage + fromBlue
        let alpha: CGFloat = (toAlpha - fromAlpha) * percentage + fromAlpha
        // return the fade colour
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
