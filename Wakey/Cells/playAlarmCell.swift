//
//  playAlarmCell.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/11.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit
import LinearProgressBar
import NVActivityIndicatorView

class playAlarmCell: UICollectionViewCell, UIGestureRecognizerDelegate{

    @IBOutlet weak var swipeUpForReactionsLabel: UILabel!
    @IBOutlet weak var exitButton: UIButton!
    
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    @IBOutlet weak var fastForwardButton: UIButton!
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var profilePicImage: RoundedProfilePic!
    
    @IBOutlet weak var pausePlayButton: UIButton!
    
    @IBOutlet weak var progressBar: LinearProgressBar!
    
    @IBOutlet weak var progressText: UILabel!
    
    @IBOutlet weak var timeSentLabel: UILabel!
    
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var swipeForReactView: UIView!
    
    var sectionController: playAlarmCellSC!
    
    var swipeUp: UISwipeGestureRecognizer!
    
    var backgroundImageView: UIImageView!
    
    @IBOutlet weak var soundBiteShadowView: UIView!
    @IBOutlet weak var soundBiteDetailsView: UIView!
    
    @IBOutlet weak var sbImageView: UIImageView!
    @IBOutlet weak var sbTitle: UILabel!
    
    @IBOutlet weak var sbCategory: UILabel!
    
    
    @IBOutlet weak var soundBiteImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicator.startAnimating()
        pausePlayButton.layer.cornerRadius = 8
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipedUp))
        swipeDown.direction = .down
        self.contentView.addGestureRecognizer(swipeDown)
        //set up
        configBGImageView()
        swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeUp.direction = .up
        swipeForReactView.isUserInteractionEnabled = true
        self.swipeForReactView.addGestureRecognizer(swipeUp)
        swipeUp.delegate = self
        sbImageView.layer.cornerRadius = 7
        sbImageView.clipsToBounds = true
        configureShadow()
        
    }
    
    func configBGImageView() {
        backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
        backgroundImageView.backgroundColor = UIColor(named: "collectionViewBackground")
        backgroundImageView.contentMode = .scaleAspectFill
        
        let origImage = UIImage(named: "onboardingBackground")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        backgroundImageView.image = tintedImage
        backgroundImageView.tintColor = .clear
        backgroundImageView.isHidden = true
        self.insertSubview(backgroundImageView, at: 0)
    }
    
    func tintBackgroundImage(color: UIColor, animate: Bool) {
        self.backgroundImageView.isHidden = false
        if animate {
            UIView.transition(with: self.backgroundImageView, duration: 0.25, options: [.beginFromCurrentState, .transitionCrossDissolve], animations: { () -> Void in
                self.backgroundImageView.tintColor = color
            }, completion: nil)
        } else {
            self.backgroundImageView.tintColor = color
        }
        
    }
    
    private func configureShadow() {
        soundBiteShadowView.backgroundColor = UIColor.clear
        soundBiteShadowView.layer.shadowColor = UIColor.black.cgColor
        soundBiteShadowView.layer.shadowOffset = CGSize(width: 1, height: 3)
        soundBiteShadowView.layer.shadowOpacity = 0.3
        soundBiteShadowView.layer.shadowRadius = 3.0
    }
    
    var blurEffectView: UIVisualEffectView!
    var reactionView: ReactionsView!
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) {
        sectionController.userDidSwipeToReact(cell: self)
    }
    
    
    @IBAction func pausePlayButtonPressed(_ sender: Any) {
        //print("sc hears it")
        sectionController.pausePlayPressed()
    }
    
    
    
    @IBAction func rewindButtonPressed(_ sender: Any) {
        sectionController.rewindButtonPressed()
    }
    
    @IBAction func fastForwardButtonPressed(_ sender: Any) {
        sectionController.fastForwardPressed()
    }
    
    @objc func swipedUp(gesture: UISwipeGestureRecognizer) {
        sectionController.userDidPressExit()
    }
    
    @IBAction func exitButtonPressed(_ sender: Any) {
        sectionController.userDidPressExit()
    }
    
    
    @IBAction func likeButtonPressed(_ sender: Any) {
        sectionController.didPressLikeButton(cell: self)
    }
    
    
}
