//
//  Constants.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/19.
//  Copyright © 2020 Wakey. All rights reserved.
//

import Foundation

class constants {
    //onboarding check
    static let hasViewedWalkThrough = "hasViewedWalkThrough"
    
    //Daily notifcation identifier
    static let dailyNotificationIdentifier = "dailyNotificationIdentifier"
    static let wakeyMessageNotificationIdentifier = "wakeyMessageNotificationIdentifier"
    
    //Keys for locally stored properties regarding the status of a user's alarm
    struct scheduledAlarms {
        //Dictionary {String: Any}: Dictionary representation of a scheduled alarm, if the user has set one
        static let scheduledAlarmDictionaryKey = "scheduledAlarmDictionaryKey"
        //Dictionary {String: Any}: Dictionary representation of a scheduled alarm, if the user has set one
        static let scheduledAlarmArrayKey = "scheduledAlarmArrayKey"
        //Date: Time alarm was set to go off
        static let alarmSetForTimeKey = "alarmSetForTimeKey"
        static let alarmLengthkey = "alarmLengthkey"
        static let alarmCanBeLikedKey = "alarmCanBeLikedKey"
        static let alarmHasBeeenLikedKey = "alarmHasBeeenLikedKey"
        static let alarmLengthKey = "alarmLength"
        static let audioIDKey = "audioID"
        static let whenToFireKey = "whenToFire"
        static let localAudioUrlKey = "localAudioUrlKey"
        static let senderIDKey = "senderIDKey"
        static let senderUsernameKey = "senderUsernameKey"
        static let senderProfilePicUrlKey = "senderProfilePicUrlKey"
        static let timeSentKey = "timeSentKey"
        
        static let hasSoundBiteKey = "hasSoundBiteKey"
        static let soundBiteIDKey = "soundBiteID"
        static let soundBiteTitleKey = "soundBiteTitle"
        static let soundBiteCategoryKey = "soundBiteCategory"
        static let soundBiteImageUrlKey = "soundBiteImageUrl"
        static let soundBiteIsExplicitKey = "soundBiteIsExplicit"
        
        
    }
    
    struct isLoggedInKeys {
        static let userDocumentHasBeenCreated = "userDocumentHasBeenCreated"
        static let userDocumentID = "userDocumentID"
    }
    
    
    
    struct helperVCKeys {
        static let hasHelpedHomeScreen = "hasHelpedHomeScreen"
        static let hasHelpedAlarmScreen = "hasHelpedAlarmScreen"
        static let hasHelpedSendScreen = "hasHelpedSendScreen"
        static let hasHelpedProfileScreen = "hasHelpedProfileScreen"
        static let hasHelpedPresentingAlarmScreen = "hasHelpedPresentingAlarmScreen"
    }
    
    struct homeScreenHelpers {
        static let recordHelper = "record"
        static let profileHelper = "profile"
        static let alarmHelper = "alarm"
        static let friendHelper = "friend"
    }
    
    struct alarmScreenHelpers {
        static let setAlarmHelper = "setAlarmHelper"
        static let goToSleepButtonHelper = "goToSleepButtonHelper"
        static let sleepModeReminder = "sleepModeReminder"
        static let numberOfAlarmsSet = "numberOfAlarmsSet"
    }
    
    //offline keys for friend label conditions
    struct friendConditions {
        static let sentRequest = "user_did_send_request"
        static let receivedRequest = "user_did_receive_request"
        static let areFriends = "users_are_friends"
        static let arentFriends = "users_are_not_friends"
    }
    
    
    //different sections of the curate alarm list
    struct curateAlarmListHeadings {
        static let unopenedMessage = "unopenedMessage"
        static let likedMessage = "likedMessage"
        static let defaultAlarm = "default"
    }
    
    struct defaultAlarms {
//        self.userID = user["user_id"] as? String ?? ""
//        self.username = user["username"] as? String ?? ""
//        self.fullName = user["full_name"] as? String ?? ""
//        self.profilePicUrl = user["profile_img_url"] as? String ?? ""
//        self.isAsleep = user["asleep"] as? Bool ?? false
//        self.currentAlarm = user["current_alarm"] as? Date ?? nil
//        self.friendshipID = user["friendship_id"] as? String ?? nil
//        self.friendshipStatus = user["friendship_status"] as? String ?? nil
//        self.becameFriends = user["became_friends"] as? Date ?? nil
//        self.phoneNumber = user["phone_num"] as? String ?? ""
//        self.deviceID = user["device_id"] as? String ?? ""
        static let marimbaAlarm = curateListAlarm(associatedProfile: userModel(user: ["username": "Marimbas"]),
                                              timeReceived: Date(),
                                              audioFileUrl: URL.init(fileURLWithPath: Bundle.main.path(forResource: "marimba_alarm", ofType: "m4a")!),
                                              audioLength: 27.0,
                                              description: "Melodic marimbas to start your day 🎶🌅",
                                              messageId: "marimba_alarm",
                                              curateListCategory: constants.curateAlarmListHeadings.defaultAlarm,
                                              isQueued: false, canBeLiked: false,
                                              hasBeenLiked: false)
        
        static let hipAlarm = curateListAlarm(associatedProfile: userModel(user: ["username": "Musical beat"]),
                                              timeReceived: Date(),
                                              audioFileUrl: URL.init(fileURLWithPath: Bundle.main.path(forResource: "hip_ringtone", ofType: "m4a")!),
                                              audioLength: 28.0,
                                              description: "A groovy wake up 🎧🍳",
                                              messageId: "hip_ringtone",
                                              curateListCategory: constants.curateAlarmListHeadings.defaultAlarm,
                                              isQueued: false, canBeLiked: false,
                                              hasBeenLiked: false)
        
        static let radarAlarm = curateListAlarm(associatedProfile: userModel(user: ["username": "Radar alarm"]),
                                              timeReceived: Date(),
                                              audioFileUrl: URL.init(fileURLWithPath: Bundle.main.path(forResource: "radar_alarm", ofType: "m4a")!),
                                              audioLength: 26.0,
                                              description: "It's annoying but it'll wake you up 😳☀️",
                                              messageId: "radar_alarm",
                                              curateListCategory: constants.curateAlarmListHeadings.defaultAlarm,
                                              isQueued: false, canBeLiked: false,
                                              hasBeenLiked: false)
        
        static let fireAlarm = curateListAlarm(associatedProfile: userModel(user: ["username": "Fire alarm"]),
                                              timeReceived: Date(),
                                              audioFileUrl: URL.init(fileURLWithPath: Bundle.main.path(forResource: "fire_alarm", ofType: "m4a")!),
                                              audioLength: 15.0,
                                              description: "In case you REALLY need to wake up 🚨🚨🚨",
                                              messageId: "fire_alarm",
                                              curateListCategory: constants.curateAlarmListHeadings.defaultAlarm,
                                              isQueued: false, canBeLiked: false,
                                              hasBeenLiked: false)
        
    }
    
    
    
}
