//
//  personalProfileVC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/03.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit
import IGListKit
import Firebase
import SDWebImage


class personalProfileVC: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var collectionView: ListCollectionView!
    @IBOutlet weak var gradientView: UIView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var currUserProfileButton: UIButton!
    @IBOutlet weak var navBarView: UIView!
    
    
    let loadingViewCell = "loadingViewCell"
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    }()
    private let refreshControl = UIRefreshControl()
    let seperatorCell = "Wakey messages"
    var feedItems = [Any]()
    var stillFetching = false
    var centerVC: CenterVC!
    
    var currUserID: String!
    
    //used for pagination nation
    var cursorDocumentID: String? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setupUI()
        searchBar.barTintColor = UIColor.clear
        searchBar.backgroundColor = UIColor.clear
        searchBar.isTranslucent = true
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        //collection view stuff
        self.collectionView.backgroundColor = .clear
        self.view.backgroundColor = .clear
        adapter.collectionView = collectionView
        adapter.dataSource = self
        adapter.scrollViewDelegate = self
        let layout = UICollectionViewFlowLayout()
        self.collectionView.collectionViewLayout = layout
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.showsVerticalScrollIndicator = false
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        //self.collectionView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        addGradientView()
        setUpRefresher()
        setupSearchBar()
        fetchData(firstFetch: true)
    }
    
    func setupSearchBar() {
        searchBar.barTintColor = UIColor.clear
        searchBar.backgroundColor = UIColor.clear
        searchBar.isTranslucent = true
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        
        
        DispatchQueue.main.async {
            FirebaseManager.shared.getCurrentUser { (err, currUser) in
                self.currUserProfileButton.sd_setImage(with: URL(string: currUser?.profilePicUrl ?? ""), for: .normal, placeholderImage:
                self.currUserProfileButton.imageView?.image, options: [.delayPlaceholder]) { (image, err, cacheType, url) in
                    if let err = err {
                        return
                    }
                    self.currUserProfileButton.imageView?.contentMode = .scaleAspectFill
                        self.currUserProfileButton.layer.cornerRadius = self.currUserProfileButton.frame.width/2
                    self.currUserProfileButton.layer.masksToBounds = true
                    self.currUserProfileButton.layer.backgroundColor = UIColor.clear.cgColor
                    self.currUserProfileButton.layer.borderWidth = 1
                    self.currUserProfileButton.layer.borderColor = UIColor(named: "AppRedColor")!.cgColor
                }
            }
        }
    }
    
    func addGradientView() {
        let gradientLayer = CAGradientLayer()
        gradientView.backgroundColor = .clear
        gradientView.layer.masksToBounds = false
        gradientLayer.frame = self.gradientView.bounds
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.00675).cgColor, UIColor.black.withAlphaComponent(0.0125).cgColor, UIColor.black.withAlphaComponent(0.025).cgColor,UIColor.black.withAlphaComponent(0.05).cgColor,UIColor.black.withAlphaComponent(0.07).cgColor, UIColor.black.withAlphaComponent(0.09).cgColor, UIColor.black.withAlphaComponent(0.11).cgColor,UIColor.black.withAlphaComponent(0.14).cgColor,UIColor.black.withAlphaComponent(0.17).cgColor,UIColor.black.withAlphaComponent(0.2).cgColor, UIColor.black.withAlphaComponent(0.22).cgColor,UIColor.black.withAlphaComponent(0.24).cgColor, UIColor.black.withAlphaComponent(0.26).cgColor, UIColor.black.withAlphaComponent(0.28).cgColor, UIColor.black.withAlphaComponent(0.3).cgColor, UIColor.black.withAlphaComponent(0.32).cgColor, UIColor.black.withAlphaComponent(0.35).cgColor,UIColor.black.withAlphaComponent(0.37).cgColor]
        self.gradientView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            FirebaseManager.shared.getCurrentUser { (error, user) in
                if let user = user {
                    Analytics.logEvent("navigated_to_personal_profile", parameters: ["username": user.username])
                }
            }
        }
    }
    
    
    @IBAction func profileButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "editProfileVC") as! editProfileVC
        nextVC.modalPresentationStyle = .fullScreen
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.moveIn
        transition.subtype = CATransitionSubtype.fromTop
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        if let window = UIApplication.shared.delegate?.window as? UIWindow {
            window.backgroundColor = .clear
        }
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.present(nextVC, animated: false, completion: nil)
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
        cursorDocumentID = nil
        feedItems.removeAll()
        fetchData(firstFetch: false)
    }
    
    func fetchData(firstFetch: Bool) {
        stillFetching = true
        DispatchQueue.main.async {
            FirebaseManager.shared.getCurrentUser { (error, user) in
                guard let user = user else {
                    //print(error?.localizedDescription)
                    self.refreshControl.endRefreshing()
                    return
                }
                self.currUserID = user.userID
                FirebaseManager.shared.fetchWakeyConversations(cursorDocument: self.cursorDocumentID, limit: nil) { (errString, conversations, lastDocID) in
                    self.cursorDocumentID = lastDocID
                    self.feedItems += conversations
                    self.stillFetching = false
                    self.adapter.performUpdates(animated: true)
                    self.refreshControl.endRefreshing()
                }
//                FirebaseManager.shared.fetchWakeyConversations(cursorDocument: self.cursorDocument) { (err, conversations, newCursorDoc) in
//                    self.cursorDocument = newCursorDoc
//                    self.feedItems += conversations
//                    self.stillFetching = false
//                    self.adapter.performUpdates(animated: true)
//                    self.refreshControl.endRefreshing()
//                }
            }
        }
    }
    
    
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset:UnsafeMutablePointer<CGPoint>) {
        let distance = scrollView.contentSize.height - (targetContentOffset.pointee.y + scrollView.bounds.height)
        if !stillFetching && distance < 20 {
            stillFetching = true
            adapter.performUpdates(animated: true, completion: nil)
            fetchData(firstFetch: false)
        }
    }

}

extension personalProfileVC: ListAdapterDataSource{
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        var screenItems: [ListDiffable] = [seperatorCell] + feedItems as! [ListDiffable]
        if (feedItems.count == 1 && stillFetching) {
            screenItems.append((self.loadingViewCell as ListDiffable))
        }
        return screenItems
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if (object is wakeyConversation) {
            let sc = wakeyConversationCellSC()
            sc.currUserID = self.currUserID
            sc.convo = (object as! wakeyConversation)
            return sc
        }
        if object is sentAlarm {
            let sc = sentAlarmCellSC()
            sc.sentAlarm = (object as! sentAlarm)
            return sc
        }
        if (object is String && (object as! String) == seperatorCell) {
            let sc = seperatorCellSC()
            sc.labelText = (object as! String)
//            sc.showHelper = true
//            sc.helperText = "All the Wakey messages you've sent will come up here. In the next update you'll be able to see the messages that were sent to you, too!"
            sc.fontSize = CGFloat(30)
            return sc
        }
        if object is userModel {
            let sc = profileHeaderCellSC()
            sc.user = (object as! userModel)
            return sc
        }
        if (object is String && (object as! String) == loadingViewCell) {
            let sc = loadingViewCellSC()
            return sc
        }
        
        
        
        return ListSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
        //return loadingCollectionView(backgroundColor: .clear, indicatorColor: UIColor.init(named: "AppRedColor")!)
    }

}
