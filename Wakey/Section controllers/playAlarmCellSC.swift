//
//  playAlarmCellSC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/11.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit
import IGListKit
import SDWebImage
import AVFoundation
import EasyTipView
import UIImageColors

class playAlarmCellSC: ListSectionController {
    
    
    var alarm: receivedAlarm!
    var previousBGTintColor: UIColor?
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: (self.viewController?.view.bounds.height)!)
    }
    
    
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(withNibName: String(describing: playAlarmCell.self), bundle: Bundle.main, for: self, at: index)
        if let cell = cell as? playAlarmCell {
            cell.usernameLabel.text = alarm.sender.username
            //            cell.skipButton.isEnabled = true
            //            cell.progressBar.isHidden = false
            cell.pausePlayButton.setTitle("Pause", for: .normal)
            cell.pausePlayButton.layoutIfNeeded()
            cell.profilePicImage.contentMode = .scaleAspectFill
            cell.progressBar.progressValue = 0
            cell.sectionController = self
            if let previousBGTintColor = previousBGTintColor {
                cell.tintBackgroundImage(color: previousBGTintColor, animate: false)
            }
            if (alarm.sender.profilePicUrl != "") {
                cell.profilePicImage.sd_setImage(with: URL(string: alarm.sender.profilePicUrl), placeholderImage: UIImage(named:"wakeyProfilePic")!, options: [.delayPlaceholder]) { (proPic, error, cacheType, url) in
                    if let proPic = proPic {
                        proPic.getColors { colors in
                            guard let colors = colors else {
                                return
                            }
                            cell.tintBackgroundImage(color: colors.detail, animate: true)
                        }
                    }
                }
            } else {
                cell.profilePicImage.sd_setImage(with: URL(string: "https:firebasestorage.googleapis.com/v0/b/wakey-3bf93.appspot.com/o/user_profile_pics%2FPrRXLnGrjLNC3x5Hdg5kqqfXMTJ2.jpg?alt=media&token=b95a4ee2-1f20-4cf5-b46d-ee06eab32543"), placeholderImage: UIImage(named:"wakeyProfilePic")!, options: [.delayPlaceholder]){ (proPic, error, cacheType, url) in
                    if let proPic = proPic {
                        proPic.getColors { colors in
                            guard let colors = colors else {
                                return
                            }
                            cell.tintBackgroundImage(color: colors.detail, animate: true)
                        }
                    }
                }
                //https://firebasestorage.googleapis.com/v0/b/wakey-3bf93.appspot.com/o/user_profile_pics%2FPrRXLnGrjLNC3x5Hdg5kqqfXMTJ2.jpg?alt=media&token=b95a4ee2-1f20-4cf5-b46d-ee06eab32543
                //cell.profilePicImage.image = UIImage(named: "wakeyProfilePic")!
//                UIView.transition(with: cell.backgroundImageView, duration: 0.5, options: [.beginFromCurrentState, .transitionCrossDissolve], animations: { () -> Void in
//                    cell.tintBackgroundImage(color: UIColor(named: "AppRedColor")!, animate: true)
//                }, completion: nil)
                
                
            }
            cell.activityIndicator.startAnimating()
            if (!UserDefaults.standard.bool(forKey:constants.helperVCKeys.hasHelpedPresentingAlarmScreen)) {
                UserDefaults.standard.set(true, forKey: constants.helperVCKeys.hasHelpedPresentingAlarmScreen)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    EasyTipView.show(forView: cell.swipeUpForReactionsLabel ,withinSuperview: self.viewController?.view,
                                     text: "Swipe up to send a reaction back to " +  self.alarm.sender.username)
                }
            }
            (self.viewController as! playAlarmVC).configAndPlay(localAudioUrl: alarm.localAudioUrl!, alarmAudioID: alarm.audioID, cell: cell)
            
        }
        return cell
    }
    
    
    
    
    public override func didUpdate(to object: Any) {
    }
    
    public override func didSelectItem(at index: Int) {
    }
    
    func pausePlayPressed() {
        (self.viewController as! playAlarmVC).pausePlayWasPressed()
    }
    
    
    func rewindButtonPressed() {
        (self.viewController as! playAlarmVC).rewindWasPressed()
    }
    
    func fastForwardPressed() {
        (self.viewController as! playAlarmVC).fastForwardWasPressed()
    }
    
    
    func userDidSwipeToReact(cell:playAlarmCell) {
        //print("hears swipe gesture")
        (self.viewController as! playAlarmVC).userDidSwipeToReact(duringAlarm: alarm)
    }
    
    
    func userDidPressExit() {
        (self.viewController as! playAlarmVC).userDidExit()
    }
    
}
