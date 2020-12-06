//
//  goToSleepCellSC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/10.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit
import IGListKit
import SDWebImage
import AVFoundation
import EasyTipView
import Firebase

class goToSleepCellSC: ListSectionController, goToSleepVCDelegate, goToSleepCellDelegate, AVAudioPlayerDelegate, EasyTipViewDelegate {
    
    
    
    var alarm: currentAlarm!
    var reminderHasBeenShown = false
    
    override func sizeForItem(at index: Int) -> CGSize {
        let guide = self.viewController!.view.safeAreaLayoutGuide
        let height = guide.layoutFrame.size.height
        return CGSize(width: UIScreen.main.bounds.width, height: height)
    }
    
    var thisCell: goToSleepCell!
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(withNibName: String(describing: goToSleepCell.self), bundle: Bundle.main, for: self, at: index)
        if let cell = cell as? goToSleepCell {
            cell.currentTimeLabel.text = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short)
            cell.currentDateLabel.text = DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .none)
            cell.delegate = self
            self.thisCell = cell
            self.prepareLockButtonAudio()
            cell.contentView.isUserInteractionEnabled = true
            if let vc = self.viewController as? goToSleepVC {
                vc.delegate = self
            }
            if (alarm.isSet) {
                let alarmText = DateFormatter.localizedString(from: alarm.alarmTime!, dateStyle: .none, timeStyle: .short)
                cell.setAlarmButton.setTitle(alarmText, for: .normal)
                cell.lockScreenButton.isHidden = false
            } else {
                cell.setAlarmButton.setTitle("Set alarm", for: .normal)
                cell.lockScreenButton.isHidden = true
            }
            self.addHelper(cell: cell)
            self.setExitButton(cell: cell)
        }
        return cell
    }
    
    func setExitButton(cell: goToSleepCell) {
        let attrTitle = createStringWithEmoji(text: "Exit sleep mode ", fontSize: 15, emojiName: "awake_face", textColor: UIColor(named: "AppRedColor")!, font: "Avenir-heavy")
        cell.exitSleepModeButton.setAttributedTitle(attrTitle, for: .normal)
    }
    
    
    
    var alarmHelper: EasyTipView!
    var exitHelper: EasyTipView!
    
    func addHelper(cell: goToSleepCell) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if (!UserDefaults.standard.bool(forKey: constants.helperVCKeys.hasHelpedAlarmScreen)) {
                self.alarmHelper = EasyTipView(text: "Set and edit your alarm from here", delegate: self)
                self.alarmHelper.show(animated: true, forView: cell.setAlarmButton,withinSuperview: cell.contentView)
                
                self.exitHelper = EasyTipView(text: "Tap here to deactivate your alarm and return to the home screen", delegate: self)
            }
        }
        
    }
    
    public override func didUpdate(to object: Any) {
        self.alarm = object as? currentAlarm
    }
    
    public override func didSelectItem(at index: Int) {
        //dim / un-dim screen
        
    }
    
    var lockScreenTip: EasyTipView!
    
    func setAlarm(timeSet: Date, cell: goToSleepCell) {
        self.alarm.isSet = true
        cell.lockScreenButton.isHidden = false
        if (!UserDefaults.standard.bool(forKey: constants.helperVCKeys.hasHelpedAlarmScreen)) {
            lockScreenTip = EasyTipView(text: "Just before bed, tap this button to dim your screen and allow your wakey messages to play in the morning!", delegate: self)
            lockScreenTip.show(animated: true, forView: cell.lockScreenButton, withinSuperview: cell.contentView)
        }
        if (timeSet != alarm.alarmTime ) {
            self.alarm.alarmTime = timeSet
            //use network method to update alarm
        }
    }
    
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        if (tipView == lockScreenTip) {
            UserDefaults.standard.set(true, forKey: constants.helperVCKeys.hasHelpedAlarmScreen)
        } else if (tipView == alarmHelper) {
            exitHelper.show(animated: true, forView: thisCell.exitSleepModeButton, withinSuperview: thisCell.contentView)
        }
    }

    
    
    func exitSleepMode() {
        //print("segue away?")
        (self.viewController as! goToSleepVC).userDidExitSleepMode()
        //(self.viewController as! goToSleepVC).homeViewController.loadRecordingUI()
        self.viewController?.dismiss(animated: true, completion: nil)
    }
    
    
    var lockButtonAudio = AVAudioPlayer()
    
    func prepareLockButtonAudio() {
        do {
            lockButtonAudio.delegate = self
            lockButtonAudio = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "lockSound", ofType: "m4a")!))
            lockButtonAudio.prepareToPlay()
        } catch {
            //print(error)
        }
    }
    
    var haveScheduledQuery = false
    
    
    func shouldShowReminder() -> Bool {
        let reminderCount = UserDefaults.standard.integer(forKey: constants.alarmScreenHelpers.sleepModeReminder)
        if !reminderHasBeenShown && (reminderCount < 4) {
            return true
        }
        return false
    }
    
    func showReminder() {
        let messageStr = "Since Apple doesn't allow us to schedule alarms with custom audio (i.e. voice notes from your friends) that play when your phone is locked, you'll need to hit the sleep button and leave your phone unlocked (make sure you're not on airplane mode!) thereafter in order to receive your wakey messages. Don't worry, this won't deplete your battery, and we'll dim the screen for you!"
        configurePopUp(backgroundColor: UIColor.init(named: "goToSleepBackgroundColor")!,textColor: .white)
        presentPopUpWith(title: "IMPORTANT NOTE", message: messageStr, viewController: (self.viewController as! goToSleepVC), image: UIImage(named: "sleepPic")!)
        let curCount = UserDefaults.standard.integer(forKey: constants.alarmScreenHelpers.sleepModeReminder)
        UserDefaults.standard.set(curCount + 1, forKey: constants.alarmScreenHelpers.sleepModeReminder)
        reminderHasBeenShown = true
        
    }
    
    func lockScreenPressed() {
        if let vc = self.viewController as? goToSleepVC {
            if !vc.inSleepMode {
                //decide whether to show the reminder
                if shouldShowReminder() {
                    showReminder()
                    return
                }
                vc.inSleepMode = true
                UIApplication.shared.isIdleTimerDisabled = true
                UIScreen.main.brightness = CGFloat(0)
                lockButtonAudio.play()
                if !haveScheduledQuery  {
                    thisCell.setAlarmButton.isUserInteractionEnabled = false
                    haveScheduledQuery = true
                    DispatchQueue.main.async {
                        FirebaseManager.shared.getCurrentUser { (error, user) in
                            if let user = user {
                                Analytics.logEvent("sleep", parameters: [ "username": user.username])
                            }
                        }
                    }
                    //(self.viewController as! goToSleepVC).alarmActivated(time: alarm.alarmTime!)
                }
            } else {
                //vc.lightUpScreen()
            }
        }
        
    }
    
    
    
    
    
    
    func userHasWokenUp() {
        //alarm has run we must hide button and reset to start state
        self.haveScheduledQuery = false
        self.thisCell.lockScreenButton.isHidden = true
        self.thisCell.setAlarmButton.setTitle("Set alarm", for: .normal)
        self.alarm.isSet = false
        self.thisCell.setAlarmButton.isUserInteractionEnabled = true
    }
    
    
    
}

