//
//  curateAlarmVC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/12/02.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit
import IGListKit
import Firebase

class curateAlarmVC: UIViewController  {
    
    
    @IBOutlet weak var collectionView: ListCollectionView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var alarmInfoLabel: UILabel!
    
    
    //cancel button UI
    @IBOutlet weak var cancelButtonShadowView: UIView!
    @IBOutlet weak var cancelButtonView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    
    var alarmFireDate: Date!
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    }()

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var popUpView: UIView!
    
    var queuedAlarms: [curateListAlarm] = []
    var unopenedAlarms: [curateListAlarm] = []
    var favoritedAlarms: [curateListAlarm] = []
    var defaultAlarms: [curateListAlarm] = []
    var isLoading = true
    var homeVC: ViewController!
    
    let queuedmessagesLabel = "Queued"
    let availableMessagesLabel = "Available wakeys"
    let unopenedMessagesLabel = "Unopened"
    let favoritedMessagesLabel = "Favorited"
    let defaultMessagesLabel = "Default"
    let emptyAlarmLabel = "Create your alarm by choosing from the available wakeys below! 🎙🔊🚨"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("TRYING HARDER")
        adapter.collectionView = collectionView
        collectionView.backgroundColor = UIColor(named: "cellBackgroud")!
        adapter.dataSource = self
        let layout = UICollectionViewFlowLayout()
        self.collectionView.collectionViewLayout = layout
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.showsVerticalScrollIndicator = false
        configPopUpUI()
        let alarmText = DateFormatter.localizedString(from: self.alarmFireDate, dateStyle: .none, timeStyle: .short).replacingOccurrences(of: " ", with: "")
        self.topLabel.text = "CREATE YOUR " + alarmText + " ALARM"
//        self.layer.cornerRadius = 8.0
//        cellBackgroundView.layer.masksToBounds = true
        ensureAlarmNotEmpty()
        //populateWithFakeData()
        fetchAlarms()
    }
    
    func configPopUpUI() {
        shadowView.backgroundColor = UIColor.clear
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
        shadowView.layer.shadowOpacity = 0.4
        shadowView.layer.shadowRadius = 2.0
        
        cancelButtonShadowView.backgroundColor = .clear
        cancelButtonShadowView.layer.shadowColor = UIColor.black.cgColor
        cancelButtonShadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cancelButtonShadowView.layer.shadowOpacity = 0.4
        cancelButtonShadowView.layer.shadowRadius = 2.0
        
        popUpView.layer.cornerRadius = 15.0
        popUpView.layer.masksToBounds = true
        popUpView.backgroundColor = UIColor(named: "cellBackgroud")!
        
        cancelButtonView.layer.cornerRadius = 15.0
        cancelButtonView.layer.masksToBounds = true
        cancelButtonView.backgroundColor = UIColor(named: "cellBackgroud")!
    }

    
    func fetchAlarms() {
        isLoading = true
        FirebaseManager.shared.fetchUnopenedMessages { (error, alarms) in
            self.isLoading = false
            if error != nil {
                return
            } else {
                var index = 0
                for alarm in alarms {
                    let curatedAlarm = curateListAlarm(associatedProfile: alarm.sender, timeReceived: alarm.timeSent, audioFileUrl: alarm.audioUrl, audioLength: 15.0, description: "", messageId: alarm.audioID, curateListCategory: constants.curateAlarmListHeadings.unopenedMessage, isQueued: true, canBeLiked: alarm.canBeLiked, hasBeenLiked: alarm.hasBeenLiked)
                    index += 1
                    //print(String(index) + " ALARM: ")
                    //print(curatedAlarm.messageId)
                    self.queuedAlarms.append(curatedAlarm)
                }
                self.ensureAlarmNotEmpty()
                self.adjustTopLabelInfo()
                self.adapter.performUpdates(animated: true)
            }
        }
    }
    
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.homeVC.popUpShadeView.removeFromSuperview()
        self.dismiss(animated: true)
    }
    
    @IBAction func setAlarmButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "setAlarmVC") as! setAlarmVC
        nextVC.alarmFireDate = alarmFireDate
        nextVC.homeVC = self.homeVC
        nextVC.alarmsToSet = queuedAlarms
        nextVC.modalPresentationStyle = .overFullScreen
        //print("TRYING HARD")
        self.dismiss(animated: false) {
            self.homeVC.present(nextVC, animated: true)
        }
    }
    
    
    
    //delegate func to be used to insert and remove alarms the are added and removed from the queue
    func reorder(thisAlarm: curateListAlarm) -> curateListAlarm {
        if thisAlarm.isQueued {
            queuedAlarms.removeAll(where: { $0.isEqual(toDiffableObject: thisAlarm) })
            thisAlarm.isQueued = false
            switch thisAlarm.curateListCategory {
            case constants.curateAlarmListHeadings.favorited:
                favoritedAlarms.append(thisAlarm)
                favoritedAlarms.sort(by: {$0.timeReceived < $1.timeReceived})
            case constants.curateAlarmListHeadings.unopenedMessage:
                unopenedAlarms.append(thisAlarm)
                unopenedAlarms.sort(by: {$0.timeReceived < $1.timeReceived})
            case constants.curateAlarmListHeadings.defaultAlarm:
                defaultAlarms.append(thisAlarm)
                defaultAlarms.sort(by: {$0.timeReceived < $1.timeReceived})
            default:
                adjustTopLabelInfo()
                return thisAlarm
            }
            adapter.performUpdates(animated: true)
            //adapter.reloadData()
        } else {
            //add this to the queue
            switch thisAlarm.curateListCategory {
            case constants.curateAlarmListHeadings.favorited:
                favoritedAlarms.removeAll(where: { $0.isEqual(toDiffableObject: thisAlarm) })
            case constants.curateAlarmListHeadings.unopenedMessage:
                unopenedAlarms.removeAll(where: { $0.isEqual(toDiffableObject: thisAlarm) })
            case constants.curateAlarmListHeadings.defaultAlarm:
                defaultAlarms.removeAll(where: { $0.isEqual(toDiffableObject: thisAlarm) })
            default:
                return thisAlarm
            }
            thisAlarm.isQueued = true
            queuedAlarms.append(thisAlarm)
            adapter.performUpdates(animated: true)
        }
        ensureAlarmNotEmpty()
        adjustTopLabelInfo()
        return thisAlarm
        
        
    }
    
    
    //used to recalculate how many messages are in your alarm and how long the alarm is
    func adjustTopLabelInfo() {
        var length = 0.0
        for alarm in queuedAlarms {
            length += alarm.audioLength
        }
        let numAlarms = queuedAlarms.count
        if numAlarms == 1 {
            alarmInfoLabel.text = String(queuedAlarms.count) + " wakey, " + String(Int(length)) + " seconds"
        } else {
            alarmInfoLabel.text = String(queuedAlarms.count) + " wakeys, " + String(Int(length)) + " seconds"
        }
    }
    
    func ensureAlarmNotEmpty() {
        if queuedAlarms.isEmpty {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }
    
    
    
}

extension curateAlarmVC: ListAdapterDataSource{
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        if isLoading {
            return [queuedmessagesLabel, "Loading", availableMessagesLabel,unopenedMessagesLabel, "Loading", favoritedMessagesLabel,"Loading", defaultMessagesLabel, "Loading"] as [ListDiffable]
        }
        var screenItems: [ListDiffable] = []
        screenItems += [self.queuedmessagesLabel] as [ListDiffable]
        if queuedAlarms.isEmpty {
            screenItems += [self.emptyAlarmLabel] as [ListDiffable]
        }
        screenItems += self.queuedAlarms as [ListDiffable]
        let numAvailableString = " (" + String(Int(unopenedAlarms.count + favoritedAlarms.count + defaultAlarms.count)) + ")"
        screenItems += [self.availableMessagesLabel + numAvailableString, self.unopenedMessagesLabel] as [ListDiffable]
        screenItems += self.unopenedAlarms as [ListDiffable]
        screenItems += [self.favoritedMessagesLabel] as [ListDiffable]
        screenItems += self.favoritedAlarms as [ListDiffable]
        screenItems += [self.defaultMessagesLabel] as [ListDiffable]
        screenItems += self.defaultAlarms as [ListDiffable]
        return screenItems
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if (object is curateListAlarm) {
            let sc = curateAlarmSC()
            sc.alarm = (object as! curateListAlarm)
            return sc
        }
        if (object is String) {
            if (object as! String == "Loading") {
                let sc = loadingViewCellSC()
                return sc
            } else if ((object as! String).contains(availableMessagesLabel) || object as! String == queuedmessagesLabel) {
                let sc = seperatorCellSC()
                sc.labelText = (object as! String)
                sc.fontSize = 16
                return sc
            } else if (object as! String == emptyAlarmLabel) {
                let sc = seperatorCellSC()
                sc.labelText = (object as! String)
                sc.lightText = true
                sc.fontSize = 14
                return sc
            } else {
                let sc = seperatorCellSC()
                sc.labelText = (object as! String)
                sc.lightText = false
                sc.fontSize = 14
                return sc
            }
        }
        return ListSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return loadingCollectionView(backgroundColor: UIColor.init(named: "collectionViewBackground")!, indicatorColor: UIColor.init(named: "AppRedColor")!)
    }
}
