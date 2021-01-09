//
//  searchFriendsVC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/12/26.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit
import IGListKit
import NVActivityIndicatorView
import AVFoundation
import Alamofire
import Firebase
import FBSDKLoginKit
import Contacts
import InstantSearch

class searchFriendsVC: UIViewController {
    
    @IBOutlet weak var collectionView: ListCollectionView!
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    }()
    private var collectionIndex : Index!
    private var query = Query()
    
    var searchBar = "searchBar"
    var connectFBCell = "facebookCell"
    var connectContactsCell = "connectContactsCell"
    var askToConnectFB = false
    var askToConnectContacts = false
    
    var firstAppearance: Bool = true
    
    
    var foundUsersInContacts = false
    var showContactsLabel = "Wakey users found from your contacts"
    var foundInContacts: [userModel] = []
    var recycledResults: [userModel] = []
    var searchResults: [userModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        adapter.collectionView = collectionView
        self.view.backgroundColor = .clear
        collectionView.backgroundColor = .clear
        adapter.dataSource = self
        let layout = UICollectionViewFlowLayout()
        self.collectionView.collectionViewLayout = layout
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.showsVerticalScrollIndicator = false
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if firstAppearance {
            setupAlgoliaSearch()
            configureAddFriends()
            firstAppearance = false
        }
    }
    
    
       
    
    
    func configureAddFriends() {
        //check if user has connected facebook
//        if let token = AccessToken.current, !token.isExpired {
//            askToConnectFB = false
//            let currAccessToken = token.tokenString
//            let params = ["fields": "id, first_name, last_name, middle_name, name, email, picture"]
//            let request = GraphRequest(graphPath: "me/friends", parameters: params)
//            request.start { (connection, result, reqError) in
//                if let reqError = reqError {
//                    let errorMessage = reqError.localizedDescription
//                    print(errorMessage)
//                    return
//                }
//                if let  result = result {
//                    print("RESULT FROM FRIENDS")
//                    print(result)
//                }
//            }
//        } else {
//            askToConnectFB = true
//            self.adapter.performUpdates(animated: true)
//        }
        //Check if user has given access to contacts
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        switch authorizationStatus {
        case .authorized:
            askToConnectContacts = false
            self.checkIfContactsWereQueried()
            break
        case .denied, .notDetermined:
            askToConnectContacts = true
            self.adapter.performUpdates(animated: true)
            break
        default:
            askToConnectContacts = true
            self.adapter.performUpdates(animated: true)
            break
        }
    }
    
    func checkIfContactsWereQueried() {
        FirebaseManager.shared.checkIfContactsHaveBeenQueried { (error, haveQueried, foundUsers) in
            if error == nil, haveQueried, !foundUsers.isEmpty {
                self.foundUsersInContacts = true
                
                for foundUser in foundUsers {
                    if let index = self.recycledResults.firstIndex(where: { $0.userID == foundUser.userID}) {
                        self.foundInContacts.append(self.recycledResults[index])
                    } else {
                        self.recycledResults.append(foundUser)
                        self.foundInContacts.append(foundUser)
                    }
                }
                self.adapter.performUpdates(animated: true)
                
            } else {
                self.foundUsersInContacts = false
            }
        }
    }
    
    
    
}

extension searchFriendsVC: searchSCDelegate {
    
    func setupAlgoliaSearch() {
        let searchClient = SearchClient(appID: "IHBKQU1Z44", apiKey: "7e0cf1eb9e2003ccb6013ca11049610c")
        let indexName = "USERS"
        collectionIndex = searchClient.index(withName: IndexName(rawValue: indexName))
        query.hitsPerPage = 20
//
        // Limiting the attributes to be retrieved helps reduce response size and improve performance.
//        query.attributesToRetrieve = ["property1", "property2", "property3"]
//        query.attributesToHighlight = ["property1", "property2", "property3"]
    }
    
    struct userHit: Decodable {
        let objectID: String
        let full_name: String
        let username: String
        let profile_img_url: String
        let phone_num: String
    }
    
    func convertdecodableToUser(hits: [userHit]) -> [userModel] {
        var users: [userModel] = []
        for hit in hits {
            if let index = recycledResults.firstIndex(where: { $0.userID == hit.objectID}) {
                users.append(recycledResults[index])
            } else {
                let unseenResultUser = userModel(user: ["user_id": hit.objectID, "username": hit.username, "full_name":  hit.full_name, "profile_img_url": hit.profile_img_url, "phone_num": hit.phone_num])
                users.append(unseenResultUser)
                recycledResults.append(unseenResultUser)
            }
        }
        return users
    }
    
    
    func searchCollection(forText searchString : String) {
        query.query = searchString
        collectionIndex.search(query: query) { (result) in
            if case .success(let response) = result {
                do {
                    let hits: [userHit] = try response.extractHits()
                    let hitsModeled = self.convertdecodableToUser(hits: hits)
                    
                    self.searchResults = self.convertdecodableToUser(hits: hits)
                    DispatchQueue.main.async {
                        self.adapter.performUpdates(animated: true)
                    }
                } catch let error {
                    print("Hits decoding error :\(error)")
                }
            }
        }
    }
    
    
    func searchSectionController(_ sectionController: searchBarSC, didChangeText text: String) {
        searchCollection(forText: text)
    }
    
    
    func userRelationshipStatusDidUpdate(updatedUser: userModel, requestID: String, status: String, sc: addFriendCellSC) {
        if let recycleResIndex = recycledResults.firstIndex(where: { $0.userID == updatedUser.userID}) {
            recycledResults[recycleResIndex].friendshipID = requestID
            recycledResults[recycleResIndex].friendshipStatus = status
            sc.user = recycledResults[recycleResIndex]
            if let searchResIndex = searchResults.firstIndex(where: { $0.userID == updatedUser.userID}) {
                searchResults[searchResIndex] = recycledResults[recycleResIndex]
            }
            if let contactsResIndex = foundInContacts.firstIndex(where: { $0.userID == updatedUser.userID}) {
                foundInContacts[contactsResIndex] = recycledResults[recycleResIndex]
            }
        }
    }
    
}

extension searchFriendsVC: ListAdapterDataSource{
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        var screenItems: [ListDiffable] = []
        screenItems += [searchBar] as [ListDiffable]
        if askToConnectFB {
            screenItems += ([connectFBCell]) as [ListDiffable]
        }
        if askToConnectContacts {
            screenItems += ([connectContactsCell]) as [ListDiffable]
        } else {
        }
        screenItems += searchResults as [ListDiffable]
        
        if !askToConnectContacts && foundUsersInContacts {
            screenItems += ([showContactsLabel]) as [ListDiffable]
            screenItems += foundInContacts
        }
        return screenItems
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if object is userModel {
            let sc = addFriendCellSC()
            sc.user = (object as! userModel)
            return sc
        }
        if (object is String && object as! String == connectContactsCell) {
            let sc = connectContactsCellSC()
            return sc
        }
        if (object is String && object as! String == showContactsLabel) {
            let sc = seperatorCellSC()
            sc.fontSize = 20
            sc.lightText = false
            sc.labelText = showContactsLabel
            return sc
        }
        if (object is String && object as! String == connectFBCell) {
            let sc = connectFacebookCellSC()
            return sc
        }
        
        if (object is String && object as! String == searchBar) {
            let sc = searchBarSC()
            sc.delegate = self
            return sc
        }
        return ListSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        
        return loadingCollectionView(backgroundColor: .clear, indicatorColor: UIColor.init(named: "AppRedColor")!)
    }
}
