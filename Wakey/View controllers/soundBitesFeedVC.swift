//
//  soundBitesFeedVC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2021/01/05.
//  Copyright © 2021 Wakey. All rights reserved.
//

import UIKit
import IGListKit
import NVActivityIndicatorView
import AVFoundation
import Alamofire
import Firebase
import InstantSearch

class soundBitesFeedVC: UIViewController {
    
   
    @IBOutlet weak var collectionView: ListCollectionView!
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    }()
    
    private let refreshControl = UIRefreshControl()
    var friendRequestsCursorDoc: DocumentSnapshot? = nil
    
    var loading = false
    
    
    var soundBitesLabel = "soundBitesLabel"
    var noSoundBitesLabel = "noSoundBitesLabel"
    var loadingCell = "loadingCell"
    var soundBites: [soundBite] = []
    
    var firstAppearance = true
    
    var globalPlayer: AVPlayer!
    var cellCurrentlyPlaying: soundBiteFeedCell!
    
    var cursorID: String? = nil
    
    //for search
    private var collectionIndex : Index!
    private var query = Query()
    var searchBar = "searchBar"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter.collectionView = collectionView
        self.view.backgroundColor = .clear
        collectionView.backgroundColor = .clear
        adapter.dataSource = self
        adapter.scrollViewDelegate = self
        let layout = UICollectionViewFlowLayout()
        self.collectionView.collectionViewLayout = layout
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.showsVerticalScrollIndicator = false
        setUpRefresher()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if firstAppearance {
            fetchSoundBites(firstFetch: true)
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
        self.soundBites = []
        if globalPlayer != nil {
            globalPlayer.pause()
            globalPlayer = nil
        }
        self.cursorID = nil
        cellCurrentlyPlaying = nil
        fetchSoundBites(firstFetch: false)
    }
    
    func fetchSoundBites(firstFetch: Bool) {
        loading = true
        self.adapter.performUpdates(animated: false)
        let limit = 8
        FirebaseManager.shared.fetchSoundBites(cursorID: cursorID, limit: limit) { (error, newSoundBites, newCursorID) in
            self.loading = false
            self.refreshControl.endRefreshing()
            if error != nil {
                self.adapter.performUpdates(animated: true)
            } else {
                self.soundBites += newSoundBites
                self.cursorID = newCursorID
                self.adapter.performUpdates(animated: true)
            }
        }
    }
    
    
    func stopSoundCurrentlyPlaying() {
        if globalPlayer != nil {
            globalPlayer.pause()
            globalPlayer = nil
        }
        if cellCurrentlyPlaying != nil {
            cellCurrentlyPlaying.sc.currPlayingState = soundBiteFeedCellSC.playButtonState.notPlaying
            cellCurrentlyPlaying.sc.configurePlayButton(cell: cellCurrentlyPlaying, isPlaying: soundBiteFeedCellSC.playButtonState.notPlaying)
            cellCurrentlyPlaying = nil
        }
    }
    
    
    func userPressedPlay(cell: soundBiteFeedCell, soundBite: soundBite) {
        if cellCurrentlyPlaying != nil, cellCurrentlyPlaying.sc.soundBite == cell.sc.soundBite {
            //player did press stop on a sound bite that was already playing, so stop it
            if globalPlayer != nil {
                globalPlayer.pause()
                globalPlayer = nil
            }
            cellCurrentlyPlaying.sc.currPlayingState = soundBiteFeedCellSC.playButtonState.notPlaying
            cellCurrentlyPlaying.sc.configurePlayButton(cell: cellCurrentlyPlaying, isPlaying: soundBiteFeedCellSC.playButtonState.notPlaying)
            cellCurrentlyPlaying = nil
            return
        }
        stopSoundCurrentlyPlaying()
        
        //play the sound  bite the user just pressed
        let url  = URL.init(string: soundBite.audioUrl)
        let playerItem: AVPlayerItem = AVPlayerItem(url: url!)
        globalPlayer = AVPlayer(playerItem: playerItem)
    
        let playerLayer = AVPlayerLayer(player: globalPlayer!)
        cell.sc.currPlayingState = soundBiteFeedCellSC.playButtonState.loading
        cell.sc.configurePlayButton(cell: cell, isPlaying: soundBiteFeedCellSC.playButtonState.loading)
        playerLayer.frame = CGRect(x: 0, y: 0, width: 10, height: 50)
        self.view.layer.addSublayer(playerLayer)
        globalPlayer.play()
        cellCurrentlyPlaying = cell
        
        //add observers to know when the audio starts playing
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        globalPlayer.addObserver(self, forKeyPath: "status", options: [.old, .new], context: nil)
        if #available(iOS 10.0, *) {
            globalPlayer.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        } else {
            globalPlayer.addObserver(self, forKeyPath: "rate", options: [.old, .new], context: nil)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as AnyObject? === globalPlayer {
            if keyPath == "status" {
                if globalPlayer.status == .readyToPlay {
                    //globalPlayer.play()
                    cellCurrentlyPlaying.sc.currPlayingState = soundBiteFeedCellSC.playButtonState.playing
                    cellCurrentlyPlaying.sc.configurePlayButton(cell: cellCurrentlyPlaying, isPlaying: soundBiteFeedCellSC.playButtonState.playing)
                }
            }
        }
    }
    
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        print("audio Finished")
        if cellCurrentlyPlaying == nil {
            return
        }
        if globalPlayer != nil {
            globalPlayer.pause()
            globalPlayer = nil
        }
        cellCurrentlyPlaying.sc.currPlayingState = soundBiteFeedCellSC.playButtonState.notPlaying
        cellCurrentlyPlaying.sc.configurePlayButton(cell: cellCurrentlyPlaying, isPlaying: soundBiteFeedCellSC.playButtonState.notPlaying)
        cellCurrentlyPlaying = nil
    }
    
}


extension soundBitesFeedVC: searchSCDelegate {
    
    func setupAlgoliaSearch() {
        let searchClient = SearchClient(appID: "IHBKQU1Z44", apiKey: "7e0cf1eb9e2003ccb6013ca11049610c")
        let indexName = "USERS"
        collectionIndex = searchClient.index(withName: IndexName(rawValue: indexName))
        query.hitsPerPage = 20
    }
    
    struct sound_bite_hit: Decodable {
        let objectID: String
        let audio_url: String
        //let created_at: Any
        let title: String
        let transcript: String
        let category: String
        let associated_profile: [String:String]
        let image_url: String
        var times_sent: Int
        let explicit: Bool
    }
    
    func convertdecodableToUser(hits: [sound_bite_hit]) -> [soundBite] {
        var sbs: [soundBite] = []
        for hit in hits {
            let associatedUser = userModel(user: hit.associated_profile)
            let unseenResultSb = soundBite(soundBite:["object_id": hit.objectID, "image_url": hit.image_url, "title": hit.title, "category": hit.category, "explicit": hit.explicit] as [String : Any],
                                           associatedProfile: associatedUser ,
                                           localAudioUrl: nil)
            sbs.append(unseenResultSb)
        }
        return sbs
    }
    
    
    func searchCollection(forText searchString : String) {
        query.query = searchString
        collectionIndex.search(query: query) { (result) in
            if case .success(let response) = result {
                do {
                    let hits: [sound_bite_hit] = try response.extractHits()
                    let hitsModeled = self.convertdecodableToUser(hits: hits)
                    
                    //self.searchResults = self.convertdecodableToUser(hits: hits)
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
//        if let recycleResIndex = recycledResults.firstIndex(where: { $0.userID == updatedUser.userID}) {
//            recycledResults[recycleResIndex].friendshipID = requestID
//            recycledResults[recycleResIndex].friendshipStatus = status
//            sc.user = recycledResults[recycleResIndex]
//            if let searchResIndex = searchResults.firstIndex(where: { $0.userID == updatedUser.userID}) {
//                searchResults[searchResIndex] = recycledResults[recycleResIndex]
//            }
//            if let contactsResIndex = foundInContacts.firstIndex(where: { $0.userID == updatedUser.userID}) {
//                foundInContacts[contactsResIndex] = recycledResults[recycleResIndex]
//            }
//        }
    }
    
}


extension soundBitesFeedVC: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset:UnsafeMutablePointer<CGPoint>) {
        let distance = scrollView.contentSize.height - (targetContentOffset.pointee.y + scrollView.bounds.height)
        if !loading && distance < 20 {
            loading = true
            adapter.performUpdates(animated: true, completion: nil)
            fetchSoundBites(firstFetch: false)
        }
    }
}

extension soundBitesFeedVC: ListAdapterDataSource{
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        var screenItems: [ListDiffable] = []
        if loading {
            screenItems += ([searchBar]) as [ListDiffable]
            if soundBites.isEmpty {
                screenItems += ([soundBitesLabel, loadingCell]) as [ListDiffable]
            } else {
                screenItems += ([soundBitesLabel]) as [ListDiffable]
                screenItems += soundBites as [ListDiffable]
                screenItems += ([loadingCell]) as [ListDiffable]
            }
        } else {
            if soundBites.isEmpty {
                screenItems += ([noSoundBitesLabel]) as [ListDiffable]
            } else {
                screenItems += ([soundBitesLabel]) as [ListDiffable]
                screenItems += soundBites
            }
        }
        return screenItems
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if object is soundBite {
            let sc = soundBiteFeedCellSC()
            sc.soundBite = (object as! soundBite)
            if (cellCurrentlyPlaying != nil && (cellCurrentlyPlaying.sc.soundBite.objectID == (object as! soundBite).objectID)) {
                sc.currPlayingState = soundBiteFeedCellSC.playButtonState.playing
            } else {
                sc.currPlayingState = soundBiteFeedCellSC.playButtonState.notPlaying
            }
            return sc
        }
        if (object is String && object as! String == loadingCell) {
            let sc = loadingViewCellSC()
            return sc
        }
        if (object is String && object as! String == soundBitesLabel) {
            let sc = seperatorCellSC()
            sc.fontSize = 15
            sc.labelText = "Browse sound bites from your favorite movies and people"
            return sc
        }
        if (object is String && object as! String == noSoundBitesLabel) {
            let sc = seperatorCellSC()
            sc.fontSize = 15
            sc.labelText = "No content at the moment!"
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
