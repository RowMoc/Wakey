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
        //check to see if this is a default alarm (default already has local audio url)
        //if default, we don't need to download anything
        if let alreadyStoredLocalUrl = alarm.localAudioUrl {
            let audioDuration = AVURLAsset(url: alreadyStoredLocalUrl, options: nil).duration.seconds
            let defaultImgUrl = Bundle.main.url(forResource: "wakeyProfilePic", withExtension: "png")
           
            notificationsArray[index] = scheduleLocalNotification(forAlarm: fetchedAlarms[index], audioLength: audioDuration, totalAlarms: fetchedAlarms.count, index: index + 1, localImageUrl: defaultImgUrl)
            downloadGroup.leave()
            continue
        }
        
        
        
        FirebaseManager.shared.downloadAudioFile(withUrl: alarm.audioUrl, isMp3: (alarm.soundBite != nil), pathPrefix: String(index)) { (error, localUrl) in
            if let error = error {
                //print(error)
                downloadGroup.leave()
                return
            }
            guard let localUrl = localUrl else {
                downloadGroup.leave()
                return
            }
            
            fetchedAlarms[index].localAudioUrl = localUrl
            
            FirebaseManager.shared.downloadImageToLocalUrl(withUrl: fetchedAlarms[index].sender.profilePicUrl, pathPrefix: String(index)) { (imageError, imageLocalUrl) in
                if let imageError = imageError {
                    //print(imageError)
                }
                guard let imageLocalUrl = imageLocalUrl else {
                    downloadGroup.leave()
                    return
                }
                
                //Record in local data that these notifications have been set
                let asset = AVURLAsset(url: localUrl, options: nil)
                let audioDuration = asset.duration.seconds
                
                
                notificationsArray[index] = scheduleLocalNotification(forAlarm: fetchedAlarms[index], audioLength: audioDuration, totalAlarms: fetchedAlarms.count, index: index + 1, localImageUrl: imageLocalUrl)
                
                //updatedWhenToFire = Calendar.current.date(byAdding: .second, value: Int(audioDuration + 1), to: updatedWhenToFire)!
                
                downloadGroup.leave()
            }
        }
    }
    downloadGroup.notify(queue: DispatchQueue.main) {
        settingAlarmProgressLabel.text = "Setting your alarm: 95%"
        completion(nil, notificationsArray)
    }
    
}





func scheduleLocalNotification(forAlarm: receivedAlarm, audioLength: Double, totalAlarms: Int, index: Int, localImageUrl: URL?) -> UNNotificationContent {
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
    if let soundBite = forAlarm.soundBite {
        content.userInfo = [constants.scheduledAlarms.audioIDKey: forAlarm.audioID, constants.scheduledAlarms.alarmLengthKey: audioLength, constants.scheduledAlarms.localAudioUrlKey: forAlarm.localAudioUrl?.absoluteString as Any, constants.scheduledAlarms.senderIDKey: forAlarm.sender.userID, constants.scheduledAlarms.senderUsernameKey: forAlarm.sender.username, constants.scheduledAlarms.senderProfilePicUrlKey: forAlarm.sender.profilePicUrl, constants.scheduledAlarms.timeSentKey: forAlarm.timeSent, constants.scheduledAlarms.alarmCanBeLikedKey: forAlarm.canBeLiked, constants.scheduledAlarms.alarmHasBeeenLikedKey: forAlarm.hasBeenLiked, constants.scheduledAlarms.hasSoundBiteKey: true, constants.scheduledAlarms.soundBiteIDKey: soundBite.objectID, constants.scheduledAlarms.soundBiteTitleKey: soundBite.title, constants.scheduledAlarms.soundBiteCategoryKey: soundBite.category, constants.scheduledAlarms.soundBiteImageUrlKey: soundBite.imageUrl, constants.scheduledAlarms.soundBiteIsExplicitKey: soundBite.explicit]
    } else {
        content.userInfo = [constants.scheduledAlarms.audioIDKey: forAlarm.audioID, constants.scheduledAlarms.alarmLengthKey: audioLength, constants.scheduledAlarms.localAudioUrlKey: forAlarm.localAudioUrl?.absoluteString as Any, constants.scheduledAlarms.senderIDKey: forAlarm.sender.userID, constants.scheduledAlarms.senderUsernameKey: forAlarm.sender.username, constants.scheduledAlarms.senderProfilePicUrlKey: forAlarm.sender.profilePicUrl, constants.scheduledAlarms.timeSentKey: forAlarm.timeSent, constants.scheduledAlarms.alarmCanBeLikedKey: forAlarm.canBeLiked, constants.scheduledAlarms.alarmHasBeeenLikedKey: forAlarm.hasBeenLiked, constants.scheduledAlarms.hasSoundBiteKey: false]
    }
    return content
}



func tryDownloadFromInternetSite() {
    let urlString = "http://www.moviesoundclips.net/movies1/getsmart/bomb.mp3"

    let destination: DownloadRequest.Destination = { _, _ in
        let fileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("bombp.mp3")
        return (fileUrl, [.removePreviousFile, .createIntermediateDirectories])
    }

    AF.download(urlString, to: destination).response { response in
        print(response)
        
        if let destinationUrl = response.fileURL {
            //print("downloaded VN successfully with local url:")
            //print(destinationUrl)
            print(destinationUrl.absoluteString)
        } else {
            print("Failed to download audio")
        }
    }
}

