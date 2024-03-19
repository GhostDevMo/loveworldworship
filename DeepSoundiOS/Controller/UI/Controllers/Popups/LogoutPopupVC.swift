import UIKit
import DeepSoundSDK
import Async
import SwiftEventBus

protocol LogoutPopupVCDelegate {
    func handleLogoutButtonTap()
}

class LogoutPopupVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var logoutLAbel: UILabel!
    @IBOutlet weak var sureLabel: UILabel!
    @IBOutlet weak var pullBar: UIView!
    @IBOutlet weak var borderView: UIView! {
        didSet {
            borderView.layer.cornerRadius = 3.5
            borderView.backgroundColor = UIColor(named: "Label_Colors_Tertiary")
        }
    }
    
    // MARK: - Properties
    
    var sheetHeight: CGFloat = 225
    var sheetBackgroundColor: UIColor = .white
    var sheetCornerRadius: CGFloat = 22
    private var hasSetOriginPoint = false
    private var originPoint: CGPoint?
    var delegate: LogoutPopupVCDelegate?
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER) { result in
            log.verbose("To dismiss the popover")
            
            self.tabBarController?.dismissPopupBar(animated: true, completion: nil)
        }
        SwiftEventBus.onMainThread(self, name: "PlayerReload") { result in
            let stringValue = result?.object as? String
            self.view.makeToast(stringValue)
            log.verbose(stringValue ?? "")
        }
        self.initialConfig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.logoutLAbel.text = NSLocalizedString("Logout", comment: "Logout")
        self.sureLabel.text = NSLocalizedString("Are you sure you want to logout?", comment: "Are you sure you want to logout?")
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetOriginPoint {
            hasSetOriginPoint = true
            originPoint = view.frame.origin
        }
    }
    
    //MARK: - Selectors
            
    // Cancel Button Action
    @IBAction func yesPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true) {
            self.delegate?.handleLogoutButtonTap()
        }
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        view.frame.size.height = sheetHeight
        view.isUserInteractionEnabled = true
        view.backgroundColor = sheetBackgroundColor
        view.roundCorners(corners: [.topLeft, .topRight], radius: sheetCornerRadius)
        self.setPanGesture()
    }
    
    // Set Pan Gesture
    func setPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
    }
    
    // Gesture Recognizer
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        // Not allowing the user to drag the view upward
        guard translation.y >= 0 else { return }
        view.frame.origin = CGPoint(
            x: 0,
            y: self.originPoint!.y + translation.y
        )
        if sender.state == .ended {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
