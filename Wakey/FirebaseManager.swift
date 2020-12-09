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
    
    
    
    //USING NEW SCHEMA AS OF 21 JUNE 2020
    
    //FETCHING WAKEY CHATS
    
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
                    
                    
                    let params = ["receivers": recipients,"audio_file_url": webHostedurl, "audio_length": audioLength, "recipients_can_favorite": recipientsCanFavorite] as [String : Any]
                    //AF.request("https://us-central1-wakey-3bf93.cloudfunctions.net/api/send_message", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                    AF.request("https://us-central1-wakey-3bf93.cloudfunctions.net/api/send_message", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                        //debugprint(response)
                        if let result = response.response?.statusCode {
                            if result == 200 {
                                for receiver in recipients {
                                    self.sendPushNotification(receiverDeviceId: (receiver["receiver_device_id"] as? String ?? "") as String, messageTitle: "Wakey received", messageBody: (currUser?.username ?? "Somebody") + " sent you a Wakey message")
                                }
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
                
//
//
//
//
//
//
//
//
//
//                let db = Firestore.firestore()
//                let downloadGroup = DispatchGroup()
//                for recipient in recipients {
//                    //check if the conversation exists;if it does, add a new wakey_message document
//                    //to the convo subCollection. If it doesn't exist, create a new
//                    //conversation and add a new wakey_message document to the convo subCollection
//                    downloadGroup.enter()
//                    let timesent = Timestamp(date: Date())
//                    //new schema
//                    let docuRef = db.collection("wakey_conversations")
//                    docuRef.whereField("participants", in: [[currUser!.userID, recipient.userID], [recipient.userID, currUser?.userID]]).limit(to: 1).getDocuments { (convo, convoErr) in
//                        if convoErr != nil {
//                            downloadGroup.leave()
//                        }
//                        if let conversations = convo {
//                            if let conversation = conversations.documents.first  {
//                                //update the array and time
//                                //do a batched write here:
//                                let batch = db.batch()
//                                let thisMessageRef = docuRef.document(conversation.documentID).collection("/wakey_messages").document()
//
//                                batch.setData([
//                                    "audio_file_url" : webHostedurl,
//                                    "opened": false,
//                                    "receiver": recipient.userID,
//                                    "sender_id": currUser!.userID,
//                                    "time_sent": timesent
//                                ], forDocument: thisMessageRef)
//
//
//                                let mostRecentMessage = ["audio_file_url": webHostedurl, "message_id": thisMessageRef.documentID, "sender_id": currUser!.userID, "time_sent": timesent] as [String: Any]
//                                let thisConvoRef = docuRef.document(conversation.documentID)
//                                batch.updateData([
//                                    "most_recent_message" : mostRecentMessage,
//                                    "last_wakey_sent_time": timesent
//                                ], forDocument: thisConvoRef)
//
//                                // Commit the batch
//                                batch.commit() { err in
//                                    if let err = err {
//                                        print("Error writing batch \(err)")
//                                        downloadGroup.leave()
//                                    } else {
//                                        print("Batch write succeeded.")
//                                        downloadGroup.leave()
//                                    }
//                                }
//                            } else {
//
//                                //create the document
//
//                                let batch = db.batch()
//                                let newConvoRef = docuRef.document()
//                                let thisMessageRef = docuRef.document(newConvoRef.documentID).collection("/wakey_messages").document()
//
//                                batch.setData([
//                                    "audio_file_url" : webHostedurl,
//                                    "opened": false,
//                                    "receiver": recipient.userID,
//                                    "sender_id": currUser!.userID,
//                                    "time_sent": timesent
//                                ], forDocument: thisMessageRef)
//
//                                let mostRecentMessage = ["audio_file_url": webHostedurl, "message_id": thisMessageRef.documentID, "sender_id": currUser!.userID, "time_sent": timesent] as [String: Any]
//                                let participants = [currUser!.userID, recipient.userID]
//
//                                let participantDetails = [["profile_pic_url": currUser!.profilePicUrl, "user_name": currUser!.userName, "user_id": currUser!.userID], ["profile_pic_url": recipient.profilePicUrl, "user_name": recipient.userName, "user_id": recipient.userID]]
//
//                                batch.setData([
//                                    "last_action_time": timesent,
//                                    "participants": participants,
//                                    "participant_details": participantDetails,
//                                    "most_recent_message" : mostRecentMessage,
//                                    "last_wakey_sent_time": timesent
//                                ], forDocument: newConvoRef)
//
//                                // Commit the batch
//                                batch.commit() { err in
//                                    if let err = err {
//                                        print("Error writing batch \(err)")
//                                        downloadGroup.leave()
//                                    } else {
//                                        print("Batch write succeeded.")
//                                        downloadGroup.leave()
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//                downloadGroup.notify(queue: DispatchQueue.main) {
//                    completion(nil)
//                }
//            }
//        }
//    }
//
    
    func acceptFriendRequest(requestID: String, sender: userModel, completion: @escaping (Error?, String?) -> ()) {
        FirebaseManager.shared.getCurrentUser { (error_curr_user, currUser) in
            if error_curr_user != nil {
                completion(error_curr_user, nil)
            }
            let db = Firestore.firestore()
            //check if the request exists;if it does, check its status and update accordinly; create it if it doesn't exist
            let requestRef = db.collection("wakey_friend_requests").document(requestID)

            db.runTransaction({ (transaction, errorPointer) -> Any? in
                let requestDoc: DocumentSnapshot
                do {
                    try requestDoc = transaction.getDocument(requestRef)
                } catch let fetchError as NSError {
                    errorPointer?.pointee = fetchError
                    return nil
                }

                guard let oldStatus = requestDoc.data()?["status"] as? String else {
                    let error = NSError(
                        domain: "AppErrorDomain",
                        code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Unable to retrieve status from snapshot \(requestDoc)"
                        ]
                    )
                    errorPointer?.pointee = error
                    return nil
                }
                guard let oldReceiver = requestDoc.data()?["receiver"] as? String else {
                    let error = NSError(
                        domain: "AppErrorDomain",
                        code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Unable to retrieve receiver from snapshot \(requestDoc)"
                        ]
                    )
                    errorPointer?.pointee = error
                    return nil
                }
                
                if oldReceiver == currUser!.userID {
                    switch oldStatus {
                        case "ACCEPTED":
                            return constants.friendConditions.areFriends
                        case "DENIED":
                            transaction.updateData(["status": "ACCEPTED"], forDocument: requestRef)
                            return constants.friendConditions.areFriends
                        case "REQUESTED":
                            transaction.updateData(["status": "ACCEPTED"], forDocument: requestRef)
                            return constants.friendConditions.areFriends
                    default:
                        break
                    }
                } else {
                    switch oldStatus {
                        case "ACCEPTED":
                            transaction.updateData(["status": "ACCEPTED", "receiver": sender.userID], forDocument: requestRef)
                            return constants.friendConditions.areFriends
                        case "DENIED":
                            return constants.friendConditions.arentFriends
                        case "REQUESTED":
                            return constants.friendConditions.sentRequest
                    default:
                        break
                    }
                }
                return nil
            }) { (object, error) in
                if let error = error {
                    print("Transaction failed: \(error)")
                    completion(error, nil)
                } else {
                    completion(nil, object as? String ?? "")
                }
            }
        }
    }
    
    
    func fetchReceivedFriendRequests(cursorDoc: DocumentSnapshot?,completion: @escaping (Error?, [userModel], DocumentSnapshot?) -> ()) {
        FirebaseManager.shared.getCurrentUser { (error_curr_user, currUser) in
            if error_curr_user != nil {
                completion(error_curr_user, [], nil)
            }
            let db = Firestore.firestore()
            //check if the request exists;if it does, check its status and update accordinly; create it if it doesn't exist
            var query = db.collection("wakey_friend_requests").whereField("receiver", isEqualTo: currUser!.userID).whereField("status", isEqualTo: "REQUESTED").limit(to: kMaxFriends)
            if let cursorDoc = cursorDoc {
                query = query.start(afterDocument: cursorDoc)
            }
            query.getDocuments { (requestObjects, reqErr) in
                if reqErr != nil {
                    completion(reqErr, [], nil)
                }
                if requestObjects == nil || requestObjects?.documents.count == 0  {
                    completion(nil, [], nil)
                } else {
                    let lastDoc = requestObjects!.documents.last
                    
                    var requestArr: [userModel] = []
                    for requestObject in requestObjects!.documents {
                        guard let participantDetails = requestObject["participant_details"] as? [[String: String]] else {
                            continue
                        }
                        var otherUser = currUser!
                        var requestReceivedDate = Date()
                        if let requestReceivedAt = requestObject["last_activity_time"] as? Timestamp {
                            requestReceivedDate = requestReceivedAt.dateValue()
                        }
                        for details in participantDetails {
                            if let userID = details["user_id"], userID != currUser!.userID {
                                otherUser = userModel(user: ["username" : details["user_name"] ?? "", "user_id": userID, "profile_img_url": details["profile_pic_url"] ?? "", "friendship_id": requestObject.documentID, "friendship_status": constants.friendConditions.receivedRequest, "became_friends": requestReceivedDate,"asleep": false])
                                break
                            }
                        }
                        requestArr.append(otherUser)
                    }
                    completion(nil, requestArr, lastDoc)
                }
            }
        }
    }
    
    
   
    
    
    func unfriend(requestID: String, completion: @escaping (Error?) -> ()) {
        //Maybe I should delete all where these two people are friends?
        let db = Firestore.firestore()
        db.collection("wakey_friend_requests").document(requestID).delete() { err in
            if let err = err {
                completion(err)
            } else {
                completion(nil)
            }
        }
    }
    
    func denyFriendRequest(requestID: String, completion: @escaping (Error?) -> ()) {
        FirebaseManager.shared.getCurrentUser { (error_curr_user, currUser) in
            if error_curr_user != nil {
                completion(error_curr_user)
            }
            let db = Firestore.firestore()
            //check if the request exists;if it does, check its status and update accordinly; create it if it doesn't exist
            let requestRef = db.collection("wakey_friend_requests").document(requestID)
            
            db.runTransaction({ (transaction, errorPointer) -> Any? in
                let requestDoc: DocumentSnapshot
                do {
                    try requestDoc = transaction.getDocument(requestRef)
                } catch let fetchError as NSError {
                    errorPointer?.pointee = fetchError
                    return nil
                }
                
                guard let oldStatus = requestDoc.data()?["status"] as? String else {
                    let error = NSError(
                        domain: "AppErrorDomain",
                        code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Unable to retrieve status from snapshot \(requestDoc)"
                        ]
                    )
                    errorPointer?.pointee = error
                    return nil
                }
                guard let oldReceiver = requestDoc.data()?["receiver"] as? String else {
                    let error = NSError(
                        domain: "AppErrorDomain",
                        code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Unable to retrieve from snapshot \(requestDoc)"
                        ]
                    )
                    errorPointer?.pointee = error
                    return nil
                }
                
                if oldReceiver == currUser!.userID {
                    switch oldStatus {
                    case "ACCEPTED":
                        transaction.updateData(["status": "DENIED"], forDocument: requestRef)
                        return constants.friendConditions.arentFriends
                    case "DENIED":
                        return constants.friendConditions.arentFriends
                    case "REQUESTED":
                        transaction.updateData(["status": "DENIED"], forDocument: requestRef)
                        return constants.friendConditions.arentFriends
                    default:
                        break
                    }
                } else {
                    switch oldStatus {
                    case "ACCEPTED":
                        transaction.deleteDocument(requestRef)
                        return constants.friendConditions.arentFriends
                    case "DENIED":
                        return constants.friendConditions.arentFriends
                    case "REQUESTED":
                        transaction.deleteDocument(requestRef)
                        return constants.friendConditions.arentFriends
                    default:
                        break
                    }
                }
                return nil
            }) { (object, error) in
                if let error = error {
                    completion(error)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    
    
    
    func sendFriendRequest(receiver: userModel, completion: @escaping (Error?, String?) -> ()) {
        FirebaseManager.shared.getCurrentUser { (error_curr_user, currUser) in
            if error_curr_user != nil {
                completion(error_curr_user, nil)
            }
            let db = Firestore.firestore()
            //check if the request exists;if it does, check its status and update accordinly; create it if it doesn't exist
            let docuRef = db.collection("wakey_friend_requests")
            docuRef.whereField("participants", in: [[currUser!.userID, receiver.userID], [receiver.userID, currUser!.userID]]).limit(to: 1).getDocuments { (requestObj, reqErr) in
                if reqErr != nil {
                    completion(reqErr, nil)
                }
                if let requests = requestObj {
                    if let request = requests.documents.first  {
                        //update the array and time
                        //do a batched write here:
                        
                        let currentStatus = request["status"] as? String ?? "DENIED"
                        let thisRelationshipRef = docuRef.document(request.documentID)
                        switch currentStatus {
                        case "ACCEPTED":
                            completion(nil, constants.friendConditions.areFriends)
                            return
                        case "REQUESTED":
                            if let receiverID = request["receiver"] as? String, currUser!.userID == receiverID {
                                //declare friends since this persons sending a request to someone who requested them
                                thisRelationshipRef.updateData(["status": "ACCEPTED", "last_activity_time": Timestamp(date: Date())]) { (err) in
                                    if err != nil {
                                        completion(err, nil)
                                        return
                                    }
                                    completion(nil, constants.friendConditions.areFriends)
                                    return
                                }
                            } else {
                                completion(nil, constants.friendConditions.sentRequest)
                                return
                            }
                        default:
                            thisRelationshipRef.updateData(["status": "REQUESTED", "receiver": receiver.userID, "last_activity_time": Timestamp(date: Date())]) { (err_three) in
                                if err_three != nil {
                                    completion(err_three, nil)
                                    return
                                }
                                completion(nil, constants.friendConditions.sentRequest)
                                return
                            }
                        }
                    } else {
                        
                        //create the request
                        let participants = [currUser!.userID, receiver.userID]
                        
                        let participantDetails = [["profile_pic_url": currUser!.profilePicUrl, "user_name": currUser!.username, "user_id": currUser!.userID], ["profile_pic_url": receiver.profilePicUrl, "user_name": receiver.username, "user_id": receiver.userID]]
                        docuRef.addDocument(data:[
                            "participants": participants,
                            "participant_details": participantDetails,
                            "last_activity_time": Timestamp(date: Date()),
                            "status": "REQUESTED",
                            "receiver": receiver.userID,
                        ]) { (docCreateErr) in
                            if docCreateErr != nil {
                                completion(docCreateErr, nil)
                                return
                            }
                            completion(nil, constants.friendConditions.sentRequest)
                            return
                            
                        }
                    }
                }
            }
        }
    }
    
    
    
     //END OF NEW ENDPOINTS THAT ARE USING NEW SCHEMA AS OF 21 JUNE 2020
    
    
    
    
    
    
    
    //    func signUp(email: String, password: String, fullName: String, profileImage: UIImage, completion: @escaping (Error?) -> ()) {
    //        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
    //            if let error = error {
    //                completion(error)
    //            } else {
    //                //print("Auth made the user")
    //                FirebaseManager.shared.createNewUser(user: result!.user, fullName: fullName, email: email, profileImage: profileImage) { (thisError) in
    //                    completion(thisError)
    //                }
    //            }
    //        }
    //    }
    
    
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
        
        
        
//
//        imageRef.putData(profileImage.jpeg(.lowest)!, metadata: nil) { (metadata, error) in
//            if let error = error {
//                completion(nil,error)
//            } else {
//               imageRef.downloadURL { (url, urlError) in
//                    if let urlError = urlError {
//                        completion(nil, urlError)
//                    } else {
//                        completion(url!.absoluteString, nil)
//                    }
//                }
//            }
//        }
//    }
//        FirebaseManager.shared.uploadProfilePic(profileImage: profileImage, user: user) { (url, error) in
//            if let error = error {
//                //failed
//                completion(error)
//            } else {
//                //print("Auth made the user")
//                let userDict = ["user_id": user.uid, "username": fullName, "profile_img_url": url!, "asleep": false, "created_at": Date()] as [String : Any]
//                FirebaseManager.shared.currentUser = userModel(user: userDict)
//                //TO-DO
//                self.fetchToken { (token) in
//                    let headers: HTTPHeaders = [
//                        "Authorization": "Bearer " + token,
//                        "Accept": "application/json"
//                    ]
//                    let params = ["username": fullName,"email": email, "img_url": url!] as [String : Any]
//                    AF.request("https://us-central1-wakey-3bf93.cloudfunctions.net/api/create_user", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
//                        //debugprint(response)
//                        if let result = response.response?.statusCode {
//                            if result == 201 {
//                                completion(nil)
//                                return
//                            }
//                        }
//                        completion(response.error)
//                    }
//                }
//            }
//        }
    
    
    
    
    
    
    
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
    
    //Checks if the signed in user has completed sign up)
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
                completion(token!)
            }
        })
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
                let params = ["audio_id": reactedToAlarm.audioID,"reaction": reactionString] as [String : Any]
                AF.request("https://us-central1-wakey-3bf93.cloudfunctions.net/api/react", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
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
    
    
    func fetchAllAlarmsReceived(completion: @escaping (Error?, [receivedAlarm]) -> ()) {
        fetchToken { (token) in
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + token,
                "Accept": "application/json"
            ]
            AF.request("https://us-central1-wakey-3bf93.cloudfunctions.net/api/go_sleep", headers: headers).responseJSON { response in
                //debugprint(response)
                //print("RESULT FROM FETCHING SINGLE ALARM")
                //print(response.result)
                do {
                    if response.data != nil {
                        //print("Response data isnt nil")
                        if let parseJSON = try JSONSerialization.jsonObject(with: response.data!, options: []) as? NSDictionary {
                            //print("Parsed it")
                            if let audiosDict = parseJSON["audios"] as? [[String: Any]] {
                                var alarms: [receivedAlarm] = []
                                for msg in audiosDict {
                                    if let senderDict = msg["sender"] as? [String: Any] {
                                        let userDict = ["user_id": senderDict["sender_id"] as Any, "username": senderDict["sender_username"] as Any, "profile_img_url": senderDict["sender_img"] as Any, "asleep": false, "created_at": Date()] as [String : Any]
                                        let user = userModel(user: userDict)
                                        
                                        let alarmProps = ["audio_id": msg["audio_id"] as Any,"audio_file_url": msg["audio_file_url"] as Any, "created_at": Date()] as [String:Any]
                                        let alarm = receivedAlarm(alarm: alarmProps, sender: user, localAudioUrl: nil)
                                        alarms.append(alarm)
                                    }
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
    
    //return value: error string, [friends], last doc id
    func getFriends(cursorDocID: String?, limit: Int?, completion: @escaping (String?, [userModel], String?) -> ()) {
        var friends:[userModel] = []
        fetchToken { (token) in
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + token,
                "Accept": "application/json"
            ]
            //let params = ["after_id": cursorDocID as Any,"limit": limit as Any] as [String : Any]
            let params = [:] as [String: Any]
            AF.request("https://us-central1-wakey-3bf93.cloudfunctions.net/api/friends", parameters: params, headers: headers).responseJSON { response in
                if let result = response.response?.statusCode {
                    if result == 500 {
                        completion("An error occurred", [], nil)
                        return
                    }
                }
                do {
                    if response.data != nil {
                        if let parseJSON = try JSONSerialization.jsonObject(with: response.data!, options: []) as? NSDictionary {
                            if let users = parseJSON["friends"] as? [[String:Any]] {
                                for userDict in users {
                                    //print("dictionary rep")
                                    //print(userDict)
                                    let user = userModel(user: userDict)
                                    //print(user.userID)
                                    friends.append(user)
                                }
                                completion(nil, friends, friends.last?.userID)
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
    
//    func fetchFriends(cursorDoc: DocumentSnapshot?, paginate: Bool,completion: @escaping (Error?, [userModel], DocumentSnapshot?) -> ()) {
//           FirebaseManager.shared.getCurrentUser { (error_curr_user, currUser) in
//               if error_curr_user != nil {
//                   completion(error_curr_user, [], nil)
//               }
//               let db = Firestore.firestore()
//               //check if the request exists;if it does, check its status and update accordinly; create it if it doesn't exist
//               var query = db.collection("wakey_friend_requests").whereField("participants", arrayContains: currUser!.userID).whereField("status", isEqualTo: "ACCEPTED")
//
//               if paginate {
//                   if let cursorDoc = cursorDoc {
//                       query = query.limit(to: kMaxFriends).start(afterDocument: cursorDoc)
//                   } else {
//                       query = query.limit(to: kMaxFriends)
//                   }
//               } else {
//                   //want to fetch all at the same time
//                   query = db.collection("wakey_friend_requests").whereField("participants", arrayContains: currUser!.userID).whereField("status", isEqualTo: "ACCEPTED")
//               }
//               query.getDocuments { (requestObjects, friendsErr) in
//                   if friendsErr != nil {
//                       completion(friendsErr, [], nil)
//                   }
//                   if requestObjects == nil || requestObjects?.documents.count == 0  {
//                       completion(nil, [], nil)
//                   } else {
//                       let lastDoc = requestObjects!.documents.last
//
//                       var friendsArr: [userModel] = []
//                       for requestObject in requestObjects!.documents {
//                           guard let participantDetails = requestObject["participant_details"] as? [[String: String]] else {
//                               continue
//                           }
//                           var otherUser = currUser!
//                           let becameFriends = requestObject["last_activity_time"] as? Timestamp
//                           for details in participantDetails {
//                               if let userID = details["user_id"], userID != currUser!.userID {
//                                   otherUser = userModel(user: ["username" : details["user_name"] ?? "", "user_id": userID, "profile_img_url": details["profile_pic_url"] ?? "", "friendship_id": requestObject.documentID, "friendship_status": constants.friendConditions.areFriends, "became_friends": becameFriends?.dateValue() as Any,"asleep": false])
//                                   break
//                               }
//                           }
//                           friendsArr.append(otherUser)
//                       }
//                       completion(nil, friendsArr, lastDoc)
//                   }
//               }
//           }
//       }
    

    
    
}
