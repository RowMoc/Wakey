//
//  Models.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/02.
//  Copyright © 2020 Wakey. All rights reserved.
//

import Foundation
import IGListKit
import Firebase



class wakeyConversation {
    let conversationID: String
    let other_user: userModel
    var messages: [wakeyMessage]
    
    init(conversationID: String, other_user: userModel, messages: [wakeyMessage]) {
        self.conversationID = conversationID
        self.other_user = other_user
        self.messages = messages
    }
}
extension wakeyConversation: Equatable{
    static public func == (rhs: wakeyConversation, lhs: wakeyConversation)-> Bool{
        return rhs.other_user.isEqual(toDiffableObject: lhs.other_user) && lhs.conversationID == rhs.conversationID
    }
}
extension wakeyConversation: ListDiffable{
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? wakeyConversation else{
            return false
        }
        
        return (self.other_user.isEqual(toDiffableObject: object.other_user) && self.conversationID == object.conversationID && self.messages.count == object.messages.count && self.messages.last?.messageID == object.messages.last?.messageID && self.messages.last?.timeSent == object.messages.last?.timeSent && self.messages.last?.timeHeard == object.messages.last?.timeHeard)
    }
    
    public func diffIdentifier()-> NSObjectProtocol{
        return self.conversationID + self.other_user.userID + "_wakey_convo" as NSObjectProtocol
    }
}



class wakeyMessage {
    let conversationID: String
    let messageID: String
    let sender: userModel
    let receiver: userModel
    let timeSent: Date
    let audioFileUrl: String
    //if null, means the receiver hasn't reacted
    var reaction: String?
    //if null, means the receiver hasn't yet heard the message
    //If receiver is the curr user and the curr user hasn't heard it, don't display it in chat history VC.
    var timeHeard: Date?
    var audioLength: Double?
    
    init(sender: userModel, receiver: userModel, timeSent: Date, timeHeard: Date?, audioFileUrl: String, reaction: String?, conversationID: String, messageID: String, audioLength: Double?) {
        self.conversationID = conversationID
        self.sender = sender
        self.receiver = receiver
        self.timeSent = timeSent
        self.timeHeard = timeHeard
        self.audioFileUrl = audioFileUrl
        self.reaction = reaction
        self.messageID = messageID
    }
}
extension wakeyMessage: Equatable{
    static public func == (rhs: wakeyMessage, lhs: wakeyMessage)-> Bool{
        return rhs.conversationID == lhs.conversationID && rhs.audioFileUrl == lhs.audioFileUrl && lhs.messageID == rhs.messageID
    }
}
extension wakeyMessage: ListDiffable{
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? wakeyMessage else{
            return false
        }
        //return (self.user.isEqual(toDiffableObject: object.user) && self.isSelected == object.isSelected)
        return (self.conversationID == object.conversationID && self.audioFileUrl == object.audioFileUrl && self.timeHeard == object.timeHeard && self.sender.isEqual(toDiffableObject: object.sender) && self.reaction == object.reaction && self.messageID == object.messageID)
    }
    
    public func diffIdentifier()-> NSObjectProtocol{
        return self.conversationID + self.audioFileUrl + self.messageID + "_wakeyMessage" as NSObjectProtocol
    }
}


class curateListAlarm {
    let associatedProfile: userModel
    let timeReceived: Date
    var audioFileUrl: URL?
    let audioLength: Double
    let msgDescription: String
    let messageId: String
    let curateListCategory: String
    var isQueued: Bool
    var canBeLiked: Bool
    var hasBeenLiked: Bool
    var soundBite: soundBite?
    
    init(associatedProfile: userModel, timeReceived: Date, audioFileUrl: URL?, audioLength: Double, description: String, messageId: String, curateListCategory: String, isQueued: Bool, canBeLiked: Bool, hasBeenLiked: Bool, soundBite: soundBite? = nil) {
        self.associatedProfile = associatedProfile
        self.timeReceived = timeReceived
        self.audioFileUrl = audioFileUrl
        self.audioLength = audioLength
        self.msgDescription = description
        self.messageId = messageId
        self.curateListCategory = curateListCategory
        self.isQueued = isQueued
        self.canBeLiked = canBeLiked
        self.hasBeenLiked = hasBeenLiked
        self.soundBite = soundBite
    }
}
extension curateListAlarm: Equatable{
    static public func == (rhs: curateListAlarm, lhs: curateListAlarm)-> Bool{
        return rhs.messageId == lhs.messageId && rhs.audioFileUrl == lhs.audioFileUrl && rhs.isQueued == lhs.isQueued && rhs.canBeLiked == lhs.canBeLiked && rhs.hasBeenLiked == lhs.hasBeenLiked && lhs.soundBite == rhs.soundBite
    }
}
extension curateListAlarm: ListDiffable{
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? curateListAlarm else{
            return false
        }
        return (self.messageId == object.messageId && self.audioFileUrl == object.audioFileUrl && self.timeReceived == object.timeReceived && self.associatedProfile.isEqual(toDiffableObject: object.associatedProfile) && self.isQueued == object.isQueued && self.canBeLiked == object.canBeLiked && self.hasBeenLiked == object.hasBeenLiked && object.soundBite == self.soundBite)
    }
    
    public func diffIdentifier()-> NSObjectProtocol{
        return self.messageId  + (self.audioFileUrl?.absoluteString ?? "") + self.associatedProfile.username + "_curatedListAlarm" as NSObjectProtocol
    }
}







//used to set the progress of loading an alarm

class SettingAlarmProgress: NSObject {
    
    init(progress: CGFloat) {
        self.progress = progress
    }
    
    var progress: CGFloat
}


class userModel {
    
    var userID: String
    let username: String
    let fullName: String
    let profilePicUrl: String
    let isAsleep: Bool
    var currentAlarm: Date?
    var friendshipStatus: String?
    var friendshipID: String?
    let becameFriends: Date?
    let phoneNumber: String?
    let deviceID: String
    
    init(user: [String:Any]) {
        self.userID = user["user_id"] as? String ?? ""
        self.username = user["username"] as? String ?? ""
        self.fullName = user["full_name"] as? String ?? ""
        self.profilePicUrl = user["profile_img_url"] as? String ?? ""
        self.isAsleep = user["asleep"] as? Bool ?? false
        self.currentAlarm = user["current_alarm"] as? Date ?? nil
        self.friendshipID = user["friendship_id"] as? String ?? nil
        self.friendshipStatus = user["friendship_status"] as? String ?? nil
        self.becameFriends = user["became_friends"] as? Date ?? nil
        self.phoneNumber = user["phone_num"] as? String ?? ""
        self.deviceID = user["device_id"] as? String ?? ""
    }
}
extension userModel: Equatable{
    static public func == (rhs: userModel, lhs: userModel)-> Bool{
        return rhs.username == lhs.username && rhs.userID == lhs.userID && rhs.profilePicUrl == lhs.profilePicUrl && rhs.isAsleep == lhs.isAsleep && rhs.friendshipStatus == lhs.friendshipStatus && rhs.deviceID == lhs.deviceID
    }
}
extension userModel: ListDiffable{
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? userModel else{
            return false
        }
        return self.username == object.username && self.userID == object.userID && self.profilePicUrl == object.profilePicUrl && self.isAsleep == object.isAsleep && self.friendshipStatus == object.friendshipStatus && self.deviceID == object.deviceID
    }
    
    public func diffIdentifier()-> NSObjectProtocol{
        return userID  as NSObjectProtocol
    }
}


class recipientModel {
    let user: userModel
    var isSelected: Bool
    
    init(user: userModel, isSelected: Bool) {
        self.user = user
        self.isSelected = isSelected
    }
}
extension recipientModel: Equatable{
    static public func == (rhs: recipientModel, lhs: recipientModel)-> Bool{
        return rhs.user.isEqual(toDiffableObject: lhs.user)
    }
}
extension recipientModel: ListDiffable{
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? recipientModel else{
            return false
        }
        //return (self.user.isEqual(toDiffableObject: object.user) && self.isSelected == object.isSelected)
        return (self.user.isEqual(toDiffableObject: object.user) && self.isSelected == object.isSelected)
    }
    
    public func diffIdentifier()-> NSObjectProtocol{
        return self.user.userID + "_recipientCell" as NSObjectProtocol
    }
}


class sentAlarm {
    let user: userModel
    let hasBeenHeard: Bool
    var reaction: String?
    let timeSent: Date
    let audioUrl: String
    let audioID: String
    
    init(alarm: [String: Any], user: userModel, hasBeenHeard: Bool, reaction: String?) {
        self.user = user
        self.hasBeenHeard = hasBeenHeard
        self.timeSent = jsonDateToDate(jsonStr: (alarm["created_at"] as? String ?? ""))
        self.audioUrl = alarm["audio_file_url"] as? String ?? ""
        self.audioID = alarm["audio_id"] as? String ?? ""
        self.reaction = reaction
    }
}
extension sentAlarm: Equatable{
    static public func == (rhs: sentAlarm, lhs: sentAlarm)-> Bool{
        return rhs.user.userID == lhs.user.userID && rhs.audioUrl == lhs.audioUrl && rhs.audioID == lhs.audioID
    }
}
extension sentAlarm: ListDiffable{
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? sentAlarm else{
            return false
        }
        return self.user.isEqual(toDiffableObject: object.user) && self.audioUrl == object.audioUrl && self.audioID == object.audioID && self.reaction == object.reaction && self.hasBeenHeard == object.hasBeenHeard
    }
    
    public func diffIdentifier()-> NSObjectProtocol{
        return ((self.user.userID + "_" + self.audioUrl + "_" + self.audioID)  as NSObjectProtocol)
    }
}



class receivedAlarm: NSObject {
    
    let sender: userModel
    let timeSent: Date
    let audioUrl: String
    var localAudioUrl: URL?
    let audioID: String
    let audioLength: Double?
    var timePlayed: Date?
    var numTimesPlayed: Int?
    var canBeLiked: Bool
    var hasBeenLiked: Bool
    var msgDescription: String
    var soundBite: soundBite?
    
    init(alarm: [String: Any], sender: userModel, localAudioUrl: URL?, soundBite: soundBite? = nil) {
        self.sender = sender
        self.timeSent = alarm["created_at"] as? Date ?? Date()
        self.audioUrl = alarm["audio_file_url"] as? String ?? ""
        self.audioLength = alarm["audio_length"] as? Double
        self.audioID = alarm["audio_id"] as? String ?? ""
        self.canBeLiked = alarm["can_be_liked"] as? Bool ?? false
        self.hasBeenLiked = alarm["has_been_liked"] as? Bool ?? false
        self.msgDescription = alarm["description"] as? String ?? ""
        self.localAudioUrl = localAudioUrl
        self.soundBite = soundBite
    }
    
    static func ==(lhs: receivedAlarm, rhs: receivedAlarm) -> Bool {
        return rhs.sender.userID == lhs.sender.userID && rhs.audioUrl == lhs.audioUrl && rhs.audioID == lhs.audioID && rhs.timePlayed == lhs.timePlayed && rhs.numTimesPlayed == lhs.numTimesPlayed && rhs.hasBeenLiked == lhs.hasBeenLiked && rhs.msgDescription == lhs.msgDescription && lhs.soundBite == rhs.soundBite
    }
}
extension receivedAlarm: ListDiffable{
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? receivedAlarm else{
            return false
        }
        return self.sender.isEqual(toDiffableObject: object.sender) && self.audioUrl == object.audioUrl && self.audioID == object.audioID && self.timePlayed == object.timePlayed && self.numTimesPlayed == object.numTimesPlayed && self.canBeLiked == object.canBeLiked && self.hasBeenLiked == object.hasBeenLiked && self.msgDescription == object.msgDescription && object.soundBite == self.soundBite
    }
    
    public func diffIdentifier()-> NSObjectProtocol{
        return ((self.sender.userID + "_" + self.audioUrl + "_" + self.audioID)  as NSObjectProtocol)
    }
}


class sentSoundBite: NSObject {
    
    let sender: userModel
    let timeSent: Date
    let soundBite: soundBite
    
    init(sender: userModel, timeSent: Date, soundBite: soundBite) {
        self.sender = sender
        self.timeSent = timeSent
        self.soundBite = soundBite
    }
    
    static func ==(lhs: sentSoundBite, rhs: sentSoundBite) -> Bool {
        return rhs.sender.isEqual(toDiffableObject: lhs.sender) && rhs.soundBite.isEqual(lhs.soundBite)  && rhs.timeSent == lhs.timeSent
    }
}
extension sentSoundBite: ListDiffable{
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? sentSoundBite else{
            return false
        }
        return self.sender.isEqual(toDiffableObject: object.sender) && self.soundBite.isEqual(object.soundBite)  && self.timeSent == object.timeSent
    }
    
    public func diffIdentifier()-> NSObjectProtocol{
        return ((self.sender.userID + "_" + self.soundBite.objectID + "_" + self.timeSent.description)  as NSObjectProtocol)
    }
}





class soundBite: NSObject {
    
//    let sender: userModel
    let audioUrl: String
    var localAudioUrl: URL?
    let objectID: String
    var audioLength: Int?
    var createdAt: Date
    let title: String
    let transcript: String
    let category: String
    var associatedProfile: userModel
    let imageUrl: String
    var timesSent: Int
    let explicit: Bool
    
    
    init(soundBite: [String: Any], associatedProfile: userModel, localAudioUrl: URL?) {
        self.audioUrl = soundBite["audio_url"] as? String ?? ""
        self.audioLength = soundBite["audio_length"] as? Int
        self.objectID = soundBite["object_id"] as? String ?? ""
        self.transcript = soundBite["transcript"] as? String ?? ""
        self.category = soundBite["category"] as? String ?? ""
        self.title = soundBite["title"] as? String ?? ""
        self.createdAt = (soundBite["created_at"] as? Timestamp ?? Timestamp(date: Date())).dateValue()
        self.imageUrl = soundBite["image_url"] as? String ?? ""
        self.timesSent = soundBite["times_sent"] as? Int ?? 0
        self.explicit = soundBite["explicit"] as? Bool ?? false
        self.localAudioUrl = localAudioUrl
        self.associatedProfile = associatedProfile
        
    }
    
    static func ==(lhs: soundBite, rhs: soundBite) -> Bool {
        return rhs.associatedProfile.isEqual(toDiffableObject: lhs.associatedProfile) && rhs.audioUrl == lhs.audioUrl && rhs.objectID == lhs.objectID && rhs.createdAt == lhs.createdAt && rhs.title == lhs.title && rhs.category == lhs.category && rhs.transcript == lhs.transcript && lhs.localAudioUrl == rhs.localAudioUrl && lhs.timesSent == rhs.timesSent
    }
}
extension soundBite: ListDiffable{
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? soundBite else{
            return false
        }
        return self.associatedProfile.isEqual(toDiffableObject: object.associatedProfile) && self.audioUrl == object.audioUrl && self.objectID == object.objectID && self.createdAt == object.createdAt && self.audioLength == object.audioLength && self.title == object.title && self.transcript == object.transcript
    }
    
    public func diffIdentifier()-> NSObjectProtocol{
        return ((self.associatedProfile.userID + "_" + self.audioUrl + "_" + self.objectID)  as NSObjectProtocol)
    }
}




class currentAlarm {
    var isSet: Bool
    var alarmTime: Date?
    var alarms: [receivedAlarm]
    
    init(isSet: Bool, alarmTime: Date?, alarms: [receivedAlarm]) {
        self.isSet = isSet
        self.alarmTime = alarmTime
        self.alarms = alarms
    }
}
extension currentAlarm: Equatable{
    static public func == (rhs: currentAlarm, lhs: currentAlarm)-> Bool{
        return rhs.isSet == lhs.isSet && rhs.alarmTime == lhs.alarmTime && rhs.alarms == lhs.alarms
    }
}
extension currentAlarm: ListDiffable{
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? currentAlarm else{
            return false
        }
        return self.isSet == object.isSet && self.alarmTime == object.alarmTime && self.alarms == object.alarms
    }
    
    public func diffIdentifier()-> NSObjectProtocol{
        return ((self.alarmTime?.description ?? "") + "_" + self.alarms.description as NSObjectProtocol)
    }
}
