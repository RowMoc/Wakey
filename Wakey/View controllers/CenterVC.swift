//
//  CenterVC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/23.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit


enum Layout {
    static let buttonContainerHeight: CGFloat = UIScreen.main.bounds.height*0.25
    static let distanceFromBottom: CGFloat = -60.0
    static let lowerCenterButton: CGFloat = 160
    static let leftPanelColor: UIColor = .blue
    static let rightPanelColor: UIColor = .red
    static let centralButtonHeight: CGFloat = 60.0
    static let centerButtonOriginalY: CGFloat = UIScreen.main.bounds.height * (1.0 - 0.28) - (UIScreen.main.bounds.width*0.4)/2
    static let centralButtonLargeHeight: CGFloat = UIScreen.main.bounds.width*0.4
    static let sideButtonHeight: CGFloat = 42.0
    static let sideButtonMargin: CGFloat = 40.0
    static let distanceFromYCenter: CGFloat = 10.0
    static let containerCornerRadius: CGFloat = 16.0
}

enum Panel {
    case top, bottom, left, center, camera, right
}

protocol centerButtonDelegate: class {
    func centerButtonPressed()
    func userDidLogOut()
}


class CenterVC: UIViewController {
    
    weak var delegate: centerButtonDelegate?
    private var centerContainer: UIView!
    private var scrollContainer: UIView!
    //private var buttonsContainer: UIView!
    //private var buttonsController: ButtonsController!
    private var scrollView: UIScrollView!
    private var shouldAnimate: Bool = false
    var bgImageView: UIImageView!
    
    var currTint = UIColor(named: "AppRedColor")!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bgImageView = UIImageView(frame: self.view.frame)
        bgImageView.backgroundColor = UIColor(named: "collectionViewBackground")
        bgImageView.contentMode = .scaleAspectFill
        
        let origImage = UIImage(named: "onboardingBackground")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        bgImageView.image = tintedImage
        bgImageView.tintColor = currTint
        self.view.insertSubview(bgImageView, at: 0)
        setupUI()
        setupButtons()
    }
    
    //to stop users from navigating away from recording screen when recording a vn
    func lockCenterScreen() {
        if scrollView != nil {
            self.scrollView.isScrollEnabled = false
        }
    }
    
    //to allow users to navigate away from recording screen when not recording a vn
    func unlockCenterScreen() {
        if scrollView != nil {
            self.scrollView.isScrollEnabled = true
        }
    }
    
    
    func tintedBackground(color: UIColor?, toDefault: Bool, buttonLabelsToChange: [UIButton?]) {
        if let color = color {
            
            UIView.transition(with: self.bgImageView, duration: 0.25, options: [.beginFromCurrentState, .transitionCrossDissolve], animations: { () -> Void in
                self.bgImageView.tintColor = color
            }, completion: nil)
            for button in buttonLabelsToChange {
                if let button = button {
                    button.setTitleColor(color, for: .normal)
                }
            }
        } else {
            if let tintRn = self.bgImageView.tintColor, tintRn == UIColor(named: "AppGreenColor")!,!toDefault {
                //will change to the default later
                return
            }
            UIView.transition(with: self.bgImageView, duration: 0.25, options: [.beginFromCurrentState, .transitionCrossDissolve], animations: { () -> Void in
                self.bgImageView.tintColor = self.currTint
            }, completion: nil)
            for button in buttonLabelsToChange {
                if let button = button {
                    button.setTitleColor(self.currTint, for: .normal)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    //var centerPanel: ViewController!
    
    private func setupUI() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let centerPanel = (storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController)
        centerPanel.centerVC = self
        
        
        
        let rightPanel = storyboard.instantiateViewController(withIdentifier: "personalProfileVC") as! personalProfileVC
        rightPanel.centerVC = self
        let panController = PanController()
        panController.delegate = self
        let leftPanel = storyboard.instantiateViewController(withIdentifier: "addFriendsMainVC") as! addFriendsMainVC
        leftPanel.centerVC = self
        scrollView = UIScrollView.makeHorizontal(
            with: [leftPanel, centerPanel, rightPanel],
            in: self
        )
        view.addSubview(scrollView)
        scrollView.fit(to: view)
        scrollView.delegate = self
    }
    
    
    
    func configButtonsForRecording(hide: Bool) {
        self.leftButton.isHidden = hide
        self.rightButton.isHidden = hide
    }
    
    //BUTTON STUFF
    
    //weak var delegate: ButtonsDelegate?
    var leftButton = UIButton.make(.left)
    var centerButton = UIButton.make(.center)
    var rightButton = UIButton.make(.right)
    
    private func setupButtons() {
        var distanceFromBottom = Layout.distanceFromBottom as CGFloat
        let buffer = 30 as CGFloat
        if #available(iOS 11.0, *) {
            distanceFromBottom = abs(view.safeAreaInsets.bottom) + buffer
        } else {
            distanceFromBottom = abs(bottomLayoutGuide.length) + buffer
        }
        leftButton.tag = 0
        leftButton.addTarget(self, action: #selector(changePanel(_:)), for: .touchUpInside)
        leftButton.frame = CGRect(x: Layout.sideButtonMargin, y: UIScreen.main.bounds.height - distanceFromBottom - Layout.sideButtonHeight, width: Layout.sideButtonHeight, height: Layout.sideButtonHeight)
        view.addSubview(leftButton)
        
        centerButton.tag = 1
        centerButton.addTarget(self, action: #selector(changePanel(_:)), for: .touchUpInside)
        centerButton.addTarget(self, action: #selector(centerButtonTapped(_:)), for: .touchUpInside)
        
        let centralButtonHeight = Layout.centralButtonLargeHeight
        //print("Center button height:")
        //print(centralButtonHeight)
        let centerButtonY = Layout.centerButtonOriginalY
        centerButton.frame = CGRect(x: UIScreen.main.bounds.width/2 - centralButtonHeight/2, y: centerButtonY, width: centralButtonHeight, height: centralButtonHeight)
        
        view.addSubview(centerButton)
        
        rightButton.tag = 2
        rightButton.addTarget(self, action: #selector(changePanel(_:)), for: .touchUpInside)
         rightButton.frame = CGRect(x: UIScreen.main.bounds.width - Layout.sideButtonMargin - Layout.sideButtonHeight, y: UIScreen.main.bounds.height - distanceFromBottom - Layout.sideButtonHeight, width: Layout.sideButtonHeight, height: Layout.sideButtonHeight)
        view.addSubview(rightButton)
       
    }
    
    @objc private func changePanel(_ sender: UIButton) {
        switch sender.tag {
        case 0: self.scroll(to: .left)
        case 1: self.scroll(to: .center)
        case 2: self.scroll(to: .right)
        default: break
        }
    }
    
    @objc private func centerButtonTapped(_ sender: UIButton) {
        if (scrollView.contentOffset.x == UIScreen.main.bounds.width) {
            delegate?.centerButtonPressed()
        }
        //print("calls this too🤑")
    }
    
    func scroll(to panel: Panel) {
        shouldAnimate = scrollView.contentOffset.x == UIScreen.main.bounds.width || panel == .center
        //print(shouldAnimate)
        switch panel {
        case .left:
            scrollView.setContentOffset(.zero, animated: true)
        case .right:
            scrollView.setContentOffset(CGPoint(x: UIScreen.main.bounds.width * 2, y: 0), animated: true)
        case .center:
            scrollView.setContentOffset(CGPoint(x: UIScreen.main.bounds.width, y: 0), animated: true)
        default:
            break
        }
    }
    
    
    
    func animateButtons(_ offset: CGFloat) {
        let buttonsSpacing: CGFloat = UIScreen.main.bounds.width / 2 - Layout.centralButtonHeight / 2 - Layout.sideButtonMargin * 2 - Layout.sideButtonHeight / 2

        leftButton.center.x = (Layout.sideButtonMargin + Layout.sideButtonHeight) / 2 + buttonsSpacing * abs(offset)
        rightButton.center.x = UIScreen.main.bounds.width - (Layout.sideButtonMargin + Layout.sideButtonHeight) / 2 - buttonsSpacing * abs(offset)
        let toScale = (Layout.centralButtonLargeHeight)/Layout.centralButtonHeight
        centerButton.transform = CGAffineTransform(scaleX: 1/(1 + ((toScale - 1)*abs(offset))), y:1/(1 + ((toScale - 1)*abs(offset))))
        
        let originalCenterY = Layout.centerButtonOriginalY + Layout.centralButtonLargeHeight/2
        let distBetweenCenterAndBotButtons = leftButton.frame.minY -  originalCenterY
        centerButton.center.y = originalCenterY + (distBetweenCenterAndBotButtons * abs(offset))
    }
    
    func recolorButtons(offset: CGFloat) {
        let centerPos = UIScreen.main.bounds.width
        let distAwayFromCenterPos = centerPos - offset
        let ratioAwayFromCenter = CGFloat(abs(distAwayFromCenterPos))/centerPos
        let sideButtonsAlphaValue = 1.0 - ratioAwayFromCenter*0.6
        let centreButtonAlphaValue = 1.0 - ratioAwayFromCenter*0.3
        rightButton.alpha = sideButtonsAlphaValue
        leftButton.alpha = sideButtonsAlphaValue
        centerButton.alpha = centreButtonAlphaValue
    }
    
    
        
        

    func backToCamera() {
        UIView.animate(withDuration: 0.2) { self.present(.center) }
    }
    
    //END OF BUTTON STUFF
    
    
    
}

extension CenterVC: PanControllerDelegate {
    func present(_ panel: Panel) {
        switch panel {
        default:
            scrollContainer.center = view.center
            centerContainer.center = scrollContainer.center
        }
    }
    
    func view(_ panel: Panel) -> UIView {
        switch panel {
        case .center: return scrollContainer
        default: return centerContainer
        }
    }
}

//extension CenterVC: ButtonsDelegate {
//
//}

extension CenterVC: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        shouldAnimate = true
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        changeButtonImages()
        recolorButtons(offset: scrollView.contentOffset.x)
        
        if shouldAnimate {
            let offset = (scrollView.contentOffset.x / view.frame.width) - 1
                //buttonsController.animateButtons(offset)
            self.animateButtons(offset)
        } else {
            let offset = (scrollView.contentOffset.x / view.frame.width) / 2
        }
        
        //hiding the easy tip view when the user scrolls (should fix this in general)
//        if scrollView.contentOffset.x != UIScreen.main.bounds.width {
//            self.centerPanel.currHelperView?.isHidden = true
//        } else {
//            self.centerPanel.currHelperView?.isHidden = false
//        }
    }
    

    func changeButtonImages() {
        let offset = scrollView.contentOffset.x
        if (offset <= UIScreen.main.bounds.width/2) {
            self.leftButton.setImage(UIImage.init(systemName: "person.circle.fill"), for: .normal)
            self.rightButton.setImage(UIImage.init(systemName: "message.circle"), for: .normal)
        } else if (offset >  UIScreen.main.bounds.width/2 && offset < UIScreen.main.bounds.width*1.5) {
            self.leftButton.setImage(UIImage.init(systemName: "person.circle"), for: .normal)
            self.rightButton.setImage(UIImage.init(systemName: "message.circle"), for: .normal)
        } else {
            self.leftButton.setImage(UIImage.init(systemName: "person.circle"), for: .normal)
            self.rightButton.setImage(UIImage.init(systemName: "message.circle.fill"), for: .normal)
        }
    }
    
}

