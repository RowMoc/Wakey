//
//  editProfileVC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/06/16.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit
import IGListKit
import Firebase


class editProfileVC: UIViewController {

    @IBOutlet weak var collectionView: ListCollectionView!
    
    @IBOutlet weak var backButton: UIButton!
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    }()
    
    var currUser: [userModel] = []
    let dailyReminderSettingsCell = "dailyReminderSettingsCell"
    let dailyReminderTimeCell = "dailyReminderTimeCell"
    let logOutCell = "logOutCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let bgImageView = UIImageView(frame: self.view.frame)
        bgImageView.backgroundColor = UIColor(named: "collectionViewBackground")
        bgImageView.contentMode = .scaleAspectFill
        bgImageView.image = UIImage(named: "onboardingBackground")
        self.view.insertSubview(bgImageView, at: 0)
        adapter.collectionView = collectionView
        collectionView.backgroundColor = .clear
        adapter.dataSource = self
        let layout = UICollectionViewFlowLayout()
        self.collectionView.collectionViewLayout = layout
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        fetchProfile()
        

        // Do any additional setup after loading the view.
    }
    
    
    func fetchProfile() {
        FirebaseManager.shared.getCurrentUser { (err, user) in
            if err != nil {
                return
            } else {
                if let user = user {
                    self.currUser = [user]
                    self.adapter.performUpdates(animated: true)
                }
            }
        }
    }
    
    
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromBottom
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        if let window = UIApplication.shared.delegate?.window as? UIWindow {
            window.backgroundColor = .clear
        }
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: false, completion: nil)
    }
    
    
    
}




extension editProfileVC: ListAdapterDataSource{
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        var screenItems: [ListDiffable] = currUser as [ListDiffable]
        screenItems += [dailyReminderSettingsCell, dailyReminderTimeCell, logOutCell] as [ListDiffable]
        return screenItems
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if (object is userModel) {
            let sc = profileHeaderCellSC()
            sc.user = (object as! userModel)
            return sc
        }
        if (object is String && object as! String == self.dailyReminderSettingsCell) {
            let sc = dailyReminderSettingCellSC()
            return sc
        }
        if (object is String && object as! String == self.dailyReminderTimeCell) {
            let sc = dailyReminderTimeCellSC()
            return sc
        }
        if (object is String && object as! String == self.logOutCell) {
            let sc = logOutSettingsCellSC()
            return sc
        }
        return ListSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return loadingCollectionView(backgroundColor: UIColor.init(named: "collectionViewBackground")!, indicatorColor: UIColor.init(named: "AppRedColor")!)
    }
}
