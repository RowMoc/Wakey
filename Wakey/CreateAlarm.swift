//
//  CreateAlarm.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/29.
//  Copyright © 2020 Wakey. All rights reserved.
//

import Foundation
import AVFoundation
import Firebase
import SDWebImage
import Alamofire


//Download alarm audios AND sender profile pics locally and stores them in notifcation content objects
//to be scheduled as notifications
func getAudios(fetchedAlarms: [receivedAlarm], timeToFire: Date,settingAlarmProgress: CGFloat, settingAlarmProgressLabel: UILabel, completion: @escaping (Error?, [UNNotificationContent?]) -> ()) {
    print("In get audios")
    var notificationsArray = [UNNotificationContent?](repeating: nil, count: fetchedAlarms.count)
    var updatedWhenToFire = timeToFire
    var currProgress = settingAlarmProgress
    let downloadGroup = DispatchGroup()
    for (index, alarm) in fetchedAlarms.enumerated() {
        downloadGroup.enter()
        FirebaseManager.shared.downloadAudioFile(withUrl: alarm.audioUrl, pathPrefix: String(index)) { (error, localUrl) in
            if let error = error {
                //print(error)
                downloadGroup.leave()
                return
            }
            guard let localUrl = localUrl else {
                downloadGroup.leave()
                return
            }
            //75 = remaining progress to go, 0.8/count = addition prog as a ration of the alarms
            let additionalProg1 = 0.8/CGFloat(fetchedAlarms.count)*75.0
            currProgress += additionalProg1
            settingAlarmProgressLabel.text = "Setting your alarm: \(Int(currProgress))%"
            
            fetchedAlarms[index].localAudioUrl = localUrl
            FirebaseManager.shared.downloadImageToLocalUrl(withUrl: fetchedAlarms[index].sender.profilePicUrl, pathPrefix: String(index)) { (imageError, imageLocalUrl) in
                if let imageError = imageError {
                    //print(imageError)
                }
                guard let imageLocalUrl = imageLocalUrl else {
                    downloadGroup.leave()
                    return
                }
                //updateProg
                let additionalProg2 = 0.2/CGFloat(fetchedAlarms.count)*70.0
                currProgress += additionalProg2
                settingAlarmProgressLabel.text = "Setting your alarm: \(Int(currProgress))%"
                
                //Record in local data that these notifications have been set
                let asset = AVURLAsset(url: localUrl, options: nil)
                let audioDuration = asset.duration.seconds
                
                
                notificationsArray[index] = scheduleLocalNotification(forAlarm: fetchedAlarms[index], timeToFire: updatedWhenToFire, totalAlarms: fetchedAlarms.count, index: index + 1, localImageUrl: imageLocalUrl)
                
                updatedWhenToFire = Calendar.current.date(byAdding: .second, value: Int(audioDuration + 1), to: updatedWhenToFire)!
                
                downloadGroup.leave()
            }
        }
    }
    downloadGroup.notify(queue: DispatchQueue.main) {
        settingAlarmProgressLabel.text = "Setting your alarm: 95%"
        completion(nil, notificationsArray)
    }
    
}


func scheduleLocalNotification(forAlarm: receivedAlarm, timeToFire: Date, totalAlarms: Int, index: Int, localImageUrl: URL?) -> UNNotificationContent {
     var audioLengthString = ""
    if let length = forAlarm.audioLength {
        audioLengthString = " (" + String(Int(length)) + "s)"
    }
    let audioDirectoryArray = forAlarm.localAudioUrl!.absoluteString.components(separatedBy: "/")
    let imageDirectoryArray = forAlarm.localAudioUrl!.absoluteString.components(separatedBy: "/")
    let content = UNMutableNotificationContent()
    content.title = "Wakey wakey! (\(index)/\(totalAlarms))"
    content.body = "Playing \(forAlarm.sender.username)'s wakey message!" + audioLengthString
    content.categoryIdentifier = "myNotificationCategory"
    if localImageUrl != nil {
        do {
            if let attachment = try UNNotificationAttachment(identifier: imageDirectoryArray.last! ,url: localImageUrl!, options: nil) as UNNotificationAttachment? {
                content.attachments = [attachment]
            }
                
        } catch let error {
            //print(error)
        }
    }
    let crit = UNNotificationSound.criticalSoundNamed(UNNotificationSoundName(rawValue: audioDirectoryArray.last!))
    //content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: audioDirectoryArray.last!))
    content.sound = crit
    content.userInfo = [constants.scheduledAlarms.audioIDKey: forAlarm.audioID, constants.scheduledAlarms.whenToFireKey: timeToFire, constants.scheduledAlarms.localAudioUrlKey: forAlarm.localAudioUrl?.absoluteString as Any, constants.scheduledAlarms.senderIDKey: forAlarm.sender.userID, constants.scheduledAlarms.senderUsernameKey: forAlarm.sender.username, constants.scheduledAlarms.senderProfilePicUrlKey: forAlarm.sender.profilePicUrl, constants.scheduledAlarms.timeSentKey: forAlarm.timeSent]
    return content
}


