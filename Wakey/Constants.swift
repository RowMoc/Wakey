//
//  Constants.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/19.
//  Copyright © 2020 Wakey. All rights reserved.
//

class constants {
    //onboarding check
    static let hasViewedWalkThrough = "hasViewedWalkThrough"
    
    //Daily notifcation identifier
    static let dailyNotificationIdentifier = "dailyNotificationIdentifier"
    
    //Keys for locally stored properties regarding the status of a user's alarm
    struct scheduledAlarms {
        //Dictionary {String: Any}: Dictionary representation of a scheduled alarm, if the user has set one
        static let scheduledAlarmDictionaryKey = "scheduledAlarmDictionaryKey"
        //Dictionary {String: Any}: Dictionary representation of a scheduled alarm, if the user has set one
        static let scheduledAlarmArrayKey = "scheduledAlarmArrayKey"
        //Date: Time alarm was set to go off
        static let alarmSetForTimeKey = "alarmSetForTimeKey"
        
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
        static let favorited = "favorited"
        static let defaultAlarm = "default"
    }
}
