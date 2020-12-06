//
//  setAlarmVC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/12/05.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit
import AVFoundation

class setAlarmVC: UIViewController, UNUserNotificationCenterDelegate{

    
  
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var middleLabel: UILabel!
    
    var alarmFireDate: Date!
    var homeVC: ViewController!
    var alarmsToSet: [curateListAlarm]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let alarmText = DateFormatter.localizedString(from: self.alarmFireDate, dateStyle: .none, timeStyle: .short).replacingOccurrences(of: " ", with: "")
        self.topLabel.text = "SETTING YOUR " + alarmText + " ALARM"
        configPopUpUI()
    }
    
    func configPopUpUI() {
        shadowView.backgroundColor = UIColor.clear
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
        shadowView.layer.shadowOpacity = 0.4
        shadowView.layer.shadowRadius = 2.0
        popUpView.layer.cornerRadius = 15.0
        popUpView.layer.masksToBounds = true
        popUpView.backgroundColor = UIColor(named: "cellBackgroud")!
    }
    

    
    func repackAlarms() {
        var repackedAlarms: [receivedAlarm] = []
        for alarm in alarmsToSet {
            let alarmObject = ["created_at": alarm.timeReceived, "audio_file_url": alarm.audioFileUrl ,"audio_length": alarm.audioLength, "audio_id": alarm.messageId ] as [String: Any]
            let fetchedAlarm = receivedAlarm(alarm: alarmObject, sender: alarm.associatedProfile, localAudioUrl: nil)
            repackedAlarms.append(fetchedAlarm)
        }
        scheduleNotifications(fetchedAlarms: repackedAlarms)
    }
    
    
    var downloadProgressLabl: UILabel!
    
    func scheduleNotifications(fetchedAlarms: [receivedAlarm]) {
        downloadProgressLabl = UILabel()
        
        getAudios(fetchedAlarms: fetchedAlarms, timeToFire: alarmFireDate, settingAlarmProgress: 25.0, settingAlarmProgressLabel: downloadProgressLabl) { (error, notificationsContent) in
            //We've downloaded th audios and profile pics. Add alarms to local storage
            self.saveAlarmDetailsLocally(fetchedAlarms: fetchedAlarms, notificationsContent: notificationsContent as! [UNNotificationContent])
        }
    }
    
    
    //Save alarm details (audio local urls, user profile pics, names, etc) locally
    func saveAlarmDetailsLocally(fetchedAlarms: [receivedAlarm], notificationsContent: [UNNotificationContent]) {
        UserDefaults.standard.removeObject(forKey: constants.scheduledAlarms.alarmSetForTimeKey)
        UserDefaults.standard.removeObject(forKey: constants.scheduledAlarms.scheduledAlarmDictionaryKey)
        UserDefaults.standard.synchronize()
        //This is where we queue the notiications; it returns the array we want to store
        let localAlarmArray = self.addNotifications(fetchedAlarms: fetchedAlarms, notificationsContent: notificationsContent)
        print("This is the array that we're storing:")
        print(localAlarmArray)
        //Set fire time in user defaults
        UserDefaults.standard.set(alarmFireDate, forKey: constants.scheduledAlarms.alarmSetForTimeKey)
        //store alarms in user defaults
        UserDefaults.standard.set(localAlarmArray, forKey: constants.scheduledAlarms.scheduledAlarmDictionaryKey)
        UserDefaults.standard.synchronize()
        //self.didSetAlarmSuccessfully()
    }
    
    
    func addNotifications(fetchedAlarms: [receivedAlarm], notificationsContent: [UNNotificationContent]) ->  [[String: Any]]{
        var localAlarmArray: [[String: Any]] = []
        var updatedTimeToFire = alarmFireDate
        for (index, content) in (notificationsContent).enumerated() {
            let alarm = fetchedAlarms[index]
            let info = content.userInfo
            let audioID = info[constants.scheduledAlarms.audioIDKey] as? String ?? ""
            //Maybe make defualt value the defaunlt alarm audio path?
            let localAudioUrl = info[constants.scheduledAlarms.localAudioUrlKey] as? String ?? ""
            let senderID = info[constants.scheduledAlarms.senderIDKey] as? String ?? ""
            let username = info[constants.scheduledAlarms.senderUsernameKey] as? String ?? ""
            let profilePicUrl = info[constants.scheduledAlarms.senderProfilePicUrlKey] as? String ?? ""
            let timeSent = info[constants.scheduledAlarms.timeSentKey] as? Date ?? Date()
            localAlarmArray.append([constants.scheduledAlarms.audioIDKey: audioID, constants.scheduledAlarms.localAudioUrlKey: localAudioUrl, constants.scheduledAlarms.senderIDKey: senderID, constants.scheduledAlarms.senderUsernameKey: username, constants.scheduledAlarms.senderProfilePicUrlKey: profilePicUrl, constants.scheduledAlarms.timeSentKey: timeSent])
            let triggerDate = Calendar.current.dateComponents([.year,.month, .day, .hour, .minute, .second], from: updatedTimeToFire!)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            let request = UNNotificationRequest(identifier: alarm.audioID, content: content, trigger: trigger)
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().add(request) { (error) in
                if (error == nil){
                    //Didn't set the alarm sheesh
                }
            }
            var audioDuration = 0.0 as Double
            if let audioLen = alarm.audioLength {
                audioDuration = audioLen
            } else {
                let asset = AVURLAsset(url: alarm.localAudioUrl!, options: nil)
                audioDuration = asset.duration.seconds
            }
            updatedTimeToFire = Calendar.current.date(byAdding: .second, value: Int(audioDuration + 1), to: updatedTimeToFire!)!
        }
        return localAlarmArray
    }
}
