//
//  FirebaseManager.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/10.
//  Copyright © 2020 Wakey. All rights reserved.
//

import Foundation
import Firebase
import Alamofire
import SDWebImage

let kMaxConversations = 10
let kMaxMessages = 5
let kMaxFriends = 10

class FirebaseManager {
    enum wakeyError: Error {
        case unknownError
        case connectionError
        case invalidCredentials
        case invalidRequest
        case notFound
        case invalidResponse
        case serverError
        case serverUnavailable
        case timeOut
        case unsuppotedURL
        case proPicFailedToUpload
    }
    
    
    
    static let shared = FirebaseManager()
    
    var currentUser: userModel?

    
    
    //
    //WAKEY CONVERSATIONS / MESSAGES STUFF
    //
    
    //return value: [error string, conversations, cursor doc string]
    func fetchWakeyConversations(cursorDocument: String?,limit: Int?, completion: @escaping (String?, [wakeyConversation], String?) -> ()) {
        FirebaseManager.shared.getCurrentUser { (err, currUser) in
            guard let currUser = currUser else {
                completion("Error", [], nil)
                return
            }
            var conversations:[wakeyConversation] = []
            self.fetchToken { (token) in
                let headers: HTTPHeaders = [
                    "Authorization": "Bearer " + token,
                    "Accept": "application/json"
                ]
                //let params = ["after_id": cursorDocID as Any,"limit": limit as Any] as [String : Any]
                let params = [:] as [String: Any]
                AF.request("https://us-central1-wakey-3bf93.cloudfunctions.net/api/conversations", parameters: params, headers: headers).responseJSON { response in
                    if let result = response.response?.statusCode {
                        if result == 500 {
                            completion("An error occurred", [], nil)
                            return
                        } else if result == 400 {
                            completion("An error occurred ", [], nil)
                            return
                        }
                    }
                    do {
                        if response.data != nil {
                            if let parseJSON = try JSONSerialization.jsonObject(with: response.data!, options: []) as? NSDictionary {
                                if let convos = parseJSON["conversations"] as? [[String:Any]] {
                                    for convo in convos {
                                        //print("dictionary rep")
                                        //print(userDict)
                                        var otherUser: userModel = currUser
                                        let participants = convo["participant_details"] as? [[String:Any]] ?? []
                                        for participant in participants {
                                            //guard let userID = participant["user_id"] else{continue}
                                            if let participantID = participant["user_id"] as? String, participantID != currUser.userID {
                                                otherUser = userModel(user: ["username" : participant["username"] ?? "", "user_id": participantID, "profile_img_url": participant["profile_img_url"] ?? ""])
                                                break
                                            }
                                        }
                                        
                                        let conversationID = convo["conversation_id"] as? String ?? ""
                                        
                                        //most recent message info
                                        let mostRecentMessage = convo["most_recent_message"] as? [String:Any] ?? [:]
                                        var sentAt = Date()
                                        if let sentAtStr = mostRecentMessage["sent_at"] as? String {
                                            sentAt = jsonDateToDate(jsonStr: sentAtStr)
                                        }
                                        var heardAtDate: Date?
                                        if let heardAtStr = mostRecentMessage["opened_at"] as? String, heardAtStr != "" {
                                            heardAtDate = jsonDateToDate(jsonStr: heardAtStr)
                                        }
                                        let audioUrl = mostRecentMessage["audio_file_url"] as? String ?? ""
                                        var reaction: String? =  nil
                                        if let reactionStr = mostRecentMessage["reaction"] as? String, reactionStr != "" {
                                            reaction = reactionStr
                                        }
                                        var latestMessageSender = currUser
                                        var latestMessageReceiver = otherUser
                                        if let sender = mostRecentMessage["sender_id"] as? String,sender != currUser.userID {
                                            latestMessageSender = otherUser
                                            latestMessageReceiver = currUser
                                        }
                                        let latestMessage = wakeyMessage(sender: latestMessageSender, receiver: latestMessageReceiver, timeSent: sentAt, timeHeard: heardAtDate, audioFileUrl: audioUrl, reaction: reaction, conversationID: conversationID, messageID: conversationID, audioLength: nil)
                                        
                                        let finalConvo = wakeyConversation(conversationID: conversationID, other_user: otherUser, messages: [latestMessage])
                                        //print(user.userID)
                                        conversations.append(finalConvo)
                                    }
                                    completion(nil, conversations, conversations.last?.conversationID)
                                }
                            }
                        }
                    } catch let parseError {
                        print("ERROR HERE", parseError.localizedDescription)
                        completion("An error occurred",[], nil)
                    }
                }
            }
        }
    }
    
    
    func fetchWakeyConversationMessages(cursorDocumentID: String?, otherUser: userModel, conversationID: String, completion: @escaping (String?, [wakeyMessage], String?) -> ()) {
        FirebaseManager.shared.getCurrentUser { (err, currUser) in
            guard let currUser = currUser else {
                completion("Error", [], nil)
                return
            }
            self.fetchToken { (token) in
                let headers: HTTPHeaders = [
                    "Authorization": "Bearer " + token,
                    "Accept": "application/json"
                ]
                //let params = ["after_id": cursorDocID as Any,"limit": limit as Any] as [String : Any]
                let params = [:] as [String: Any]
                AF.request("https://us-central1-wakey-3bf93.cloudfunctions.net/api/messages/" + conversationID, parameters: params, headers: headers).responseJSON { response in
                    if let result = response.response?.statusCode {
                        if result == 500 {
                            completion("An error occurred", [], nil)
                            return
                        } else if result == 400 {
                            completion("An error occurred ", [], nil)
                            return
                        }
                    }
                    do {
                        if response.data != nil {
                            if let parseJSON = try JSONSerialization.jsonObject(with: response.data!, options: []) as? NSDictionary {
                                if let messages = parseJSON["messages"] as? [[String:Any]] {
                                    var messageArr: [wakeyMessage] = []
                                    for message in messages {
                                        let messageID = message["message_id"] as? String ?? ""
                                        let audioFileUrl = message["audio_file_url"] as? String ?? ""
                                        var reaction: String?
                                        if let reactionStr = message["reaction"] as? String, reactionStr != "" {
                                            reaction = reactionStr
                                        }
                                        let senderID = message["sender_id"] as? String ?? ""
                                        var timeSent = Date()
                                        if let timeSentStr = message["sent_at"] as? String, timeSentStr != "" {
                                            timeSent = jsonDateToDate(jsonStr: timeSentStr)
                                        }
                                        var audioLength: Double?
                                        if let len = message["audio_length"] as? Double {
                                            audioLength = len
                                        }
                                        var timeHeard: Date?
                                        if let timeHeardStr = message["opened_at"] as? String, timeHeardStr != "" {
                                            timeHeard = jsonDateToDate(jsonStr: timeHeardStr)
                                        }
                                        
                                        if senderID == currUser.userID {
                                            messageArr.append(wakeyMessage(sender: currUser, receiver: otherUser, timeSent: timeSent, timeHeard: timeHeard, audioFileUrl: audioFileUrl, reaction: reaction, conversationID: conversationID, messageID: messageID, audioLength: audioLength))
                                        } else {
                                            messageArr.append(wakeyMessage(sender: otherUser, receiver: currUser, timeSent: timeSent, timeHeard: timeHeard, audioFileUrl: audioFileUrl, reaction: reaction, conversationID: conversationID, messageID: messageID, audioLength: audioLength))
                                        }
                                    }
                                    completion(nil, messageArr, messageArr.last?.messageID)
                                    
                                }
                            }
                        }
                    } catch let parseError {
                        print("ERROR HERE", parseError.localizedDescription)
                        completion("An error occurred",[], nil)
                    }
                }
            }
        }
    }
    
    
    func sendWakeyMessage(audioFileUrl: URL, audioLength: Double, recipientsCanFavorite: Bool, recipients: [[String: Any]], completion: @escaping (Error?) -> ()) {
        self.getCurrentUser { (err, currUser) in
            FirebaseManager.shared.uploadAudioFile(audioFileUrl: audioFileUrl) { (error, webHostedurl) in
                //upload the recorded message to storage
                guard let webHostedurl = webHostedurl else {
                    completion(error)
                    return
                }
                //once we've uplaoded the file, send the messages
                self.fetchToken { (token) in
                    let headers: HTTPHeaders = [
                        "Authorization": "Bearer " + token,
                        "Accept": "application/json"
                    ]
                    let params = ["receivers": recipients,"audio_file_url": webHostedurl, "audio_length": audioLength, "can_be_liked": recipientsCanFavorite, "sender_username": currUser!.username, "sender_full_name": currUser!.fullName, "sender_profile_img_url": currUser!.profilePicUrl ] as [String : Any]
                    //AF.request("https://us-central1-wakey-3bf93.cloudfunctions.net/api/send_message", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                    AF.request("https://us-central1-wakey-3bf93.cloudfunctions.net/api/send_message", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                        //debugprint(response)
                        if let result = response.response?.statusCode {
                            if result == 200 {
                                completion(nil)
                                return
                            }
                        }
                        completion(response.error)
                    }
                }
            }
        }
    }
    
    
    
    func likeWakeyMessage(thisMessage: receivedAlarm, didLikeMessage: Bool , description: String, completion: @escaping (Error?) -> ()) {
        self.getCurrentUser { (error, currUser) in
            if error != nil {
                completion(error)
            }
            self.fetchToken { (token) in
                let headers: HTTPHeaders = [
                    "Authorization": "Bearer " + token,
                    "Accept": "application/json"
                ]
                let params = ["description": description,"message_id":thisMessage.audioID, "did_like_message": didLikeMessage, "sender_id": thisMessage.sender.userID, "receiver_username": currUser!.username] as [String : Any]
                AF.request("https://us-central1-wakey-3bf93.cloudfunctions.net/api/like_message", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                    //debugprint(response)
                    if let result = response.response?.statusCode {
                        if result == 200 {
                            completion(nil)
                            return
                        }
                    }
                    completion(response.error)
                }
            }
        }
    }
    
    func sendReaction(reactedToAlarm: receivedAlarm, reactionString: String, completion: @escaping (String) -> ()) {
        self.getCurrentUser { (error, currUser) in
            if error != nil {
                completion("Failed to send")
            }
            self.fetchToken { (token) in
                let headers: HTTPHeaders = [
                    "Authorization": "Bearer " + token,
                    "Accept": "application/json"
                ]
                let params = ["message_id": reactedToAlarm.audioID,"reaction": reactionString, "sender_id": reactedToAlarm.sender.userID, "receiver_username": currUser!.username] as [String : Any]
                AF.request("https://us-central1-wakey-3bf93.cloudfunctions.net/api/open_message", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
                    .responseJSON { response in
                        //debugprint(response)
                        if let result = response.response?.statusCode {
                            if result == 200 {
                                completion("Sent to " + reactedToAlarm.sender.username)
                                return
                            }
                        }
                        completion("Failed to send to " + reactedToAlarm.sender.username)
                    }
            }
        }
    }
    
    
    func likeAlarm(thisAlarm: receivedAlarm, didLike: Bool, completion: @escaping (String) -> ()) {
        self.getCurrentUser { (error, currUser) in
            if error != nil {
                completion("Failed to send")
            }
            self.fetchToken { (token) in
                let headers: HTTPHeaders = [
                    "Authorization": "Bearer " + token,
                    "Accept": "application/json"
                ]
                let params = ["audio_id": thisAlarm.audioID,"did_like": didLike] as [String : Any]
                AF.request("https://us-central1-wakey-3bf93.cloudfunctions.net/api/did_favorite", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
                    .responseJSON { response in
                        //debugprint(response)
                        if let result = response.response?.statusCode {
                            if result == 200 {
                                if didLike {
                                    completion("Liked " + thisAlarm.sender.username + "'s wakey")
                                } else {
                                    completion("Unliked " + thisAlarm.sender.username + "'s wakey")
                                }
                                
                                return
                            }
                        }
                        if didLike {
                            completion("Failed to like " + thisAlarm.sender.username + "'s wakey")
                        } else {
                            completion("Failed to unlike " + thisAlarm.sender.username + "'s wakey")
                        }
                    }
            }
        }
    }
    
    
    func sendAudio(audioFileUrl: URL, recipients: [userModel], completion: @escaping (Error?) -> ()) {
        FirebaseManager.shared.uploadAudioFile(audioFileUrl: audioFileUrl) { (error, url) in
            guard let url = url else {
                completion(error)
                return
            }
            self.fetchToken { (token) in
                let headers: HTTPHeaders = [
                    "Authorization": "Bearer " + token,
                    "Accept": "application/json"
                ]
                var recipientsJson: [[String:Any]] = []
                for user in recipients {
                    let recip = ["receiver_user_id": user.userID,"receiver_user_img": user.profilePicUrl ,"receiver_user_username":user.username]
                    recipientsJson.append(recip)
                }
                let params = ["receivers": recipientsJson, "audio_file_url": url] as [String : Any]
                
                AF.request("https://us-central1-wakey-3bf93.cloudfunctions.net/api/audio_msg", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
                    .responseJSON { response in
                        //debugprint(response)
                    }
            }
        }
    }
    
    func wakeUp(usedAlarm: Bool, audioID: String, completion: @escaping (Error?) -> ()) {
        self.fetchToken { (token) in
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + token,
                "Accept": "application/json"
            ]
            let params = ["used_alarm": usedAlarm, "audio_id": audioID] as [String : Any]
            AF.request("https://us-central1-wakey-3bf93.cloudfunctions.net/api/wake_up", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
                .responseJSON { response in
                    //debugprint(response)
                }
        }
    }
    
    
    func setAsleepProperty(asleepBool: Bool, completion: @escaping (Error?) -> ()) {
        self.fetchToken { (token) in
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + token,
                "Accept": "application/json"
            ]
            let params = ["asleep_bool": asleepBool] as [String : Any]
            AF.request("https://us-central1-wakey-3bf93.cloudfunctions.net/api/go_sleep", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
                .responseString { response in
                    if let result = response.response?.statusCode {
                        if result != 200 {
                            //created user
                            completion(wakeyError.unknownError)
                            return
                        } else {
                            completion(nil)
                        }
                    } else {
                        completion(wakeyError.unknownError)
                        return
                    }
                }
        }
    }
        
    
    func sendPushNotification(receiverDeviceId: String, messageTitle: String,messageBody: String) {
        self.fetchToken { (token) in
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + token,
                "Accept": "application/json"
            ]
            let params = ["device_id": receiverDeviceId, "msg_title": messageTitle, "msg_body": messageBody] as [String : Any]
            AF.request("https://us-central1-wakey-3bf93.cloudfunctions.net/api/send_push", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
                //AF.request("https://us-central1-wakey-3bf93.cloudfunctions.net/api/send_push", parameters: params, headers: headers)
                .responseString { response in
                    //debugprint(response)
                    print("RESPONSE FROM TRYING TO SEND PUSH NOTIFICATION: ")
                    debugPrint(response)
                }
        }
    }
    

    
    //
    //USER CREATION / UPDATING STUFF
    //
    
    
    //returns (error?, pro pic did upload)
    func createNewUser(authUser: User, username: String, fullName: String, phoneNumber: String, profileImage: UIImage, completion: @escaping (String?, Bool) -> ()) {
        self.fetchToken { (token) in
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + token,
                "Accept": "application/json"
            ]
            let storageRef = Storage.storage()
            let imageRef = storageRef.reference().child("user_profile_pics/" + authUser.uid + ".jpg")
            imageRef.putData(profileImage.jpeg(.lowest)!, metadata: nil) { (metaData, proPicErr) in
                guard let metaData = metaData else {
                    completion("A network error occurred", false)
                    return
                }
                if proPicErr != nil {
                    completion("A network error occurred", false)
                    return
                } else {
                    imageRef.downloadURL { (profilePicUrl, error) in
                        if let error = error {
                            //couldn't get url for profile pic
                            completion("A network error occurred", false)
                            return
                        } else if let profilePicUrl = profilePicUrl {
                            //we've got the pro pic url; go ahead and create the user
                            let params = ["username": username,"full_name": fullName,  "profile_img_url": profilePicUrl.absoluteString, "asleep": false, "bed_time": 7.0, "fb_data": [],"phone_num": phoneNumber] as [String : Any]
                            AF.request("https://us-central1-wakey-3bf93.cloudfunctions.net/api/create_user", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                                //debugprint(response)
                                if let result = response.response?.statusCode {
                                    if result == 201 {
                                        //created user
                                        completion(nil, true)
                                        return
                                    }
                                    if result == 400 {
                                        print("HITS 400")
                                        completion("That username is already in use. Please choose another one", false)
                                    }
                                    if result == 500 {
                                        print("HITS 500")
                                        completion("A network error occurred", false)
                                    }
                                }
                            }
                        } else {
                            completion("A network error occurred", false)
                            return
                        }
                    }
                }
            }
            
        }
    }
    
    
    func setDeviceID(deviceID: String,completion: @escaping (Error?) -> ()) {
        self.fetchToken { (token) in
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + token,
                "Accept": "application/json"
            ]
            let params = ["device_id": deviceID] as [String : Any]
            AF.request("https://us-central1-wakey-3bf93.cloudfunctions.net/api/set_device_id", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
                .responseJSON { response in
                    if let result = response.response?.statusCode {
                        if result != 200 {
                            completion(wakeyError.unknownError)
                            return
                        } else {
                            completion(nil)
                            return
                        }
                    } else {
                        completion(wakeyError.unknownError)
                        return
                    }
                }
        }
    }
    
    
    //need to use auth token in future
    func uploadProfilePic(profileImage: UIImage, user: User, completion: @escaping (String?, Error?) -> ()) {
        let storageRef = Storage.storage()
        let imageRef = storageRef.reference().child("user_profile_pics/" + user.uid + ".jpg")
        imageRef.putData(profileImage.jpeg(.lowest)!, metadata: nil) { (metadata, error) in
            if let error = error {
                completion(nil,error)
            } else {
               imageRef.downloadURL { (url, urlError) in
                    if let urlError = urlError {
                        completion(nil, urlError)
                    } else {
                        completion(url!.absoluteString, nil)
                    }
                }
            }
        }
    }
    
    //return (error?, has completed sign up)
    func checkIfUserHasCompletedSignUp(completion: @escaping (Error?, Bool?) -> ()) {
        fetchToken { (token) in
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + token,
                "Accept": "application/json"
            ]
            AF.request("https://us-central1-wakey-3bf93.cloudfunctions.net/api/user/", headers: headers).responseJSON { response in
                do {
                    if let result = response.response?.statusCode {
                        if result == 400 {
                            //user doc doesn't exist; user hasn't finished signed up
                            completion(nil, false)
                            return
                        } else if result == 500 {
                            //something went wrong
                            let err = response.error?.underlyingError
                            completion(err, false)
                            return
                        }
                    }
                    //if we get here, final check to see that user isn't nil
                    if response.data != nil {
                        if let dict = try JSONSerialization.jsonObject(with: response.data!, options: []) as? [String:Any] {
                            let thisUser = userModel(user: dict)
                            FirebaseManager.shared.currentUser = thisUser
                            completion(nil, true)
                            return
                        }
                    }
                    //if we get here it failed for some weird reason
                    let err = response.error?.underlyingError
                    completion(err, false)
                    return
                } catch let parseError {
                    completion(parseError, false)
                    return
                }
            }
            
            
        }
    }
    
    
    func signIn(email: String, password: String, completion: @escaping (String?) -> ()) {
        Auth.auth().signIn(withEmail:email, password: password) { (result, error) in
            if let error = error {
                if let errCode = AuthErrorCode(rawValue: error._code) {
                    switch errCode {
                    case .networkError:
                        completion("A network error occurred")
                    case .wrongPassword:
                        completion("Invalid credentials. Make sure your email and password are correct")
                    default:
                       completion("An error occurred")
                    }
                    return
                }
                completion("An error occurred")
            } else {
               completion(nil)
            }
        }
    }
    
    func getCurrentUser(completion: @escaping (Error?, userModel?) -> ()) {
        if let user = FirebaseManager.shared.currentUser {
            completion(nil,user)
        } else {
            setCurrentUser { (error, user) in
                if let error = error {
                    completion(error, nil)
                } else {
                    completion(nil, user)
                }
            }
        }
    }
    
    func setCurrentUser(completion: @escaping (Error?, userModel?) -> ()) {
        fetchToken { (token) in
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + token,
                "Accept": "application/json"
            ]
            AF.request("https://us-central1-wakey-3bf93.cloudfunctions.net/api/user/", headers: headers).responseJSON { response in
                do {
                    if response.data != nil {
                        if let dict = try JSONSerialization.jsonObject(with: response.data!, options: []) as? [String:Any] {
                            //print("got current user")
                            let thisUser = userModel(user: dict)
                            FirebaseManager.shared.currentUser = thisUser
                            completion(nil, thisUser)
                        }
                    }
                } catch let parseError {
                    completion(parseError, nil)
                }
            }
        }
    }
    
    func logOut(completion: @escaping (Error?) -> ()) {
        do {
            try Auth.auth().signOut()
            FirebaseManager.shared.currentUser = nil
            completion(nil)
        } catch let err {
            completion(err)
        }
    }
    
    
    func fetchToken(completion: @escaping (String) -> ()) {
        Auth.auth().currentUser?.getIDToken(completion: { (token, error) in
            if error != nil {
                //print("error gett auth token")
            } else {
                print("THIS IS THE TOKEN: " + (token ?? ""))
                completion(token!)
            }
        })
    }
    
    
    
    
    //SETTING ALARMS
    
    func fetchLikedMessages(completion: @escaping (Error?, [receivedAlarm]) -> ()) {
        fetchToken { (token) in
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + token,
                "Accept": "application/json"
            ]
            AF.request("https://us-central1-wakey-3bf93.cloudfunctions.net/api/liked_messages", headers: headers).responseJSON { response in
                //debugprint(response)
                //print("RESULT FROM FETCHING SINGLE ALARM")
                print(response.result)
                do {
                    if response.data != nil {
                        if let parseJSON = try JSONSerialization.jsonObject(with: response.data!, options: []) as? NSDictionary {
                            if let audiosDict = parseJSON["messages"] as? [[String: [String: Any]]] {
                                var alarms: [receivedAlarm] = []
                                for msg in audiosDict {
                                    let messageDetails = msg["message"]! as [String: Any]
                                    let senderDetails = msg["sender"]! as [String: Any]
                                    let alarmProps = ["audio_id": messageDetails["message_id"] as Any,"audio_file_url": messageDetails["audio_file_url"] as Any, "created_at": jsonDateToDate(jsonStr: messageDetails["sent_at"] as? String ?? ""), "audio_length": messageDetails["audio_length"] as Any, "can_be_liked": messageDetails["can_be_liked"] as Any, "has_been_liked": messageDetails["has_been_liked"] as Any, "description": messageDetails["description"] as Any] as [String:Any]
                                    let userDict = ["user_id": senderDetails["sender_id"] as Any, "username": senderDetails["username"] as Any, "profile_img_url": senderDetails["profile_img_url"] as Any, "asleep": false, "created_at": Date()] as [String : Any]
                                    
                                    let user = userModel(user: userDict)
                                    let alarm = receivedAlarm(alarm: alarmProps, sender: user, localAudioUrl: nil)
                                    alarms.append(alarm)
                                }
                                completion(nil, alarms)
                                return
                                
                            } else {
                                //empty
                                completion(nil, [])
                                return
                            }
                        }
                    }
                    completion(nil, [])
                } catch let parseError {
                    completion(parseError, [])
                }
            }
        }
    }
    
    func uploadAudioFile(audioFileUrl: URL, completion: @escaping (Error?,String?) -> ()) {
        FirebaseManager.shared.getCurrentUser { (error, user) in
            if let user = user {
                let storageRef = Storage.storage()
                let referenceString = user.username + " " + user.userID + " " + Date().description
                let audioRef = storageRef.reference().child("/audio_message/" + referenceString)
                let uploadTask = audioRef.putFile(from: audioFileUrl, metadata: nil) { metadata, error in
                    guard let metadata = metadata else {
                        // error occurred!
                        return
                    }
                    audioRef.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            // error occurred!
                            return
                        }
                        //print("uploaded url is this:")
                        //print(downloadURL.absoluteString)
                        completion(nil, downloadURL.absoluteString)
                        
                    }
                }
            }
        }
        
    }
    
    func downloadAudioFile(withUrl: String,pathPrefix: String, completion: @escaping (Error?, URL?) -> ()) {
        let destination: DownloadRequest.Destination = { _, _ in
            //let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            //let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let soundsDirectoryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent("Sounds")
            //Library/Sounds
            do {
                try FileManager.default.createDirectory(atPath: soundsDirectoryURL.path,
                                                        withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                //print("COULDNT CREATE DIRECTORY")
                //print("Error: \(error.localizedDescription)")
            }
            
            //let fileURL = documentsURL.appendingPathComponent("wakey_message_sent_" + pathPrefix + ".m4a")
            let fileURL = soundsDirectoryURL.appendingPathComponent("wakey_message_sent_" + pathPrefix + ".m4a")
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        
        
        AF.download(withUrl, to: destination).responseData { (response) in
            //debugprint(response)
            //print(response.result)
            if let destinationUrl = response.fileURL {
                //print("downloaded VN successfully with local url:")
                //print(destinationUrl)
                completion(nil, destinationUrl)
            } else {
                completion(response.error, URL(string: ""))
            }
        }
    }
    
    
    func downloadImageToLocalUrl(withUrl: String,pathPrefix: String, completion: @escaping (Error?, URL?) -> ()) {
        let folderURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("profile_pics", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: folderURL!, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            //print(error)
        }
        let fileURL = folderURL!.appendingPathComponent("wakey_message_sent_profile_pic_" + pathPrefix + ".jpg")
        SDWebImageDownloader.shared.downloadImage(with: URL(string: withUrl), options: [.continueInBackground], progress: nil) { (image, data, error, success) in
            if error == nil {
                if let image = image {
                    let rotatedImg = image.sd_rotatedImage(withAngle: 0, fitSize: false)!
                    do {
                        try rotatedImg.jpegData(compressionQuality: 0.2)?.write(to: fileURL)
                        completion(nil, fileURL)
                    } catch let err {
                        //print(err)
                        completion(err, nil)
                    }
                }
            }
        }
    }
    
    func getAllAlarmsSent(completion: @escaping ([sentAlarm]) -> ()) {
        var sentAlarms:[sentAlarm] = []
        fetchToken { (token) in
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + token,
                "Accept": "application/json"
            ]
            AF.request("https://us-central1-wakey-3bf93.cloudfunctions.net/api/all_audio", headers: headers).responseJSON { response in
                //print("Result from api/audio_sent call")
                //print(response.result)
                do {
                    if response.data != nil {
                        if let parseJSON = try JSONSerialization.jsonObject(with: response.data!, options: []) as? NSDictionary {
                            //print("GETS HERE")
                            
                            if let alarms = parseJSON["audio_sent"] as? [[String:Any]] {
                                //print("These are the alarms")
                                //print(alarms)
                                for dict in alarms {
                                    //print("ALARM SENT OBJ HERE")
                                    //print(dict)
                                    let alarmProps = ["audio_id": dict["audio_id"] as Any,"audio_file_url": dict["audio_file_url"] as Any,"sender": dict["sender"] as Any, "created_at": dict["created_at"] as Any] as [String:Any]
                                    if let receivers = dict["receivers"] as? [[String:Any]] {
                                        for receiver in receivers {
                                            let userDict = ["user_id": receiver["receiver_user_id"] as Any, "username": receiver["receiver_user_username"] as Any, "profile_img_url": receiver["receiver_user_img"] as Any, "asleep": false, "created_at": Date()] as [String : Any]
                                            let user = userModel(user: userDict)
                                            let hasBeenheard = receiver["played"] as? Bool ?? false
                                            let alarm = sentAlarm(alarm: alarmProps, user: user, hasBeenHeard: hasBeenheard,reaction: receiver["reaction"] as? String)
                                            sentAlarms.append(alarm)
                                        }
                                    }
                                }
                                completion(sentAlarms)
                            }
                        }
                    }
                } catch let parseError {
                    //print("JSON Error \(parseError.localizedDescription)")
                    completion([])
                }
            }
        }
    }
    
    func fetchUnopenedMessages(completion: @escaping (Error?, [receivedAlarm]) -> ()) {
        fetchToken { (token) in
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + token,
                "Accept": "application/json"
            ]
            AF.request("https://us-central1-wakey-3bf93.cloudfunctions.net/api/unopened_messages", headers: headers).responseJSON { response in
                //debugprint(response)
                //print("RESULT FROM FETCHING SINGLE ALARM")
                print(response.result)
                do {
                    if response.data != nil {
                        print("Response data isnt nil")
                        if let parseJSON = try JSONSerialization.jsonObject(with: response.data!, options: []) as? NSDictionary {
                            if let audiosDict = parseJSON["messages"] as? [[String: [String: Any]]] {
                                var alarms: [receivedAlarm] = []
                                for msg in audiosDict {
                                    let messageDetails = msg["message"]! as [String: Any]
                                    let senderDetails = msg["sender"]! as [String: Any]
                                    
                                    
                                    
                                    let alarmProps = ["audio_id": messageDetails["message_id"] as Any,"audio_file_url": messageDetails["audio_file_url"] as Any, "created_at": jsonDateToDate(jsonStr: messageDetails["sent_at"] as? String ?? ""), "audio_length": messageDetails["audio_length"] as Any, "can_be_liked": messageDetails["can_be_liked"] as Any, "has_been_liked": messageDetails["has_been_liked"] as Any] as [String:Any]
                                    let userDict = ["user_id": senderDetails["sender_id"] as Any, "username": senderDetails["username"] as Any, "profile_img_url": senderDetails["profile_img_url"] as Any, "asleep": false, "created_at": Date()] as [String : Any]
                                    
                                    let user = userModel(user: userDict)
                                    let alarm = receivedAlarm(alarm: alarmProps, sender: user, localAudioUrl: nil)
                                    alarms.append(alarm)
                                    print("HERES A MESSAGE:")
                                    print(alarmProps)
                                }
                                completion(nil, alarms)
                                return
                                
                            } else {
                                //empty
                                completion(nil, [])
                                return
                            }
                        }
                    }
                    completion(nil, [])
                } catch let parseError {
                    //print("JSON Error \(parseError.localizedDescription)")
                    completion(parseError, [])
                }
            }
        }
    }
    
    
    //
    //FRIENDS ENDPOINTS
    //
    
    func fetchAllFriends(completion: @escaping (Error?, [userModel]) -> ()) {
        self.fetchToken { (token) in
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + token,
                "Accept": "application/json"
            ]
            AF.request("https://us-central1-wakey-3bf93.cloudfunctions.net/api/fetch_all_friends", headers: headers).responseJSON { response in
                do {
                    if response.data != nil {
                        if let parseJSON = try JSONSerialization.jsonObject(with: response.data!, options: []) as? NSDictionary {
                            if let friendsArr = parseJSON["friends"] as? [[String: String]] {
                                var friends: [userModel] = []
                                for frnd in friendsArr {
                                    let requestId = frnd["request_id"]! as String
                                    let profileImgUrl = frnd["profile_img_url"]! as String
                                    let userID = frnd["user_id"]! as String
                                    let username = frnd["username"]! as String
                                    let connectedAt = jsonDateToDate(jsonStr: frnd["connected_at"] ?? "")
                                    let userDict = ["user_id": userID, "username": username, "profile_img_url": profileImgUrl, "became_friends": connectedAt, "friendship_status": constants.friendConditions.areFriends, "frienship_id": requestId] as [String : Any]
                                    let user = userModel(user: userDict)
                                    friends.append(user)
                                }
                                completion(nil, friends)
                                return
                            } else {
                                completion(nil, [])
                                return
                            }
                        }
                    }
                    completion(nil, [])
                } catch let parseError {
                    completion(parseError, [])
                }
            }
        }
    }
    
    
    //Returns (error, request_id, status)
    func fetchRelationshipStatus(otherUserID: String,completion: @escaping (Error?, String, String) -> ()) {
        self.fetchToken { (token) in
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + token,
                "Accept": "application/json"
            ]
            
            
            AF.request("https://us-central1-wakey-3bf93.cloudfunctions.net/api/fetch_relationship_status/" + otherUserID, headers: headers).responseJSON { response in
                if let result = response.response?.statusCode {
                    if result == 500 {
                        completion(wakeyError.unknownError,"" , "")
                        return
                    } else if result == 400 {
                        completion(wakeyError.unknownError,"" , "")
                        return
                    }
                }
                do {
                    if response.data != nil {
                        print(response.data!)
                        
                        
                        if let parseJSON = try JSONSerialization.jsonObject(with: response.data!, options: []) as? NSDictionary {
                            if let statusDict = parseJSON as? [String: String] {
                                let requestID = statusDict["request_id"]! as String
                                let status = statusDict["status"]! as String
                                completion(nil, requestID, status)
                                return
                            } else {
                                completion(wakeyError.unknownError, "", "")
                                return
                            }
                        }
                    }
                    completion(wakeyError.unknownError, "", "")
                } catch let parseError {
                    print(parseError.localizedDescription)
                    completion(wakeyError.unknownError, "", "")
                }
            }
        }
    }
    
    //returns (error, request_id, status)
    func requestFriend(otherUser: userModel, completion: @escaping (Error?, String, String) -> ()) {
        self.getCurrentUser { (error, currUser) in
            if error != nil {
                completion(wakeyError.unknownError, "", "")
                return
            }
            self.fetchToken { (token) in
                let headers: HTTPHeaders = [
                    "Authorization": "Bearer " + token,
                    "Accept": "application/json"
                ]
                let params = ["receiver_id": otherUser.userID, "receiver_username": otherUser.username,"sender_full_name": currUser?.username, "receiver_profile_img_url": otherUser.profilePicUrl, "sender_id": currUser!.userID, "sender_username": currUser!.username, "sender_profile_img_url": currUser!.profilePicUrl] as [String : Any]
                AF.request("https://us-central1-wakey-3bf93.cloudfunctions.net/api/request_friend", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
                    .responseJSON { response in
                        if let result = response.response?.statusCode {
                            if result == 500 {
                                completion(wakeyError.unknownError, "", "")
                                return
                            }
                        }
                        do {
                            if response.data != nil {
                                if let parseJSON = try JSONSerialization.jsonObject(with: response.data!, options: []) as? NSDictionary {
                                    if let statusDict = parseJSON as? [String: String] {
                                        let requestID = statusDict["request_id"]! as String
                                        let status = statusDict["status"]! as String
                                        completion(nil, requestID, status)
                                        return
                                    } else {
                                        completion(wakeyError.unknownError, "", "")
                                        return
                                    }
                                }
                            }
                            completion(wakeyError.unknownError, "", "")
                        } catch let parseError {
                            print(parseError.localizedDescription)
                            completion(wakeyError.unknownError, "", "")
                        }
                    }
            }
        }
    }
    
    
    //returns (error, request_id, status)
    func acceptOrDenyFriendRequest(otherUser: userModel, requestID: String, acceptedRequest: Bool, completion: @escaping (Error?, String, String) -> ()) {
        self.getCurrentUser { (error, currUser) in
            if error != nil {
                completion(wakeyError.unknownError, "", "")
                return
            }
            self.fetchToken { (token) in
                let headers: HTTPHeaders = [
                    "Authorization": "Bearer " + token,
                    "Accept": "application/json"
                ]
                let params = ["receiver_id": currUser!.userID, "receiver_username":currUser!.username, "receiver_full_name": currUser!.fullName, "sender_id": otherUser.userID, "request_id": requestID, "accepted_bool": acceptedRequest] as [String : Any]
                AF.request("https://us-central1-wakey-3bf93.cloudfunctions.net/api/accept_or_deny_friend_request", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
                    .responseJSON { response in
                        if let result = response.response?.statusCode {
                            if result == 500 {
                                completion(wakeyError.unknownError, "", "")
                                return
                            }
                        }
                        do {
                            if response.data != nil {
                                if let parseJSON = try JSONSerialization.jsonObject(with: response.data!, options: []) as? NSDictionary {
                                    if let statusDict = parseJSON as? [String: String] {
                                        let requestID = statusDict["request_id"]! as String
                                        let status = statusDict["status"]! as String
                                        completion(nil, requestID, status)
                                        return
                                    } else {
                                        completion(wakeyError.unknownError, "", "")
                                        return
                                    }
                                }
                            }
                            completion(wakeyError.unknownError, "", "")
                        } catch let parseError {
                            print(parseError.localizedDescription)
                            completion(wakeyError.unknownError, "", "")
                        }
                    }
            }
        }
    }
    
    //returnsL (error?, [request user])
    func fetchPendingRequestReceived(completion: @escaping (Error?, [userModel]) -> ()) {
        self.fetchToken { (token) in
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + token,
                "Accept": "application/json"
            ]
            AF.request("https://us-central1-wakey-3bf93.cloudfunctions.net/api/pending_requests_received", headers: headers).responseJSON { response in
                if let result = response.response?.statusCode {
                    if result == 500 {
                        completion(wakeyError.unknownError, [])
                        return
                    } else if result == 400 {
                        completion(wakeyError.unknownError, [])
                        return
                    }
                }
                do {
                    if response.data != nil {
                        if let parseJSON = try JSONSerialization.jsonObject(with: response.data!, options: []) as? NSDictionary {
                            if let requests = parseJSON["pending_requests_received"] as? [[String: Any]] {
                                var requestArr: [userModel] = []
                                for request in requests {
                                    var requestID = ""
                                    requestID = request["request_id"] as? String ?? ""
                                    let senderDetails = request["sender_details"] as? [String: String] ?? [:]
                                    let lastActivityTime = jsonDateToDate(jsonStr: (request["last_activity_time"] as? String ?? ""))
                                    let userDict = ["user_id": senderDetails["user_id"] ?? "", "username": senderDetails["username"] ?? "", "profile_img_url": senderDetails["profile_img_url"] ?? "", "became_friends": lastActivityTime, "friendship_status": constants.friendConditions.receivedRequest, "friendship_id": requestID] as [String : Any]
                                    let requestUser = userModel(user: userDict)
                                    requestArr.append(requestUser)
                                }
                                completion(nil, requestArr)
                                return
                            }
                        } else {
                            completion(wakeyError.unknownError, [])
                            return
                        }
                    } else {
                        completion(wakeyError.unknownError, [])
                        return
                    }
                } catch let parseError {
                    completion(wakeyError.unknownError, [])
                    return
                }
            }
        }
    }
    
    
    func fetchAllFriends(completion: @escaping (Error?, [userModel]) -> ()) {
        self.getCurrentUser { (error, currUser) in
            if error != nil {
                completion(wakeyError.unknownError, [])
                return
            }
            self.fetchToken { (token) in
                let headers: HTTPHeaders = [
                    "Authorization": "Bearer " + token,
                    "Accept": "application/json"
                ]
                
                //need to give it an array of numbers in the body
                AF.request("https://us-central1-wakey-3bf93.cloudfunctions.net/api/find_friends_from_contacts", headers: headers).responseJSON { response in
                    do {
                        if response.data != nil {
                            if let parseJSON = try JSONSerialization.jsonObject(with: response.data!, options: []) as? NSDictionary {
                                if let friendsArr = parseJSON["friends"] as? [[String: String]] {
                                    var friends: [userModel] = []
                                    for frnd in friendsArr {
                                        let requestId = frnd["request_id"]! as String
                                        let profileImgUrl = frnd["profile_img_url"]! as String
                                        let userID = frnd["user_id"]! as String
                                        let username = frnd["username"]! as String
                                        let connectedAt = jsonDateToDate(jsonStr: frnd["connected_at"] ?? "")
                                        let userDict = ["user_id": userID, "username": username, "profile_img_url": profileImgUrl, "became_friends": connectedAt, "friendship_status": constants.friendConditions.areFriends, "frienship_id": requestId] as [String : Any]
                                        let user = userModel(user: userDict)
                                        friends.append(user)
                                    }
                                    completion(nil, friends)
                                    return
                                } else {
                                    completion(nil, [])
                                    return
                                }
                            }
                        }
                        completion(nil, [])
                    } catch let parseError {
                        completion(parseError, [])
                    }
                }
            }
        }
    }
    
    
}
