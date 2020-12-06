//
//  NetworkManager.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/02.
//  Copyright © 2020 Wakey. All rights reserved.
//

import Foundation


class DatabaseManager {
    
    static let shared = DatabaseManager()
    //var uid: String?
    var uid: String? = "Rowan"
    //var user: basicUser? = basicUser(userID: "rowan", userName: "rowan", fullName: "Rowan Mockler", profilePicUrl: "https://firebasestorage.googleapis.com/v0/b/vigdb-534db.appspot.com/o/user_profile_pics%2Frowanmockler@gmail.com.jpg?alt=media&token=920106b0-9585-466b-af9f-065b1bc127b6")
    
    var isAuthenticated: Bool {
        //return authentication?.currentUser != nil
        return true
    }
    //var databaseRootRef: DatabaseReference?
    //var storageRootRef: StorageReference?
    //var authentication: Auth?

    init() {

    }

    func initialize() {
//        uid = Auth.auth().currentUser?.uid
//        databaseRootRef = Database.database().reference()
//        storageRootRef = Storage.storage().reference()
//        authentication = Auth.auth()
    }
    
//    func registerUserWith(name: String, email: String, password: String, completionHandler: (@escaping (User?, Error?) -> Void)) {
//        authentication?.signIn(withEmail: email, password: password, completion: { (user, error) in
//            completionHandler(user, error)
//        })
//    }
}
