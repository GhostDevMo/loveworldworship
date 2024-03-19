//
//  BottomSheetPresentationController.swift
//  UIBottomSheet
//
//  Created by Bruno Vieira on 01/05/23.
//

import UIKit

class BottomSheetPresentationController: UIPresentationController {
    var blurStyle: UIBlurEffect.Style = .dark
    
    private var tapGestureRecognizer: UITapGestureRecognizer!
    private var backgroundView: UIView!
    
    // MARK: - Init
    
    override init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?
    ) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissController))
        self.backgroundView = setupBackgroundView()
    }
    
    // MARK: - Setup
    
    private func setupBackgroundView() -> UIView {
        let backgroundView = UIView()
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.isUserInteractionEnabled = true
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.72)
        backgroundView.addGestureRecognizer(tapGestureRecognizer)
        
        return backgroundView
    }
    
    // MARK: - Presentation
    
    /// Get the frame of the sheet based on the containerView available space.
    override var frameOfPresentedViewInContainerView: CGRect {
        let sheetWidth = containerView!.frame.width
        let sheetHeight = presentedView!.frame.height
        
        return CGRect(
            origin: CGPoint(x: 0, y: containerView!.frame.height - sheetHeight),
            size: CGSize(width: sheetWidth, height: sheetHeight)
        )
    }
    
    override func presentationTransitionWillBegin() {
        self.backgroundView.alpha = 0
        self.containerView?.addSubview(backgroundView)
        self.presentedViewController.transitionCoordinator?.animate(
            alongsideTransition: { _ in
                self.backgroundView.alpha = 1
            }
        )
    }
    
    override func dismissalTransitionWillBegin() {
        self.presentedViewController.transitionCoordinator?.animate(
            alongsideTransition: { _ in
                self.backgroundView.alpha = 0
            },
            completion: { _ in
                self.backgroundView.removeFromSuperview()
            }
        )
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        // stub
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
        backgroundView.frame = containerView!.bounds
    }
    
    // MARK: - Actions
    
    @objc func dismissController() {
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
}
