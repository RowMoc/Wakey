//
//  dailyReiminderTimeCellSC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/07/06.
//  Copyright © 2020 Wakey. All rights reserved.
//

import IGListKit
import Foundation


class dailyReminderTimeCellSC: ListSectionController, UNUserNotificationCenterDelegate, settingActionButtonCellDelegate {
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 70)
    }
    
    var dailyReminderIsSet: Bool?
    var dailyReminderTime: Date?
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(withNibName: String(describing: settingActionButtonCell.self), bundle: Bundle.main, for: self, at: index)
        if let cell = cell as? settingActionButtonCell {
            cell.delegate = self
            cell.iconImageView.image = UIImage(systemName: "bell")!
            cell.activityIndicator.stopAnimating()
            cell.titleLabel.text = "Daily alarm reminder time"
            if let dailyReminderTime = dailyReminderTime {
                cell.actionButton.setTitle(DateFormatter.localizedString(from:  dailyReminderTime, dateStyle: .none, timeStyle: .short), for: .normal)
            } else {
                cell.activityIndicator.startAnimating()
                self.determineDailyReminderTime(cell: cell)
            }
            
        }
        return cell
    }
    
    
    func determineDailyReminderTime(cell: settingActionButtonCell) {
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
                                        //set default time
                                        cell.activityIndicator.stopAnimating()
                                        self.setDefaultTime(cell: cell)
                                        return
                                    }
                                    cell.activityIndicator.stopAnimating()
                                    self.dailyReminderTime = time
                                    cell.actionButton.setTitle(DateFormatter.localizedString(from:  time, dateStyle: .none, timeStyle: .short), for: .normal)
                                }
                                return
                            }
                        }
                        cell.activityIndicator.stopAnimating()
                        //if we get here, the user has no daily upcoming reminder; set default time
                        self.setDefaultTime(cell: cell)
                        return
                    }
                }
            } else {
                DispatchQueue.main.async {
                    cell.activityIndicator.stopAnimating()
                    self.setDefaultTime(cell: cell)
                    return
                    //set time as some default or the time we store in the user object
                }
            }
        }
    }
    
    
    func setDefaultTime(cell: settingActionButtonCell) {
        let defDate =  DateComponents(hour: 7, minute: 0).date
        if let defDate = defDate {
            cell.actionButton.setTitle(DateFormatter.localizedString(from:  defDate, dateStyle: .none, timeStyle: .short), for: .normal)
        }
    }
    
    
    func actionButtonPressed(cell: settingActionButtonCell) {
        //Present a time picker to allow the user to select the time they want their notifcation to be set
    }
    
    
    public override func didUpdate(to object: Any) {
    }
    
    public override func didSelectItem(at index: Int) {
    }
   
    
}

