//
//  viewRequestsVC.swift
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

class viewRequestsVC: UIViewController {
    
    @IBOutlet weak var collectionView: ListCollectionView!
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    }()
    
    private let refreshControl = UIRefreshControl()
    var friendRequestsCursorDoc: DocumentSnapshot? = nil
    
    var requestsReceivedLoading = false
    
    var requestReceivedLabel = "requestReceivedLabel"
    var noRequestsLabel = "noRequestsLabel"
    var loadingCell = "loadingCell"
    var requestsReceived: [userModel] = []
    
    var firstAppearance = true

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
        setUpRefresher()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if firstAppearance {
            fetchRequestsData()
            firstAppearance = false
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
        self.requestsReceived = []
        fetchRequestsData()
    }
    
    func fetchRequestsData() {
        requestsReceivedLoading = true
        self.adapter.performUpdates(animated: false)
        FirebaseManager.shared.fetchPendingRequestReceived { (error, requestUsers) in
            self.requestsReceivedLoading = false
            self.refreshControl.endRefreshing()
            if error != nil {
                self.adapter.performUpdates(animated: true)
            } else {
                self.requestsReceived = requestUsers
                self.adapter.performUpdates(animated: true)
            }
        }
    }
    
    //called by addFriendSC when a user responds to a friend request
    func userRelationshipStatusDidUpdate(updatedUser: userModel, requestID: String, status: String, sc: addFriendCellSC) {
        if let requestIndex = requestsReceived.firstIndex(where: { $0.userID == updatedUser.userID}) {
            requestsReceived[requestIndex].friendshipID = requestID
            requestsReceived[requestIndex].friendshipStatus = status
            sc.user = requestsReceived[requestIndex]
        }
    }
    
}

extension viewRequestsVC: ListAdapterDataSource{
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        var screenItems: [ListDiffable] = []
        if requestsReceivedLoading {
            screenItems += ([requestReceivedLabel, loadingCell]) as [ListDiffable]
        } else {
            if requestsReceived.isEmpty {
                screenItems += ([noRequestsLabel]) as [ListDiffable]
            } else {
                screenItems += ([requestReceivedLabel]) as [ListDiffable]
                screenItems += requestsReceived
            }
        }
        return screenItems
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if object is userModel {
            let sc = addFriendCellSC()
            sc.user = (object as! userModel)
            return sc
        }
        if (object is String && object as! String == requestReceivedLabel) {
            let sc = seperatorCellSC()
            sc.labelText = "Friend requests received"
            sc.lightText = false
            sc.fontSize = 20
            return sc
        }
        if (object is String && object as! String == noRequestsLabel) {
            let sc = seperatorCellSC()
            sc.labelText = "You have no friend requests at the moment"
            sc.lightText = false
            sc.fontSize = 20
            return sc
        }
        if (object is String && object as! String == loadingCell) {
            let sc = loadingViewCellSC()
            return sc
        }
        return ListSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        
        return loadingCollectionView(backgroundColor: .clear, indicatorColor: UIColor.init(named: "AppRedColor")!)
    }

}

