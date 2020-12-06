//
//  playAlarmVC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/12.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit
import AVFoundation
import IGListKit
import NVActivityIndicatorView
import Firebase
import MediaPlayer
import UserNotifications

class playAlarmVC: UIViewController, AVAudioPlayerDelegate {
    
    @IBOutlet weak var collectionView: ListCollectionView!
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    }()
    
    var presented = true
    
    
    var alarms: [receivedAlarm] = []
    var alarmToPlay: receivedAlarm!
    var previousAlarmBGTint: UIColor? = nil
    
    var audioWasPausedBeforeReaction = false
    var currAlarmIndex = 0

    var meterTimer:Timer!
    var wakeyMessageLength: Double!
    //for reacting
    var reactionViewContainer: UIView!
    var curAlarmCell: playAlarmCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("THE ALARMS ARE HERE:")
        //print(alarms)
        setupSpeakers()
        alarmToPlay = alarms[currAlarmIndex]
        adapter.collectionView = collectionView
        adapter.dataSource = self
        let layout = UICollectionViewFlowLayout()
        self.collectionView.collectionViewLayout = layout
        self.collectionView.alwaysBounceVertical = false
        self.collectionView.isScrollEnabled = false
        self.collectionView.showsVerticalScrollIndicator = false
        prepareNextAlarmAudio()
        self.adapter.reloadData()
        //ANALYTICS
        DispatchQueue.main.async {
            FirebaseManager.shared.getCurrentUser { (error, user) in
                if let user = user {
                    Analytics.logEvent("wake_up", parameters: [ "username": user.username, "num_alarms_received": self.alarms.count])
                }
            }
        }
    }
    
    
    func setupSpeakers() {
        MPVolumeView.setVolume(1)
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            //print("couldn't set audio source to speakers")
        }
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    func userDidExit() {
        meterTimer.invalidate()
        nextAlarmSound?.stop()
        alarmPlayer?.stop()
        nextAlarmSound = nil
        alarmPlayer = nil
        presented = false
        dismiss(animated: true) {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    
    
    
    var nextAlarmSound: AVAudioPlayer?
    
    var reactionSound: AVAudioPlayer?
    
    func prepareNextAlarmAudio() {
        do {
            nextAlarmSound = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "nextAlarmSound", ofType: "m4a")!))
            nextAlarmSound?.delegate = self
            nextAlarmSound?.prepareToPlay()
        } catch {
            //print(error)
        }
        do {
            
            reactionSound = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "reactionSelected", ofType: "m4a")!))
            reactionSound?.delegate = self
            reactionSound?.prepareToPlay()
        } catch {
            //print(error)
        }
    }

    
    
    func configAndPlay(localAudioUrl: URL, alarmAudioID: String, cell: playAlarmCell) {
        var audioUrl = URL(fileURLWithPath: Bundle.main.path(forResource: "defaultAlarmSound", ofType: "m4a")!)
        if localAudioUrl.absoluteString.lowercased().contains("library/sounds") {
            audioUrl = fetchAudioUrl(absoluteUrl: localAudioUrl)
        }
        //determine how long it is
        curAlarmCell = cell
        curAlarmCell.timeSentLabel.text = String(currAlarmIndex + 1) + "/" + String(alarms.count)
        cell.pausePlayButton.setTitle("Pause", for: .normal)
        cell.pausePlayButton.layoutIfNeeded()
        let asset = AVURLAsset(url: audioUrl, options: nil)
        let audioDuration = asset.duration
        wakeyMessageLength = audioDuration.seconds
        playAlarm(alarmAudioToFire: audioUrl, alarmAudioToFireID: alarmAudioID)
    }
    
    
    func fetchAudioUrl(absoluteUrl: URL) -> URL {
        let resourceNames = absoluteUrl.absoluteString.components(separatedBy: "/")
        let soundsDirectoryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent("Sounds")
        //Library/Sounds
        do {
            try FileManager.default.createDirectory(atPath: soundsDirectoryURL.path,
                                            withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            //print("COULDNT CREATE DIRECTORY")
            //print("Error: \(error.localizedDescription)")
        }
        //let fileURL = documentsURL.appendingPathComponent("wakey_message_sent_" + pathPrefix + ".m4a")
        let fileURL = soundsDirectoryURL.appendingPathComponent(resourceNames.last!)
        return fileURL
    }
    
    var alarmPlayer: AVAudioPlayer?
    
    var alarmsMarkedAsPlayed: [String] = []
    
    func playAlarm(alarmAudioToFire: URL, alarmAudioToFireID: String) {
        do {
            self.alarmPlayer = try AVAudioPlayer(contentsOf: alarmAudioToFire)
            alarmPlayer?.delegate = self
            alarmPlayer?.prepareToPlay()
            alarmPlayer?.volume = 1.0
            alarmPlayer?.play()
            //print("playing alarm")
            meterTimer = Timer.scheduledTimer(timeInterval: 0.05, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats: true)
            //only mark that the alarm has been heard if it's the first time we're playing it
            if !alarmsMarkedAsPlayed.contains(alarmAudioToFireID) {
                alarmsMarkedAsPlayed.append(alarmAudioToFireID)
                DispatchQueue.main.async {
                    FirebaseManager.shared.wakeUp(usedAlarm: true, audioID: alarmAudioToFireID) { (error) in
                        if let error = error {
                            //print("failed to set alarm has_been_heard to false")
                            //print(error)
                        }
                    }
                }
                
            }
        } catch let error as NSError {
            //self.player = nil
            //print(error.localizedDescription)
        } catch {
            //print("AVAudioPlayer init failed")
        }
    }
    
    @objc func updateAudioMeter(timer: Timer) {
        if alarmPlayer == nil {return}
        let sec = CGFloat(alarmPlayer!.currentTime)
        let totalTimeString = String(format: "%.1f", arguments: [sec]) + " / " + String(format: "%.1f", arguments: [self.wakeyMessageLength]) + " s"
        curAlarmCell.progressText.text = totalTimeString
        curAlarmCell.progressBar.progressValue = CGFloat(CGFloat(sec)/CGFloat(wakeyMessageLength) * 100.0)
    }
    
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        //print("finished playing this sound: ")
        //print(player)
        if !presented {return}
        if player == alarmPlayer {
            meterTimer.invalidate()
            reflectAudioEnding()
            updateIndex(fastForward: false, rewind: false)
        } else if player == nextAlarmSound {
            self.adapter.reloadData()
        }
    }
    
    func reflectAudioEnding() {
        curAlarmCell.progressBar.progressValue = 100
        curAlarmCell.progressText.text = String(format: "%.1f", arguments: [wakeyMessageLength]) + " / " + String(format: "%.1f", arguments: [self.wakeyMessageLength]) + " s"
    }
    
    
    func pausePlayWasPressed() {
        //print("vc hears it")
        if let alarmPlayer = alarmPlayer {
            //print("inside")
            if (alarmPlayer.isPlaying) {
                curAlarmCell.activityIndicator.stopAnimating()
                alarmPlayer.stop()
                curAlarmCell.pausePlayButton.setTitle("Play", for: .normal)
                curAlarmCell.pausePlayButton.layoutIfNeeded()
            } else {
                curAlarmCell.activityIndicator.startAnimating()
                alarmPlayer.play()
                curAlarmCell.pausePlayButton.setTitle("Pause", for: .normal)
                curAlarmCell.pausePlayButton.layoutIfNeeded()
            }
        }
    }
    
    func rewindWasPressed() {
        alarmPlayer?.stop()
        self.curAlarmCell.progressBar.progressValue = 0
        self.curAlarmCell.progressText.text = String(format: "%.1f", arguments: [0]) + " / " + String(format: "%.1f", arguments: [self.wakeyMessageLength]) + " s"
        meterTimer.invalidate()
        updateIndex(fastForward: false, rewind: true)
    }
    
    func fastForwardWasPressed() {
        alarmPlayer?.stop()
        self.curAlarmCell.progressBar.progressValue = 0
        self.curAlarmCell.progressText.text = String(format: "%.1f", arguments: [0]) + " / " + String(format: "%.1f", arguments: [self.wakeyMessageLength]) + " s"
        meterTimer.invalidate()
        updateIndex(fastForward: true, rewind: false)
    }
    
    
    
    func playNextAlarm(actionPressed: Bool) {
        if !presented { return}
        alarms[currAlarmIndex].timePlayed = Date()
        if let timesPlayed = alarms[currAlarmIndex].numTimesPlayed {
            alarms[currAlarmIndex].numTimesPlayed = timesPlayed + 1
        }
        alarms[currAlarmIndex].numTimesPlayed = 1
        alarmToPlay = alarms[currAlarmIndex]
        if actionPressed {
            self.nextAlarmSound?.play()
        } else {
            self.curAlarmCell.progressBar.progressValue = 0
            self.curAlarmCell.progressText.text = String(format: "%.1f", arguments: [0]) + " / " + String(format: "%.1f", arguments: [self.wakeyMessageLength]) + " s"
            self.nextAlarmSound?.play()
            
        }
        
    }
    
    func updateIndex( fastForward: Bool, rewind: Bool) {
        if fastForward {
            currAlarmIndex += 1
        } else if rewind {
            currAlarmIndex -= 1
        } else {
            currAlarmIndex += 1
        }
        if currAlarmIndex >= alarms.count || currAlarmIndex < 0 {
            currAlarmIndex = 0
        }
        playNextAlarm(actionPressed: fastForward || rewind)
    }
    
    
}


extension playAlarmVC: reactionViewDelegate {
    
    
    func userDidReactWith(emojiName: String, forAlarm: receivedAlarm) {
        reactionSound?.play()
        //print("button was heard: " + emojiName)
        DispatchQueue.main.async {
            FirebaseManager.shared.sendReaction(reactedToAlarm: forAlarm, reactionString: emojiName) { (resultString) in
                let contView = UIView(frame: CGRect(x: UIScreen.main.bounds.width/2 - 80, y: UIScreen.main.bounds.height/2 - 20, width: 160, height: 40))
                let notifView = UILabel(frame: CGRect(x: 10, y: 0, width: 140, height: 40))
                //notifView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                contView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                contView.layer.cornerRadius = 4
                
                notifView.font = UIFont(name: "Avenir-heavy", size: 12)
                notifView.adjustsFontSizeToFitWidth = true
                notifView.textAlignment = .center
                notifView.textColor = .white
                notifView.text = resultString
                contView.addSubview(notifView)
                UIApplication.shared.keyWindow!.addSubview(contView)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    UILabel.animate(withDuration: 0.5, animations: {
                        contView.alpha = 0
                    }) { (success) in
                        contView.removeFromSuperview()
                    }
                }
            }
        }
        DispatchQueue.main.async {
            FirebaseManager.shared.getCurrentUser { (error, user) in
                if let user = user {
                    Analytics.logEvent("user_reacted", parameters: ["username": user.username, "reaction": emojiName])
                }
            }
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.reactionViewContainer.alpha = 0.1
        }) { (success) in
            self.reactionViewContainer.removeFromSuperview()
            self.startAudioAfterReactionDismisses()
        }
    }
    
    func startAudioAfterReactionDismisses() {
        if audioWasPausedBeforeReaction {return}
        if let alarmPlayer = self.alarmPlayer {
            //print("inside")
            if (alarmPlayer.isPlaying) {
                //shouldn't be doing this but whatever
            } else {
                self.curAlarmCell.activityIndicator.startAnimating()
                alarmPlayer.play()
                self.curAlarmCell.pausePlayButton.setTitle("Pause", for: .normal)
                self.curAlarmCell.pausePlayButton.layoutIfNeeded()
            }
        }
    }
    
    @objc func escapeFromReactionView(gesture: UITapGestureRecognizer) {
        //print("tap/swipe was heard")
        UIView.animate(withDuration: 0.2, animations: {
            self.reactionViewContainer.alpha = 0.1
        }) { (success) in
            self.reactionViewContainer.removeFromSuperview()
            self.startAudioAfterReactionDismisses()
        }
    }
    
    
    func userDidSwipeToReact(duringAlarm: receivedAlarm) {
        if let alarmPlayer = self.alarmPlayer {
            //print("inside")
            if (alarmPlayer.isPlaying) {
                audioWasPausedBeforeReaction = false
                curAlarmCell.activityIndicator.stopAnimating()
                alarmPlayer.stop()
                curAlarmCell.pausePlayButton.setTitle("Play", for: .normal)
                curAlarmCell.pausePlayButton.layoutIfNeeded()
            } else {
                audioWasPausedBeforeReaction = true
            }
        }
        reactionViewContainer = UIView(frame: self.view.bounds)
        reactionViewContainer.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        let firstFrame = CGRect(x: 0, y: 40, width: self.view.bounds.width, height: self.view.bounds.height)
        let reactionView = ReactionsView(frame: firstFrame)
        reactionView.reactingToAlarm = duringAlarm
        reactionView.delegate = self
        reactionView.alpha = 0.1
        reactionView.titleLabel.text = "Replying to " + duringAlarm.sender.username
        reactionViewContainer.addSubview(reactionView)
        self.view.addSubview(reactionViewContainer)
        let tap = UITapGestureRecognizer(target: self, action: #selector(escapeFromReactionView))
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(escapeFromReactionView))
        swipe.direction = .down
        reactionView.contentView.addGestureRecognizer(tap)
        reactionView.contentView.addGestureRecognizer(swipe)
        UIView.animate(withDuration: 0.15, animations: {
            reactionView.frame = self.view.bounds
            reactionView.alpha = 1
        }) { (success) in
            //
        }
        
    }
    
    
}


extension playAlarmVC: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        let screenItems: [ListDiffable] = [alarmToPlay] as! [ListDiffable]
        return screenItems
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if object is receivedAlarm {
            let sc = playAlarmCellSC()
            sc.alarm = (object as! receivedAlarm)
            return sc
        }
        return ListSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return loadingCollectionView(backgroundColor: UIColor.init(named: "goToSleepBackgroundColor")!, indicatorColor: UIColor.init(named: "AppRedColor")!)
    }

}



