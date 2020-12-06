//
//  goToSleepVC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/10.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit
import IGListKit
import AVFoundation
import EasyTipView
import Firebase
import SDWebImage
import Alamofire

protocol goToSleepVCDelegate: class {
    func userHasWokenUp()
}

class goToSleepVC: UIViewController, UNUserNotificationCenterDelegate {

    @IBOutlet weak var collectionView: ListCollectionView!
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    }()
    
    var feedItems = [Any]()
    
    var inSleepMode = false
    
    var currHelper = ""
    
    weak var delegate: goToSleepVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adapter.collectionView = collectionView
        adapter.dataSource = self
        let layout = UICollectionViewFlowLayout()
        self.collectionView.collectionViewLayout = layout
        self.collectionView.alwaysBounceVertical = false
        self.collectionView.showsVerticalScrollIndicator = false
        //disableSilentMode()
        //add tap gesture recognizer to collection view
        //let tap = UITapGestureRecognizer(target: self, action: #selector(self.screenTapped(_:)))
        
        //collectionView.addGestureRecognizer(tap)
        fetchData()
    }
    
    
    func disableSilentMode() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
          try AVAudioSession.sharedInstance().setActive(true)
        } catch {
          //print(error)
        }
    }
    
    
    func fetchData() {
        DispatchQueue.main.async {
            FirebaseManager.shared.getCurrentUser { (error, currUser) in
                guard let currUser = currUser else {
                    return
                }
                let currAlarm = currentAlarm(isSet: currUser.currentAlarm == nil ? false: true, alarmTime: currUser.currentAlarm, alarms: [])
                self.feedItems.append(currAlarm)
                self.adapter.performUpdates(animated: true)
            }
        }
    }
    
    
    
    var alarmAudioToFire: URL?
    var alarmAudioToFireID: String?
    
    //populate with default alarm to be safe
    var alarmsToPlay: [receivedAlarm] = [receivedAlarm(alarm: (["created_at": Date(), "audio_file_url": "", "audio_id": "defaultAlarmSound"] as [String: Any]), sender: userModel(user: ["username": "Wakey", "profile_img_url": ""]), localAudioUrl: URL(fileURLWithPath: Bundle.main.path(forResource: "defaultAlarmSound", ofType: "m4a")!))]
    
    var alarmFireTimer: Timer!
    var fetchAlarmsTimer: Timer!
    
    
    func convertAlarmToDate(time: Date) -> Date {
        let calendar = Calendar.current
        let hour = Calendar.current.component(.hour, from: time)
        let minute = Calendar.current.component(.minute, from: time)
        var whenToFire = calendar.date(
            bySettingHour: hour,
            minute: minute,
            second: 0,
            of: time)!
        if whenToFire < Date() {
            whenToFire = Calendar.current.date(byAdding: .day, value: 1, to: whenToFire)!
        }
        return whenToFire
    }
    
    
    func userDidExitSleepMode() {
        if alarmFireTimer != nil {
            alarmFireTimer.invalidate()
        }
        if fetchAlarmsTimer != nil {
            fetchAlarmsTimer.invalidate()
        }
    }
    
    
    var alarmPlayer = AVAudioPlayer()
    
    @objc func playAlarm() {
        //self.performSegue(withIdentifier: "playAlarmsSegue", sender: alarmsToPlay)
        inSleepMode = false
        self.delegate?.userHasWokenUp()
        //print("pumping up the brightness")
        UIScreen.main.brightness = CGFloat(1)
        self.performSegue(withIdentifier: "playAlarmSegue", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playAlarmSegue" {
            if let nextViewController = segue.destination as? playAlarmVC {
                nextViewController.alarms = alarmsToPlay
            }
        }
    }
    
    
    
 
    
    
}



extension goToSleepVC: ListAdapterDataSource{
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        let screenItems: [ListDiffable] = feedItems as! [ListDiffable]
        return screenItems
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if object is currentAlarm {
            let sc = goToSleepCellSC()
            sc.alarm = (object as! currentAlarm)
            return sc
        }
        return ListSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return loadingCollectionView(backgroundColor: UIColor.init(named: "goToSleepBackgroundColor")!, indicatorColor: UIColor.init(named: "AppRedColor")!)
    }

}




