//
//  ViewController.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/01.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit
import AVFoundation
import LinearProgressBar
import Firebase
import NVActivityIndicatorView
import SDWebImage
import EasyTipView
import PopupDialog



class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UNUserNotificationCenterDelegate {
    
    
    var recPermissionGiven =  false
    
    var recordButtonImage: UIImageView?
    @IBOutlet weak var discardVNButton: TrashButton!
    @IBOutlet weak var sendVNButton: SendButton!
    @IBOutlet weak var goToSleepButton: UIButton!
    @IBOutlet weak var minimumLengthLabel: UILabel!
    @IBOutlet weak var alarmImage: UIImageView!
    
    @IBOutlet weak var labelAboveRecordButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendDiscardStackViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendDiscardButtonsHeightConstraint: NSLayoutConstraint!
    
    
    var centerVC: CenterVC!
    
    @IBOutlet weak var recordingTimeLabel: UILabel!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var meterTimer:Timer!
    var colorChangeTimer: Timer!
    
    let recordImage = "recordSymbol"
    let stopImage = "stopRecording"
    let playImage = "playRecording"
    let pauseImage = "pauseRecording"
    let restartImage = "restartRecording"
    let restartRecording = "restartPlayer"
    let playAnimation = "playAnimation"
    
    let minRecordingLength = 1
    let maxRecordingLength = 30
    var minProgress: CGFloat!
    
    var recordMode = true
    
    //for helpers
    var currHelper = ""
    
    @IBOutlet weak var progressBar: LinearProgressBar!
    
    
    
    //SET UP PAGE UPON LOADING
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordingTimeLabel.adjustsFontSizeToFitWidth = true
        centerVC.delegate = self
        minProgress = CGFloat(minRecordingLength)/CGFloat(maxRecordingLength) * 100.00
        self.loadRecordingUI()
        calibrateRecordingSession()
        self.addBackgroundListeners()
        self.configureConstraints()
        self.configureAlarmButton()
    }
    
    
    func configureConstraints() {
        
        labelAboveRecordButtonBottomConstraint.constant = UIScreen.main.bounds.height - (Layout.centerButtonOriginalY - 20)
        let centreButtonDistFromBottom = UIScreen.main.bounds.height - (Layout.centerButtonOriginalY + Layout.centralButtonLargeHeight)
        let buttonsHeight = (centreButtonDistFromBottom)*(0.5)
        sendDiscardButtonsHeightConstraint.constant = buttonsHeight
        
        sendDiscardStackViewBottomConstraint.constant = (centreButtonDistFromBottom - buttonsHeight)/2
    }
    
    func calibrateRecordingSession() {
        recordingSession = AVAudioSession.sharedInstance()
        switch recordingSession.recordPermission {
        case AVAudioSessionRecordPermission.granted:
            //configSharedAudioSession()
            self.recPermissionGiven = true
            self.addHelpers()
        case AVAudioSessionRecordPermission.denied:
            microphoneNotAllowed()
        case AVAudioSessionRecordPermission.undetermined:
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        //configSharedAudioSession()
                        self.recPermissionGiven = true
                        self.addHelpers()
                    } else {
                        microphoneNotAllowed()
                    }
                }
            }
        @unknown default:
            microphoneNotAllowed()
        }
    }
    
    func configSharedAudioSession() -> Bool {
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers])
            try recordingSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            try recordingSession.setActive(true)
        } catch let error {
            self.microphoneNotAllowed()
            return false
        }
        return true
    }
    
    func microphoneNotAllowed() {
        self.recordingTimeLabel.text = "Allow access to microphone to create a wakey message"
        self.recPermissionGiven = false
        self.centerVC.centerButton.isUserInteractionEnabled = false
    }
    
    
    
    
    
    func loadRecordingUI() {
        print("load recording UI TRIGGERED")
        self.centerVC.unlockCenterScreen()
        invalidateTimers()
        if let audioPlayer = audioPlayer, let audioRecorder = audioRecorder {
            audioPlayer.stop()
            audioRecorder.stop()
        }
        self.centerVC.tintedBackground(color: nil, toDefault: true, buttonLabelsToChange: [self.saveButton, self.cancelButton])
        audioPlayer = nil
        audioRecorder = nil
        goToSleepButton.layer.cornerRadius = 8
        //shadow for alarm button
        
        goToSleepButton.layer.shadowColor = UIColor.black.cgColor
        goToSleepButton.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        goToSleepButton.layer.shadowOpacity = 0.3
        goToSleepButton.layer.shadowRadius = 1
        goToSleepButton.layer.masksToBounds = false
        
        self.centerVC.centerButton.backgroundColor = UIColor(named: "AppRedColor")!
        centerVC.configButtonsForRecording(hide: false)
        configureButton(imageName: recordImage)
        discardVNButton.isHidden = true
        sendVNButton.isHidden = true
        setDefaultLabel()
        recordMode = true
        isPlaying = false
        setMinimumLengthLabel(hidden: true)
        calibrateProgressBar()
        prepareButtonAudio()
    }
    
    var buttonStartClickAudio = AVAudioPlayer()
    var buttonEndClickAudio = AVAudioPlayer()
    var trashButtonAudio = AVAudioPlayer()
    var regularClickAudio = AVAudioPlayer()
    
    func prepareButtonAudio() {
        do {
            buttonStartClickAudio.delegate = self
            buttonStartClickAudio = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "buttonStartClick", ofType: "m4a")!))
            buttonStartClickAudio.volume = 0.2
            buttonStartClickAudio.prepareToPlay()
        } catch {
        }
        
        do {
            buttonStartClickAudio.delegate = self
            buttonEndClickAudio = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "buttonEndClick", ofType: "m4a")!))
            buttonEndClickAudio.volume = 0.2
            buttonEndClickAudio.prepareToPlay()
        } catch {
        }
        
        do {
            trashButtonAudio.delegate = self
            trashButtonAudio = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "trashNoise", ofType: "m4a")!))
            trashButtonAudio.enableRate = true
            trashButtonAudio.rate = 1.7
            trashButtonAudio.volume = 0.2
            trashButtonAudio.prepareToPlay()
        } catch {
        }
        
        do {
            regularClickAudio.delegate = self
            regularClickAudio = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "regularClick", ofType: "m4a")!))
            regularClickAudio.volume = 0.2
            regularClickAudio.prepareToPlay()
        } catch {
        }
    }
    
    
    //RECORDING AUDIO LOGIC
    
    var recordButtonAnimation: NVActivityIndicatorView?
    
    func configureButton(imageName: String) {
        if (recordButtonImage != nil) {
            recordButtonImage?.removeFromSuperview()
        }
        if (recordButtonAnimation != nil) {
            recordButtonAnimation?.removeFromSuperview()
        }
        let imageHeight: CGFloat
        let inset: CGFloat
        let widthToScreenRatio = 0.4 as CGFloat
        let buttonWidth = UIScreen.main.bounds.width * widthToScreenRatio
        switch imageName {
        case recordImage:
            imageHeight = CGFloat(buttonWidth * 0.5)
        case stopImage:
            imageHeight = CGFloat(buttonWidth * 0.3)
        case playImage:
            imageHeight = CGFloat(buttonWidth * 0.3)
        case pauseImage:
            imageHeight = CGFloat(buttonWidth * 0.3)
        case restartImage:
            imageHeight = CGFloat(buttonWidth * 0.3)
        case restartRecording:
            imageHeight = CGFloat(buttonWidth * 0.3)
        case playAnimation:
            imageHeight = CGFloat(buttonWidth * 0.3)
        default:
            imageHeight = CGFloat(buttonWidth * 0.5)
        }
        
        
        inset = (buttonWidth - imageHeight)/2.0
        let recordImageFrame = CGRect(x: inset, y: inset,width:imageHeight, height: imageHeight)
        if (imageName == playAnimation) {
            recordButtonAnimation = NVActivityIndicatorView(frame: recordImageFrame, type: .lineScalePulseOutRapid, color: .white, padding: 0)
            recordButtonAnimation?.isUserInteractionEnabled = false
            centerVC.centerButton.addSubview(recordButtonAnimation!)
            //recordButton.addSubview(recordButtonAnimation!)
            recordButtonAnimation!.startAnimating()
            return
        }
        recordButtonImage = UIImageView(frame: recordImageFrame)
        recordButtonImage!.contentMode = .scaleAspectFit
        recordButtonImage!.image = UIImage(named: imageName)
        recordButtonImage!.isUserInteractionEnabled = false
        centerVC.centerButton.addSubview(recordButtonImage!)
        //recordButton.addSubview(recordButtonImage!)
        
    }
    
    func calibrateProgressBar() {
        progressBar.progressValue = 0
        let upTo = Float(self.minProgress)
        progressBar.barColorForValue = { value in
            switch value {
            case 0..<upTo:
                return UIColor(named: "AppRedColor")!
            default:
                return UIColor(named: "AppGreenColor")!
            }
        }
    }
    
    
    
    func updateProgressBar(progress: CGFloat) {
        progressBar.progressValue = progress
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func invalidateTimers() {
        if meterTimer != nil {meterTimer.invalidate()}
        if colorChangeTimer != nil {colorChangeTimer.invalidate()}
    }
    
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        invalidateTimers()
        if success {
            self.centerVC.tintedBackground(color: UIColor(named: "AppGreenColor")!, toDefault: false, buttonLabelsToChange: [self.saveButton, self.cancelButton])
            recordMode = false
            configureButton(imageName: playImage)
            discardVNButton.isHidden = false
            sendVNButton.isHidden = false
            DispatchQueue.main.async {
                FirebaseManager.shared.getCurrentUser { (error, user) in
                    if let user = user {
                        Analytics.logEvent("record_messsage", parameters: ["length": self.progressBar.progressValue * CGFloat(self.maxRecordingLength), "username": user.username])
                    }
                }
            }
            
        } else {
            setDidntRecordLabel()
            recordMode = true
            configureButton(imageName: recordImage)
            self.centerVC.centerButton.backgroundColor = UIColor(named: "AppRedColor")
            progressBar.progressValue = CGFloat(0)
            discardVNButton.isHidden = true
            sendVNButton.isHidden = true
            // recording failed :(
        }
    }
    
    
    func setDefaultLabel() {
        let text = "Tap to start recording a wakey message"
        recordingTimeLabel.text = text
        progressBar.isHidden = true
    }
    
    func setDidntRecordLabel() {
        let text = "Tap to start recording a wakey message"
        recordingTimeLabel.text = text
        progressBar.isHidden = true
    }
    
    func setMinimumLengthLabel(hidden: Bool) {
        if (hidden) {
            UILabel.animate(withDuration: 0.2, animations: {
                self.minimumLengthLabel.alpha = 0
            })
            
        } else {
            let text = "Minimum length of " + String(minRecordingLength) + " seconds"
            let myAttributes = [ NSAttributedString.Key.font: UIFont(name: "Avenir-medium", size: 10.0)!,
                                 NSAttributedString.Key.foregroundColor: UIColor.lightGray
            ]
            let myAttrString = NSAttributedString(string: text, attributes: myAttributes)
            self.minimumLengthLabel.alpha = 1
            minimumLengthLabel.attributedText = myAttrString
            minimumLengthLabel.isHidden = false
        }
    }
    
    var buttonNoisePlaying = false
    
    
    func recordTapped() {
        buttonStartClickAudio.volume = 0.2
        performPressAnimation()
        if !recPermissionGiven {
            buttonStartClickAudio.play()
            return
        }
        if (recordMode) {
            if audioRecorder == nil {
                self.centerVC.lockCenterScreen()
                centerVC.configButtonsForRecording(hide: true)
                buttonStartClickAudio.play()
                buttonNoisePlaying = true
                configureButton(imageName: restartImage)
                recordingTimeLabel.text = ""
                progressBar.isHidden = false
                setMinimumLengthLabel(hidden: false)
            } else {
                buttonEndClickAudio.play()
                if (progressBar.progressValue > minProgress) {
                    centerVC.configButtonsForRecording(hide: true)
                    configureButton(imageName: playImage)
                    finishRecording(success: true)
                } else {
                    self.centerVC.unlockCenterScreen()
                    //voice note too short; has to re-record
                    centerVC.configButtonsForRecording(hide: false)
                    setMinimumLengthLabel(hidden: true)
                    configureButton(imageName: recordImage)
                    finishRecording(success: false)
                }
            }
        } else {
            playPressed()
        }
        
        
    }
    
    func playPressed() {
        if(isPlaying) {
            //animateRecordingPlaying(animate: false)
            buttonEndClickAudio.play()
            stopAudio()
        } else  {
            buttonStartClickAudio.play()
            if FileManager.default.fileExists(atPath: getFileUrl().path) {
                //configureButton(imageName: restartRecording)
                configureButton(imageName: playAnimation)
                prepare_play()
                audioPlayer.play()
                isPlaying = true
            } else {
                //configureButton(imageName: restartRecord
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)  {
        if player == buttonStartClickAudio && recordMode {
            buttonNoisePlaying = false
            startRecording()
        } else if player == audioPlayer {
            //animateRecordingPlaying(animate: false)
            //configureButton(imageName: playAnimation)
            isPlaying = false
            configureButton(imageName: playImage)
        }
        
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if ((progressBar.progressValue > minProgress)) {
            //setCategory(toRecord: false)
        }
        if !flag {
            //finishRecording(success: false)
        }
    }
    
    func startRecording() {
        if !self.configSharedAudioSession() {
            return
        }
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
        } catch {
            //print("THIS IS THE FUCKER THAT'S SCREWING THIS UP")
            //print(error.localizedDescription)
            finishRecording(success: false)
            return
        }
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        meterTimer = Timer.scheduledTimer(timeInterval: 0.05, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats: true)
        colorChangeTimer = Timer.scheduledTimer(timeInterval: TimeInterval(minRecordingLength), target:self, selector:#selector(self.messageLengthIsValid), userInfo:nil, repeats: false)
    }
    
    @objc func updateAudioMeter(timer: Timer) {
        
        //if audioRecorder.isRecording {
        let isRec = audioRecorder.isRecording
            let sec = CGFloat(audioRecorder.currentTime)
            if (sec <= CGFloat(maxRecordingLength)) {
                let totalTimeString = String(format: "%.1f", arguments: [sec]) + " s"
                recordingTimeLabel.text = totalTimeString
                updateProgressBar(progress: CGFloat(CGFloat(sec)/CGFloat(maxRecordingLength) * 100.0))
                audioRecorder.updateMeters()
            } else {
                let totalTimeString = String(format: "%.1f", arguments: [CGFloat(maxRecordingLength)])  + " s"
                recordingTimeLabel.text = totalTimeString
                updateProgressBar(progress: 100.0)
                finishRecording(success: true)
            }
            
        //}
    }
    
    
    func performPressAnimation() {
        UIButton.animate(withDuration: 0.05,
                         animations: {
                            self.centerVC.centerButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                            //self.recordButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        },
                         completion: { finish in
                            UIButton.animate(withDuration: 0.05, animations: {
                                //self.recordButton.transform = CGAffineTransform.identity
                                self.centerVC.centerButton.transform = CGAffineTransform.identity
                            })
        })
    }
    
    @objc func messageLengthIsValid() {
        configureButton(imageName: stopImage)
        performColorAnimation(toColor: UIColor(named: "AppGreenColor")!)
        setMinimumLengthLabel(hidden: true)
    }
    
    
    func performColorAnimation(toColor: UIColor) {
        UIButton.animate(withDuration: 0.4,animations: {
                //self.recordButton.backgroundColor = toColor
            self.centerVC.centerButton.backgroundColor = toColor
        })
    }
    

    //to play audio
    var audioPlayer : AVAudioPlayer!
    var isPlaying = false
    
    func getFileUrl() -> URL {
        let filename = "recording.m4a"
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
        return filePath
    }
    
    var audioPlayingIndicator: NVActivityIndicatorView?
    func animateRecordingPlaying(animate: Bool) {
        return
        if (animate) {
            self.progressBar.isHidden = true
            if let audioPlayingIndicator = audioPlayingIndicator {
                audioPlayingIndicator.isHidden = false
                audioPlayingIndicator.startAnimating()
            } else {
                let frame = CGRect(x: progressBar.center.x - 100, y: progressBar.center.y - 30, width: 200, height: 60)
                audioPlayingIndicator = NVActivityIndicatorView(frame: frame, type: .lineScalePulseOutRapid, color: UIColor(named: "AppGreenColor")!, padding: 5)
                self.view.addSubview(audioPlayingIndicator!)
                audioPlayingIndicator!.startAnimating()
            }
            
        } else {
            self.progressBar.isHidden = false
            if let audioPlayingIndicator = audioPlayingIndicator {
                audioPlayingIndicator.stopAnimating()
                audioPlayingIndicator.isHidden = true
            }
        }
    }
    
    func stopAudio() {
        audioPlayer.stop()
        isPlaying = false
        configureButton(imageName: playImage)
    }
    
    func prepare_play() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: getFileUrl())
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
        }
        catch {
        }
    }
    
    //SEND/ DISCARD MESSAGE AUDIO AFTER RECORDING
    
    @IBAction func discardVNPressed(_ sender: Any) {
        self.centerVC.unlockCenterScreen()
        self.centerVC.tintedBackground(color: nil, toDefault: true, buttonLabelsToChange: [self.saveButton, self.cancelButton])
        trashButtonAudio.play()
        recordMode = true
        isPlaying = false
        progressBar.progressValue = 0.0
        audioPlayer = nil
        audioRecorder = nil
        discardVNButton.isHidden = true
        sendVNButton.isHidden = true
        setDefaultLabel()
        performColorAnimation(toColor: UIColor(named: "AppRedColor")!)
        configureButton(imageName: recordImage)
        centerVC.configButtonsForRecording(hide: false)
        DispatchQueue.main.async {
            FirebaseManager.shared.getCurrentUser { (error, user) in
                if let user = user {
                    Analytics.logEvent("trash_messsage", parameters: ["username": user.username])
                }
            }
        }
        
    }
    
    @IBAction func sendVNButtonPressed(_ sender: Any) {
        //regularClickAudio.play()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "SelectRecipientsVC") as! SelectRecipientsVC
        nextVC.audioURL = getFileUrl()
        nextVC.homeViewController = self
        nextVC.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
        self.present(nextVC, animated: true, completion: nil)
        //self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    
    //SETTING YOUR ALARM
    
    
    //part 1: BG listeners
    
    func addBackgroundListeners() {
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIScene.willDeactivateNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIScene.willEnterForegroundNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        }
    }
    
    @objc func appMovedToForeground() {
        if appIsReturningFromBackground {
            appIsReturningFromBackground = false
            self.determineNotificationAuth()
        }
    }
    
    @objc func willResignActive() {
        self.appIsReturningFromBackground = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            FirebaseManager.shared.getCurrentUser { (error, user) in
                if let user = user {
                    Analytics.logEvent("navigated_to_main_screen", parameters: ["username": user.username])
                }
            }
        }
    }
    
    //part 2: Set up alarm button upon first load
    
    func configureAlarmButton() {
        //0. Spawn activity indicator, setup UI
        //1. Check if user has set an alarm
        //2. Configure appropriately
        
        //0.
        //let loadingIndFrame = CGRect(x: 0, y: 5, width: goToSleepButton.bounds.width, height: goToSleepButton.bounds.height - 10)
        loadingAlarmIndicator = NVActivityIndicatorView(frame: goToSleepButton.bounds, type: .lineScale, color: .white ,padding: 15)
        loadingAlarmIndicator.startAnimating()
        self.goToSleepButton.addSubview(loadingAlarmIndicator)
        self.goToSleepButton.setAttributedTitle(NSAttributedString(string: ""), for: .normal)
        self.goToSleepButton.isEnabled = false
        alarmCountdownLabel.textColor = UIColor.init(named: "defaultTextColor")!
        alarmCountdownLabel.textAlignment = .center
        determineNotificationAuth()
    }
    
    
    //part 3: Check if user has allowed us to send them notifications
    func determineNotificationAuth() {
        //must hide these in the event that user pressed set alarm before going into background
        if cancelButton != nil {
            cancelButton.isHidden = true
        }
        if saveButton != nil {
            saveButton.isHidden = true
        }
        if timePicker != nil {
            timePicker.isHidden = true
        }
        alarmImage.isHidden = false
        goToSleepButton.isHidden = false
        
        //Check if we can send notifcations to the user
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        let options: UNAuthorizationOptions
        if #available(iOS 12.0, *) {
            options = [.alert, .badge, .sound, .criticalAlert]
        } else {
            options = [.alert, .badge, .sound]
        }
        //remove all delivered nbotifications
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        center.requestAuthorization(options: [options]) { (granted, error) in
            // Enable or disable features based on authorization.
            if error != nil {
            } else {
                if granted {
                    
                    //Check if user has an alarm that has been played over notifcations
                    //If yes, we present PlayWakeyAlarms screen
                    //If no, we check if alarm is set
                    //part 4: See if alarms has played
                    DispatchQueue.main.async {
                        self.checkIfAlarmHasBeenSet(alarmPlayedWhileAppInForeground: false)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.configButtonWithNoPermission()
                    }
                    
                }
            }
        }
    }
    
    var alarmIsSet = false
    //part 4: Check if an alarm has been set.
    func checkIfAlarmHasBeenSet(alarmPlayedWhileAppInForeground: Bool) {
        //Do this with core data instead of notification history
        if let scheduledAlarmDictionary = UserDefaults.standard.array(forKey: constants.scheduledAlarms.scheduledAlarmDictionaryKey) as? [[String: Any]] {
            
            //user has set an alarm. Check if it has been played
            checkIfSetAlarmHasPlayed(scheduledAlarmArray: scheduledAlarmDictionary)
        } else {
            //Alarm has not been set
            self.configButtonWithNoAlarm()
        }
        
    }
    
    //Part 5: Alarm has been set; check if the fire time has passed: If it has, present the alarm as wakey
    //messages. If it hasn't, configure the alarm button with the correct time.
    func checkIfSetAlarmHasPlayed(scheduledAlarmArray: [[String: Any]]) {
        if let alarmFireTime = UserDefaults.standard.object(forKey: constants.scheduledAlarms.alarmSetForTimeKey) as? Date {
            print("In Part 5")
            if (alarmFireTime < Date()) {
                print("In Part 5: Alarm has played; present now")
                //alarm has played. Present the alarms and delete the local dictionary before doing so
                self.prepareScreenForWakeyMessagePresentation(wakeyMessages: convertDictionariesToReceivedAlarms(wakeyMessages: scheduledAlarmArray))
            } else {
                //alarm is yet to go off. Configure the alarm button with the correct time.
                self.alarmHasBeenSet(alarmFireTimeDate: alarmFireTime)
            }
        } else {
            //Can't find alarm fire time
        }
    }
    
    //used from setAlarmvC
    func alarmHasBeenSet(alarmFireTimeDate: Date) {
        self.alarmIsSet = true
        self.alarmFireDate = alarmFireTimeDate
        self.setAlarmButtonWithDate()
    }
    
    
    //Part 5: Helper method
    
    func convertDictionariesToReceivedAlarms(wakeyMessages: [[String: Any]]) -> [receivedAlarm] {
        print("Converting to receieved alarms; this is the incoming array:")
        print(wakeyMessages)
        var alarms: [receivedAlarm] = []
        for wakeyMessage in wakeyMessages {
            let audioID = wakeyMessage[constants.scheduledAlarms.audioIDKey] as? String ?? ""
            //Maybe make defualt value the defaunlt alarm audio path?
            let localAudioUrl = URL(fileURLWithPath: wakeyMessage[constants.scheduledAlarms.localAudioUrlKey] as? String ?? "")
            let senderID = wakeyMessage[constants.scheduledAlarms.senderIDKey] as? String ?? ""
            let username = wakeyMessage[constants.scheduledAlarms.senderUsernameKey] as? String ?? ""
            let profilePicUrl = wakeyMessage[constants.scheduledAlarms.senderProfilePicUrlKey] as? String ?? ""
            let timeSent = wakeyMessage[constants.scheduledAlarms.timeSentKey] as? Date ?? Date()
            let canBeLiked = wakeyMessage[constants.scheduledAlarms.alarmCanBeLikedKey] as? Bool ?? false
            let hasBeenLiked = wakeyMessage[constants.scheduledAlarms.alarmHasBeeenLikedKey] as? Bool ?? false
            alarms.append(receivedAlarm(alarm: ["created_at" : timeSent, "audio_id": audioID, "has_been_liked": hasBeenLiked, "can_be_liked": canBeLiked], sender: userModel(user: ["user_id" : senderID, "username": username, "profile_img_url": profilePicUrl]), localAudioUrl: localAudioUrl))
        }
        return alarms
    }
    
    
   
    
    
    //Part 6: Play wakey messages while app is in foreground if alarm fire sate has passed
    func prepareScreenForWakeyMessagePresentation(wakeyMessages: [receivedAlarm]) {
        self.displayWakeyMessages(wakeyMessages: wakeyMessages)
    }
    
    func displayWakeyMessages(wakeyMessages: [receivedAlarm]) {
        //delete local storage of alarms
        self.popUpVC = nil
        UserDefaults.standard.removeObject(forKey: constants.scheduledAlarms.scheduledAlarmDictionaryKey)
        UserDefaults.standard.synchronize()
        
        if wakeyMessages.isEmpty {return}
        //let sortedWakeyMessages = wakeyMessages.sorted {$0.timeSent < $1.timeSent}
        //segue to playAlarm
        self.configButtonWithNoAlarm()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "playAlarmVC") as! playAlarmVC
        nextVC.alarms = wakeyMessages
        nextVC.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
        
        //present the alarm over the VC the user is currently on
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            print("TOP CONTROLLER")
            print(topController)
            topController.present(nextVC, animated: true, completion: nil)
            // topController should now be your topmost view controller
        } else {
            self.centerVC.present(nextVC, animated: true, completion: nil)
        }
    }
    
    
    
    
    func clearNotifications() {
        //Delete local record of alarm
        UserDefaults.standard.removeObject(forKey: constants.scheduledAlarms.alarmSetForTimeKey)
        UserDefaults.standard.removeObject(forKey: constants.scheduledAlarms.scheduledAlarmDictionaryKey)
        UserDefaults.standard.synchronize()
        //Delete delivered notifications for alarms
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        //delete alarm notifications that are yet to be sent
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
           var identifiers: [String] = []
           for notification:UNNotificationRequest in notificationRequests {
            if notification.identifier.contains(constants.wakeyMessageNotificationIdentifier) {
                  identifiers.append(notification.identifier)
               }
           }
           UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
    
    
    
    func configButtonWithNoAlarm() {
        alarmSet = false
        if loadingAlarmIndicator != nil {
            self.loadingAlarmIndicator.stopAnimating()
            self.loadingAlarmIndicator.removeFromSuperview()
        }
        if alarmCountdownLabel != nil {
            self.alarmCountdownLabel.text = ""
        }
        if alarmCountdownTimer != nil {
            self.alarmCountdownTimer.invalidate()
        }
        let attrTitle = createStringWithEmoji(text: "Set your alarm ", fontSize: 20, emojiName: "asleep_face", textColor: .white, font: "Avenir-heavy")
        self.goToSleepButton.isEnabled = true
        self.goToSleepButton.setAttributedTitle(attrTitle, for: .normal)
        self.goToSleepButton.isHidden = false
        alarmImage.alpha = 0.1
        self.alarmImage.image = UIImage.init(systemName: "alarm")!
        
        //set default red bg
        self.centerVC.currTint = UIColor.init(named: "AppRedColor")!
        self.centerVC.tintedBackground(color: nil, toDefault: false, buttonLabelsToChange: [self.saveButton, self.cancelButton])
    }
    
    
    
    func configButtonWithNoPermission() {
        alarmSet = false
        if loadingAlarmIndicator != nil {
            self.loadingAlarmIndicator.stopAnimating()
            self.loadingAlarmIndicator.removeFromSuperview()
        }
        if alarmCountdownLabel != nil {
            self.alarmCountdownLabel.text = "Allow notifications to set an alarm"
        }
        if alarmCountdownTimer != nil {
            self.alarmCountdownTimer.invalidate()
        }
        let attrTitle = createStringWithEmoji(text: "", fontSize: 30, emojiName: "asleep_face", textColor: .white, font: "Avenir-heavy")
        self.goToSleepButton.isEnabled = false
        self.goToSleepButton.setAttributedTitle(attrTitle, for: .normal)
        self.goToSleepButton.isHidden = false
        alarmImage.alpha = 0.1
        self.alarmImage.image = UIImage.init(systemName: "alarm")!
    }
    
    
    @objc func alarmCountdownTick() {
        let interval = alarmFireDate.timeIntervalSince(Date())
        if interval.isLess(than: 0.0) {
            FirebaseManager.shared.setAsleepProperty(asleepBool: false) { (error) in}
            configButtonWithNoAlarm()
            if let wakeyMessages = UserDefaults.standard.array(forKey: constants.scheduledAlarms.scheduledAlarmDictionaryKey) as? [[String: Any]] {
                
                let wakeys = convertDictionariesToReceivedAlarms(wakeyMessages: wakeyMessages)
                self.prepareScreenForWakeyMessagePresentation(wakeyMessages: wakeys)
                self.alarmCountdownTimer?.invalidate()
            }
            return
        } else {
            alarmCountdownLabel.text = "Alarm will go off in " + interval.stringTime
        }
    }
    
    func setAlarmButtonWithDate() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.beginAlarmCountdown()
        }
        alarmSet = true
        if loadingAlarmIndicator != nil {
            self.loadingAlarmIndicator.stopAnimating()
            self.loadingAlarmIndicator.removeFromSuperview()
        }
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(goToSleepLongPress))
        goToSleepButton.addGestureRecognizer(longGesture)
        
        self.alarmImage.alpha = 1
        self.alarmImage.image = UIImage.init(systemName: "alarm.fill")!
        let alarmText = DateFormatter.localizedString(from: alarmFireDate, dateStyle: .none, timeStyle: .short)
        let attrTitle = createStringWithEmoji(text: alarmText + "  ", fontSize: 25, emojiName: "asleep_face", textColor: .white, font: "Avenir-heavy")
        self.goToSleepButton.setAttributedTitle(attrTitle, for: .normal)
        self.goToSleepButton.isHidden = false
        self.goToSleepButton.isEnabled = true
        
        //set bg tint
        self.centerVC.currTint = UIColor.init(named: "defaultTextColor")!
        self.centerVC.tintedBackground(color: nil, toDefault: false, buttonLabelsToChange: [self.saveButton, self.cancelButton])
        
    }
    
    
    var popUpVC: PopupDialog?
    
    func explainHowAlarmWorks() {
        let reminderCount = UserDefaults.standard.integer(forKey: constants.alarmScreenHelpers.numberOfAlarmsSet)
        if (reminderCount > 7) {
            return
        }
        //let messageStr = "Nice! Congrats on setting an alarm on Wakey. You can be sure that your alarm will go off even if you close the app and/or turn on airplane mode. BUT, make sure that Do Not Disturb and Silent Mode are turned OFF and your volume is turned UP!"
        //configurePopUpForImage(backgroundColor: UIColor.init(named: "collectionViewBackground")!,textColor: UIColor(named: "defaultTextColor")!)
        configurePopUp(backgroundColor: UIColor.init(named: "collectionViewBackground")!,textColor: UIColor(named: "AppRedColor")!)
        UserDefaults.standard.set(reminderCount + 1, forKey: constants.alarmScreenHelpers.numberOfAlarmsSet)
        popUpVC = getPopUpWith(title: "HEARING YOUR ALARM", message: "Be sure to follow the instructions above to make sure that you hear your alarm when it goes off!", image: UIImage(named: "alarmInstructions"))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            if self.popUpVC != nil {
                self.present(self.popUpVC!, animated: true, completion: nil)
            }
        }
        
    }
    
    @objc func goToSleepLongPress() {
        if !alarmSet {return}
        //Cancel upcoming alarm
        self.trashButtonAudio.play()
        alarmImage.image = UIImage.init(systemName: "alarm")!
        self.clearNotifications()
        configButtonWithNoAlarm()
        alarmSet = false
        shakeAlarmImage()
        FirebaseManager.shared.setAsleepProperty(asleepBool: false) { (error) in}
    }
    
    func shakeAlarmImage() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: alarmImage.center.x - 8, y: alarmImage.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: alarmImage.center.x + 8, y: alarmImage.center.y))

        alarmImage.layer.add(animation, forKey: "position")
    }
    
    var alarmFireDate: Date!
    
    
    var alarmCountdownTimer: Timer!
    var loadingAlarmIndicator: NVActivityIndicatorView!
    var timePicker: UIDatePicker!
    var timeFromNowLabelTimer: Timer!
    var timeFromNowLabel: UILabel!
    var cancelButton: UIButton!
    var saveButton: UIButton!
    var alarmSet: Bool = false
    var buttonAnimating = false
    var appIsReturningFromBackground = false
    var popUpShadeView: UIView!
    
    @IBOutlet weak var alarmCountdownLabel: UILabel!
        
    @IBAction func goToSleepPressed(_ sender: Any) {
        if alarmSet {
            if buttonAnimating {return}
            let attrString = createStringWithEmoji(text: "Hold to deactivate ", fontSize: 17, emojiName: "awake_face", textColor: .white, font: "Avenir-heavy")
            self.goToSleepButton.titleLabel?.attributedText = attrString
            self.goToSleepButton.setAttributedTitle(attrString, for: .normal)
            buttonAnimating = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.buttonAnimating = false
                if !self.alarmSet {
                    return
                }
                let alarmText = DateFormatter.localizedString(from: self.alarmFireDate, dateStyle: .none, timeStyle: .short)
                let attrTitle = createStringWithEmoji(text: alarmText + "  ", fontSize: 25, emojiName: "asleep_face", textColor: .white, font: "Avenir-heavy")
                self.goToSleepButton.titleLabel?.attributedText = attrTitle
                self.goToSleepButton.setAttributedTitle(attrTitle, for: .normal)
                self.goToSleepButton.layoutIfNeeded()
            }
            return
        } else {
            self.presentSetTimeVC()
        }
    }
    
    func presentSetTimeVC() {
        //add the shadow view to the centerVC so that it covers the buttons too
        popUpShadeView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        popUpShadeView.backgroundColor = .black
        popUpShadeView.alpha = 0.0
        self.centerVC.view.addSubview(popUpShadeView)
        UIView.animate(withDuration: 0.25, animations: {
            self.popUpShadeView.alpha = 0.5
        })
        //segue
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "setTimeVC") as! setTimeVC
        nextVC.homeVC = self
        nextVC.modalPresentationStyle = .overFullScreen
        self.present(nextVC, animated: true)
    }
    
    
    
    func calculateTimeUntilAlarm() -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: timePicker.date)
        let selectedTimeComponents = DateComponents(year: components.year, month: components.month, day: components.day, hour: components.hour, minute: components.minute, second: 0)
        let selectedTime = Calendar.current.date(from: selectedTimeComponents)!
        let alarmFire = convertSelectedTimeToDate(time: selectedTime)
        let interval = alarmFire.timeIntervalSince(Date())
        return (interval.stringTime + " from now")
    }
    
    
    
    func beginAlarmCountdown() {
        if alarmCountdownTimer != nil {
            alarmCountdownTimer.invalidate()
        }
        self.alarmCountdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(self.alarmCountdownTick) , userInfo: nil, repeats: true)
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
}

extension ViewController: EasyTipViewDelegate {
    
    func addHelpers() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if (!UserDefaults.standard.bool(forKey: constants.helperVCKeys.hasHelpedHomeScreen)) {
                self.currHelper = constants.homeScreenHelpers.recordHelper
                let dummyView = UIView(frame: self.centerVC.centerButton.frame)
                dummyView.isHidden = true
                self.view.addSubview(dummyView)
                self.insertHelper(text: "Tap the record button to start creating a wakey message!", pointAt: dummyView, superView: self.view)
            }
        }
    }
    
    func insertHelper(text: String, pointAt: UIView, superView: UIView ) {
        EasyTipView.show(animated: true, forView: pointAt, withinSuperview: superView, text: text, delegate: self)
    }
    
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        switch currHelper {
        case constants.homeScreenHelpers.recordHelper:
            currHelper = constants.homeScreenHelpers.profileHelper
            
            let dummyView = UIView(frame: self.centerVC.rightButton.frame)
            dummyView.isHidden = true
            self.view.addSubview(dummyView)
            insertHelper(text: "View your message history by swiping right", pointAt: dummyView, superView: self.view)
            return
        case constants.homeScreenHelpers.profileHelper:
            currHelper = constants.homeScreenHelpers.alarmHelper
            insertHelper(text: "Tap here to set an alarm just before going to bed", pointAt: self.goToSleepButton, superView: self.view)
            return
        case constants.homeScreenHelpers.alarmHelper:
            currHelper = constants.homeScreenHelpers.friendHelper
            let dummyView = UIView(frame: self.centerVC.leftButton.frame)
            dummyView.isHidden = true
            self.view.addSubview(dummyView)
            insertHelper(text: "View and add friends by swiping left", pointAt: dummyView, superView: self.view)
            return
        default:
            UserDefaults.standard.set(true, forKey: constants.helperVCKeys.hasHelpedHomeScreen)
            return
        }
    }
}


extension ViewController: centerButtonDelegate {
    func centerButtonPressed() {
        recordTapped()
    }
    
    func userDidLogOut() {
        //making sure you don't receive an alarm once you're logged out
        invalidateTimers()
        if alarmCountdownTimer != nil {alarmCountdownTimer.invalidate()}
    }
}
