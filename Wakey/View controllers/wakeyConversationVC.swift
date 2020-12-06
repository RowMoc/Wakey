//
//  wakeyConversationVC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/06/15.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit
import IGListKit
import Firebase

class wakeyConversationVC: UIViewController, UIScrollViewDelegate{
    
    @IBOutlet weak var collectionView: ListCollectionView!
    
    var convo: wakeyConversation!
    var currUserID: String!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var currChatLabel: UILabel!
    
    @IBOutlet weak var navBarView: UIView!
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    }()
    
    var feedItems: [wakeyMessage] = []
    
    
    var cursorDocumentID: String? = nil
    var stillLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let bgImageView = UIImageView(frame: self.view.frame)
        bgImageView.backgroundColor = UIColor(named: "collectionViewBackground")
        bgImageView.contentMode = .scaleAspectFill
        bgImageView.image = UIImage(named: "onboardingBackground")
        self.view.insertSubview(bgImageView, at: 0)
        adapter.collectionView = collectionView
        adapter.dataSource = self
        adapter.scrollViewDelegate = self
        let layout = UICollectionViewFlowLayout()
        self.collectionView.collectionViewLayout = layout
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.backgroundColor = .clear
        //self.collectionView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.backButton.imageEdgeInsets = .init(top: 13, left: 20, bottom: 13, right: 5)
        self.backButton.imageView?.contentMode = .scaleAspectFit
        self.currChatLabel.sizeToFit()
        self.currChatLabel.text = convo.other_user.username
        //self.navBarView.addBottomBorderWithColor(color: .systemBackground, width: 0.5)
        self.fetchData()
        
    }
    
    
    func fetchData() {
        stillLoading = true
        FirebaseManager.shared.fetchWakeyConversationMessages(cursorDocumentID: nil, otherUser: convo.other_user,conversationID: convo.conversationID) { (errStr, messages, lastDocID) in
            if let lastDocID = lastDocID {
                self.cursorDocumentID = lastDocID
            }
            self.feedItems = self.feedItems + messages.reversed()
            self.stillLoading = false
            self.refreshCollectionView()
        }
    }
    
    func refreshCollectionView() {
//        self.adapter.reloadData { (complete) in
//            if complete {
//                self.adapter.scroll(
//                    to: self.convo.messages.last as Any,
//                    supplementaryKinds: nil,
//                    scrollDirection: .vertical,
//                    scrollPosition: .bottom,
//                    animated: true
//                )
//            }
//        }
        self.adapter.performUpdates(animated: true, completion: { (complete) in
            if complete {
                self.adapter.scroll(
                    to: self.convo.messages.last as Any,
                    supplementaryKinds: nil,
                    scrollDirection: .vertical,
                    scrollPosition: .bottom,
                    animated: true
                )
            }
        })
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        if let window = UIApplication.shared.delegate?.window as? UIWindow {
            window.backgroundColor = .clear
        }
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: false, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!stillLoading && scrollView.contentOffset.y < -5) {
            //stillLoading = true
            self.adapter.performUpdates(animated: true)
            fetchData()
        }
    }
    
}

extension wakeyConversationVC: ListAdapterDataSource{
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        var screenItems: [ListDiffable] = self.feedItems as [ListDiffable]
        if stillLoading {
            screenItems.insert("loading" as ListDiffable, at: 0)
        }
        return screenItems
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if (object is wakeyMessage) {
            let sc = wakeyMessageCellSC()
            sc.currUserID = self.currUserID
            sc.message = (object as! wakeyMessage)
            return sc
        }
        if (object is String && object as! String == "loading") {
            let sc = loadingViewCellSC()
            return sc
        }
        return ListSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return loadingCollectionView(backgroundColor: UIColor.clear, indicatorColor: UIColor.init(named: "AppRedColor")!)
    }
}
