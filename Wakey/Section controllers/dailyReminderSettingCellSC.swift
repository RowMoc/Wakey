//
//  dailyReminderSettingCellSC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/07/03.
//  Copyright © 2020 Wakey. All rights reserved.
//

import IGListKit
import Foundation


class dailyReminderSettingCellSC: ListSectionController, UNUserNotificationCenterDelegate, settingsDefaultCellDelegate {
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 70)
    }
    
    var dailyReminderIsSet: Bool?
    var dailyReminderTime: Date?
    
    
    enum permsCases {
        case isSetWithoutDate
        case isNotSet
        case isSetWithDate
        case busyDetermining
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(withNibName: String(describing: settingsDefaultCell.self), bundle: Bundle.main, for: self, at: index)
        if let cell = cell as? settingsDefaultCell {
            cell.delegate = self
            cell.iconImageView.image = UIImage(systemName: "bell")!
            cell.titleLabel.text = "Daily alarm reminder notification"
        
            if let dailyReminderIsSet = dailyReminderIsSet {
                if dailyReminderIsSet {
                    if self.dailyReminderTime != nil {
                        self.configSwitchAndButton(cell: cell, state: .isSetWithDate)
                    } else {
                        self.configSwitchAndButton(cell: cell, state: .isSetWithoutDate)
                    }
                } else {
                    self.configSwitchAndButton(cell: cell, state: .isNotSet)
                }
            } else {
                self.configSwitchAndButton(cell: cell, state: .busyDetermining)
                checkNotificationStatus(cell: cell)
                
            }
        }
        return cell
    }
    
    
    func checkNotificationStatus(cell: settingsDefaultCell) {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.getNotificationSettings { (settings) in
            if(settings.authorizationStatus == .authorized) {
                print("Push notification is enabled")
                center.getPendingNotificationRequests { (upcomingNotifRequests) in
                    DispatchQueue.main.async {
                        for notif in upcomingNotifRequests {
                            if notif.identifier == constants.dailyNotificationIdentifier {
                                self.dailyReminderIsSet = true
                                if let trigger = notif.trigger as? UNCalendarNotificationTrigger {
                                    guard let time = trigger.nextTriggerDate() else {
                                        self.configSwitchAndButton(cell: cell, state: .isSetWithoutDate)
                                        return
                                    }
                                    self.dailyReminderTime = time
                                    self.configSwitchAndButton(cell: cell, state: .isSetWithDate)
                                }
                                return
                            }
                        }
                        //if we get here, the user has no daily upcoming reminder
                        self.configSwitchAndButton(cell: cell, state: .isNotSet)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.configSwitchAndButton(cell: cell, state: .isNotSet)
                }
            }
        }
    }
    
    
    func configSwitchAndButton(cell: settingsDefaultCell, state: permsCases) {
        switch state {
        case .isNotSet:
            cell.permissionsSwitch.isOn = false
            cell.permissionsSwitch.isHidden = false
            cell.activityIndicator.stopAnimating()
            return
        case .isSetWithDate:
            cell.permissionsSwitch.isOn = true
            cell.permissionsSwitch.isHidden = false
            cell.activityIndicator.stopAnimating()
//            if let dailyReminderDate = dailyReminderTime {
//                cell.actionButton.setTitle(DateFormatter.localizedString(from:  dailyReminderDate, dateStyle: .none, timeStyle: .short), for: .normal)
//            } else {
//                cell.actionButton.setTitle("Set time", for: .normal)
//            }
//            cell.actionButton.layoutIfNeeded()
            //cell.actionButton.isHidden = false
            return
        case .isSetWithoutDate:
            cell.permissionsSwitch.isOn = true
            cell.permissionsSwitch.isHidden = false
            cell.activityIndicator.stopAnimating()
            //cell.actionButton.setTitle("Set time", for: .normal)
//            cell.actionButton.layoutIfNeeded()
//            cell.actionButton.isHidden = false
            return
        case .busyDetermining:
            cell.permissionsSwitch.isHidden = true
            //cell.actionButton.isHidden = true
            cell.activityIndicator.startAnimating()
        }
    }
    
    
    
    //Delegate methods
    func switchToggled(turnedOn: Bool, cell: settingsDefaultCell) {
        self.configSwitchAndButton(cell: cell, state: .busyDetermining)
        if turnedOn {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.getNotificationSettings { (settings) in
                DispatchQueue.main.async {
                    switch settings.authorizationStatus {
                    case .authorized:
                        //request that the user defines a time they want to be reminded and THEN queue the notifications
                        self.dailyReminderIsSet = true
                        self.configSwitchAndButton(cell: cell, state: .isSetWithoutDate)
                        return
                    case .denied:
                        //redirect user to settings to allow notifs
                        self.dailyReminderIsSet = false
                        self.dailyReminderTime = nil
                        self.configSwitchAndButton(cell: cell, state: .isNotSet)
                        return
                    case .notDetermined:
                        let options: UNAuthorizationOptions
                        if #available(iOS 12.0, *) {
                            options = [.alert, .badge, .sound, .criticalAlert]
                        } else {
                            options = [.alert, .badge, .sound]
                        }
                        center.requestAuthorization(options: [options]) { (granted, error) in
                            // Enable or disable features based on authorization.
                            if error != nil {
                                self.dailyReminderIsSet = nil
                                self.configSwitchAndButton(cell: cell, state: .isNotSet)
                                return
                            } else {
                                if granted {
                                    //QUEUE A DAILY REMINDER
                                    self.dailyReminderIsSet = true
                                    self.configSwitchAndButton(cell: cell, state: .isSetWithoutDate)
                                    return
                                    
                                } else {
                                    self.dailyReminderIsSet = true
                                    self.dailyReminderTime = nil
                                    self.configSwitchAndButton(cell: cell, state: .isNotSet)
                                    return
                                }
                            }
                        }
                        break
                    default:
                        self.dailyReminderTime = nil
                        self.dailyReminderIsSet = false
                        self.configSwitchAndButton(cell: cell, state: .isNotSet)
                        return
                    }
                    
                }
            }
        } else {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.getNotificationSettings { (settings) in
                DispatchQueue.main.async {
                    if(settings.authorizationStatus == .authorized) {
                        center.removePendingNotificationRequests(withIdentifiers: [constants.dailyNotificationIdentifier])
                        self.dailyReminderTime = nil
                        self.dailyReminderIsSet = false
                        self.configSwitchAndButton(cell: cell, state: .isNotSet)
                    } else {
                        self.dailyReminderTime = nil
                        self.dailyReminderIsSet = false
                        self.configSwitchAndButton(cell: cell, state: .isNotSet)
                    }
                }
            }
        }
    }
    
    func actionButtonPressed(cell: settingsDefaultCell) {
        //Present a time picker to allow the user to select the time they want their notifcation to be set
    }
    
    
    public override func didUpdate(to object: Any) {
    }
    
    public override func didSelectItem(at index: Int) {
    }
   
    
}




