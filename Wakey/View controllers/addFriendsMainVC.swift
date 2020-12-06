//
//  addFriendsMainVC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/20.
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

class addFriendsMainVC: UIViewController {
    
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var collectionView: ListCollectionView!
    
    @IBOutlet weak var gradientView: UIView!
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    }()
    
    var feedItems = [Any]()
    var filteredAllArray = [Any]()
    
    
    var searchArray:[Any] = []
    var receivedRequestsArray: [Any] = []
    var elemsToDisplayArray: [Any] = []
    
    
    var searchBar = "searchBar"
    var loadingViewCell = "loadingViewCell"
    var searchUsers = "Search users"
    var friendUpdateNotification = "Coming soon: The ability to add friends!"
    var centerVC: CenterVC!
    
    //var segments = ["Search", "Friends", "Requests"]
    var segments = ["Search", "Requests"]
    //must match above
    var searchUserSegment = "Search"
    var requestsSegment = "Requests"
    var connectFBCell = "facebookCell"
    var connectContactsCell = "connectContactsCell"
    
    
    private let refreshControl = UIRefreshControl()
    var receivedRequestsLoading = false
    var searchUserLoading = false
    var askToConnectFB = false
    var askToConnectContacts = false
    var friendRequestsCursorDoc: DocumentSnapshot? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        //segmentControl = UISegmentedControl(items: segments)
        
        let font: [AnyHashable : Any] = [NSAttributedString.Key.font : UIFont(name: "Avenir-heavy", size: 16) as Any]
        segmentControl.setTitleTextAttributes(font as? [NSAttributedString.Key : Any], for: .normal)
        segmentControl.selectedSegmentIndex = 0
        adapter.collectionView = collectionView
        self.view.backgroundColor = .clear
        collectionView.backgroundColor = .clear
        adapter.dataSource = self
        let layout = UICollectionViewFlowLayout()
        self.collectionView.collectionViewLayout = layout
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.showsVerticalScrollIndicator = false
        //let statusBarHeight = UIApplication.shared.statusBarFrame.height
        //self.collectionView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        addGradientView()
        setUpRefresher()
        //fetchAllData(update: true)
        configureAddFriends()
        fetchRequestsData()
    }
    
    func configureAddFriends() {
        //check if user has connected facebook
        if let token = AccessToken.current, !token.isExpired {
            askToConnectFB = false
            let currAccessToken = token.tokenString
            let params = ["fields": "id, first_name, last_name, middle_name, name, email, picture"]
            let request = GraphRequest(graphPath: "me/friends", parameters: params)
            request.start { (connection, result, reqError) in
                if let reqError = reqError {
                    let errorMessage = reqError.localizedDescription
                    print(errorMessage)
                    return
                    /* Handle error */
                }
                if let  result = result {
                    /*  handle response */
                    print("RESULT FROM FRIENDS")
                    print(result)
                }
            }
        } else {
            askToConnectFB = true
            self.adapter.performUpdates(animated: true)
        }
        
        
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)

        // Find out what access level we have currently
        switch authorizationStatus {
        case .authorized:
            askToConnectContacts = false
           
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
    
    func fetchRequestsData() {
        self.receivedRequestsLoading = true
        FirebaseManager.shared.fetchReceivedFriendRequests(cursorDoc: friendRequestsCursorDoc) { (error, requests, lastDoc) in
            self.receivedRequestsLoading = false
            if error != nil || requests.isEmpty {
                self.refreshControl.endRefreshing()
                return
            }
            self.refreshControl.endRefreshing()
            self.friendRequestsCursorDoc = lastDoc
            self.receivedRequestsArray += requests
            self.filteredAllArray = self.receivedRequestsArray
            if self.segmentControl.selectedSegmentIndex == self.segments.firstIndex(of: self.requestsSegment) {
               self.adapter.performUpdates(animated: true)
            }
        }
    }
    
    func searchClicked() {
        self.searchUserLoading = true
        self.filteredAllArray = self.searchArray
    }
    
    func addGradientView() {
        let gradientViewHeight = self.view.frame.height * 0.18
        self.gradientView.frame = CGRect(x: 0, y: self.view.frame.height - gradientViewHeight, width: self.view.frame.width, height: gradientViewHeight)
        let gradientLayer = CAGradientLayer()
        gradientView.backgroundColor = .clear
        gradientView.layer.masksToBounds = false
        gradientLayer.frame = self.gradientView.bounds
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.00675).cgColor, UIColor.black.withAlphaComponent(0.0125).cgColor, UIColor.black.withAlphaComponent(0.025).cgColor,UIColor.black.withAlphaComponent(0.05).cgColor,UIColor.black.withAlphaComponent(0.07).cgColor, UIColor.black.withAlphaComponent(0.09).cgColor, UIColor.black.withAlphaComponent(0.11).cgColor,UIColor.black.withAlphaComponent(0.14).cgColor,UIColor.black.withAlphaComponent(0.17).cgColor,UIColor.black.withAlphaComponent(0.2).cgColor, UIColor.black.withAlphaComponent(0.22).cgColor,UIColor.black.withAlphaComponent(0.24).cgColor, UIColor.black.withAlphaComponent(0.26).cgColor, UIColor.black.withAlphaComponent(0.28).cgColor, UIColor.black.withAlphaComponent(0.3).cgColor, UIColor.black.withAlphaComponent(0.32).cgColor, UIColor.black.withAlphaComponent(0.35).cgColor,UIColor.black.withAlphaComponent(0.37).cgColor]
        self.gradientView.layer.insertSublayer(gradientLayer, at: 0)
        
        print("GRADIENT VIEW FRAME", self.gradientView.frame)
        print("view width", self.view.frame.width)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            FirebaseManager.shared.getCurrentUser { (error, user) in
                if let user = user {
                    Analytics.logEvent("navigated_to_add_friends_page", parameters: ["username": user.username])
                }
            }
        }
    }
    
    func setUpRefresher() {
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
        refreshControl.tintColor = UIColor.init(named: "AppRedColor")!
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    @objc func refreshData() {
        if segmentControl.selectedSegmentIndex == 0 {
            refreshControl.endRefreshing()
        } else if segmentControl.selectedSegmentIndex == 1 {
            if receivedRequestsLoading {
                refreshControl.endRefreshing()
            } else {
                fetchRequestsData()
            }
        }
        
    }
    
    
    @IBAction func segmentControlValueChanged(_ sender: Any) {
        self.refreshControl.endRefreshing()
        switch segmentControl.selectedSegmentIndex {
        case self.segments.firstIndex(of: self.searchUserSegment):
            self.filteredAllArray = searchArray
            self.adapter.performUpdates(animated: true)
        case self.segments.firstIndex(of: self.requestsSegment):
            self.filteredAllArray = self.receivedRequestsArray
            self.adapter.performUpdates(animated: true)
        default:
            return
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        //print("dissappearssssssss")
        self.resignFirstResponder()
        //self.view.endEditing(true)
    }
    
    
    
    
}

extension addFriendsMainVC: searchSCDelegate {
    
    func searchSectionController(_ sectionController: searchBarSC, didChangeText text: String) {
        //print("Searching")
        //isSearching = true
//        if (text == "") {
//            //isSearching = false
//            self.filteredAllArray = allArray
//            self.adapter.performUpdates(animated: true)
//            return
//        }
//        if (!allArray.isEmpty) {
//            var filteredUsers: [Any] = []
//            for user in allArray {
//                if let user = user as? userModel {
//                    if (user.userName.lowercased().contains(text.lowercased())) {
//                        filteredUsers.append(user)
//                    }
//                }
//            }
//            self.filteredAllArray = filteredUsers
//            self.adapter.performUpdates(animated: true)
//        }
    }
    
    
}

extension addFriendsMainVC: ListAdapterDataSource{
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        var screenItems: [ListDiffable] = []
        switch segmentControl.selectedSegmentIndex {
        case self.segments.firstIndex(of: self.searchUserSegment):
//            if (allFetching && filteredAllArray.isEmpty) {
//                screenItems = [searchBar, loadingViewCell] as [ListDiffable]
//            } else {
//                screenItems = [searchBar] + filteredAllArray as! [ListDiffable]
//            }
            screenItems += [searchBar] as [ListDiffable]
            if askToConnectFB {
                screenItems += ([connectFBCell]) as [ListDiffable]
            }
            if askToConnectContacts {
                screenItems += ([connectContactsCell]) as [ListDiffable]
            }
            screenItems += filteredAllArray as! [ListDiffable]
            break
            
        case self.segments.firstIndex(of: self.requestsSegment):
            if (receivedRequestsLoading && filteredAllArray.isEmpty) {
                screenItems = [loadingViewCell] as [ListDiffable]
            } else {
                screenItems = [friendUpdateNotification] + filteredAllArray as! [ListDiffable]
            }
            break
        default:
            screenItems = []
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
        if (object is String && object as! String == connectFBCell) {
            let sc = connectFacebookCellSC()
            return sc
        }
        if (object is String && object as! String == searchUsers) {
            let sc = seperatorCellSC()
            sc.labelText = (object as! String)
            return sc
        }
        if (object is String && object as! String == searchBar) {
            let sc = searchBarSC()
            sc.delegate = self
            return sc
        }
        if (object is String && object as! String == friendUpdateNotification) {
            let sc = seperatorCellSC()
            sc.labelText = (object as! String)
            sc.fontSize = 14
            return sc
        }
        
        if (object is String && object as! String == loadingViewCell) {
            let sc = loadingViewCellSC()
            return sc
        }
        return ListSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        
        return loadingCollectionView(backgroundColor: .clear, indicatorColor: UIColor.init(named: "AppRedColor")!)
    }

}
