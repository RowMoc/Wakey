//
//  SelectRecipientsVC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/02.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit
import IGListKit
import NVActivityIndicatorView
import AVFoundation
import Alamofire
import Firebase

class SelectRecipientsVC: UIViewController, AVAudioPlayerDelegate {
    
    @IBOutlet weak var collectionView: ListCollectionView!
    var selectedRecipients: [userModel] = []
   
    @IBOutlet weak var recipientsBottomView: UIView!
    @IBOutlet weak var sendButton: SendToRecipientsButton!
    @IBOutlet weak var recipientsListButton: UIButton!
    
    var audioURL: URL!
    //privacy toggle of the message
    
    var recipientsCanFavorite = true
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    }()
    
    var allArray = [Any]()
    var awakeArray = [Any]()
    var asleepArray = [Any]()
    var filteredAllArray = [Any]()
    var fetchingData = false
    var homeViewController: ViewController!
    
    //seperator tokens
    let friendsLabelCell = "Select friends"
    let loadingViewCell = "loadingViewCell"
    let theRest = "Everyone"
    let youHaveNoFriendsCell = "You don't yet have any friends on Wakey to send this to. Add friends from the people tab!"
    var searchBar = "searchBar"
    var togglePrivacyCell = "togglePrivacyCell"
    var asleepSeperator = "Asleep"
    var asleepSeperatorDescription = "These folks have already set their alarms for the night, so - if you send them this message - they'll only receive it the next time they set their Wakey alarms after waking up."
    var awakeSeperator = "Awake"
    var awakeSeperatorDescription = "These folks are awake, so - if you send them this message - they'll receive it whenever their next alarm goes off!"

    override func viewDidLoad() {
        super.viewDidLoad()
        //setupUI()
        sendButton.isHidden = true
        recipientsBottomView.isHidden = true
        adapter.collectionView = collectionView
        adapter.dataSource = self
        let layout = UICollectionViewFlowLayout()
        self.collectionView.collectionViewLayout = layout
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.showsVerticalScrollIndicator = false
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        self.collectionView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.recipientsListButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        //navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        prepareButtonAudio()
        fetchData()
    }
     
    
    func fetchData() {
        fetchingData = true
        allArray = []
        self.adapter.performUpdates(animated: true)
        //fetch all friends
        FirebaseManager.shared.fetchAllFriends { (error, friendsArray) in
            if error != nil {
                return
            }
            DispatchQueue.main.async {
                for user in friendsArray {
                    let recipient = recipientModel(user: user, isSelected: false)
                    if user.isAsleep {
                        self.asleepArray.append(recipient)
                    } else {
                        self.awakeArray.append(recipient)
                    }
                    self.allArray.append(recipient)
                }
                self.fetchingData = false
                self.adapter.performUpdates(animated: true)
            }
        }
    }
    
    var sendButtonImage: UIImageView?
    
    func setupUI() {
        if (sendButtonImage != nil) {
            sendButtonImage?.removeFromSuperview()
        }
        let imageHeight = CGFloat(sendButton.bounds.width * 0.4)
        //print("image height")
        //print(imageHeight)
        let inset = (sendButton.bounds.width - imageHeight)/2.0
        let imageFrame = CGRect(x: inset, y: inset,width: imageHeight,height: imageHeight)
        sendButtonImage = UIImageView(frame: imageFrame)
        sendButtonImage!.image = UIImage(systemName:"paperplane")!.withTintColor(UIColor.black)
        sendButtonImage!.isUserInteractionEnabled = false
        sendButton.addSubview(sendButtonImage!)
        sendButton.isHidden = true
    }
    
    
    
    func addRecipient(user: userModel) {
        regularClickAudio.play()
        if !selectedRecipients.contains(user) {
            selectedRecipients.append(user)
        }
        sendButton.isHidden = false
        recipientsBottomView.isHidden = false
        setRecipientButtonString()
    }
    
    func removeRecipient(user: userModel) {
        regularClickAudio.play()
        if selectedRecipients.contains(user) {
            selectedRecipients.removeAll(where:  { user == $0 })
        }
        if selectedRecipients.isEmpty {
            sendButton.isHidden = true
            recipientsBottomView.isHidden = true
        } else {
            setRecipientButtonString()
        }
    }
    
    func setRecipientButtonString() {
        if selectedRecipients.isEmpty {
            self.recipientsListButton.setTitle("", for: .normal)
            self.recipientsListButton.layoutIfNeeded()
            return
        }
        var listString = ""
        if selectedRecipients.count < 3 {
            for (index, recip) in selectedRecipients.enumerated() {
                if index == (selectedRecipients.count - 1) {
                    listString += recip.username
                } else {
                    listString += recip.username + ", "
                }
            }
        //there are at least 2 recipients
        } else if !selectedRecipients.isEmpty {
            for (index, recip) in selectedRecipients.enumerated() {
                listString += recip.username + ", "
                if index == 1 {
                    if selectedRecipients.count == 3 {
                         listString += " and " + String((selectedRecipients.count - 2)) + " other"
                    } else {
                        listString += " and " + String((selectedRecipients.count - 2)) + " others"
                    }
                    break
                }
            }
        }
        self.recipientsListButton.setTitle(listString, for: .normal)
        self.recipientsListButton.layoutIfNeeded()
        return
    }
    
    func mapUserToReceiver(receivers: [userModel]) -> [[String: Any]] {
        var maps: [[String: Any]] = []
        for receiver in receivers {
            maps.append(["receiver_device_id": receiver.deviceID, "receiver_full_name": receiver.fullName, "receiver_profile_img_url": receiver.profilePicUrl, "receiver_username": receiver.username, "receiver_id": receiver.userID])
        }
        return maps
    }
    
    
    @IBAction func sendPressed(_ sender: Any) {
        sendButtonAudio.play()
        
        //determine length of audio of alarm
        let asset = AVURLAsset(url: self.audioURL, options: nil)
        let audioDuration = asset.duration.seconds
        DispatchQueue.main.async {
            FirebaseManager.shared.sendWakeyMessage(audioFileUrl: self.audioURL, audioLength: audioDuration, recipientsCanFavorite: self.recipientsCanFavorite, recipients: self.mapUserToReceiver(receivers: self.selectedRecipients)) { (error) in
                if let error = error {
                    //didn't work
                    print(error)
                } else {
                    print("MESSAGES WERE SENT SHEEESH")
                }
            }
        }
        //ANALYTICS
        DispatchQueue.main.async {
            FirebaseManager.shared.getCurrentUser { (error, user) in
                if let user = user {
                    Analytics.logEvent("sent_message", parameters: ["num_receivers": self.selectedRecipients.count, "username": user.username])
                }
            }
        }
        //animate the sending of the message
        UIButton.animate(withDuration: 0.07, animations: {
                            self.sendButton.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
        },
                         completion: { finish in
                            self.expandLoadView()
        })
        
        
    }
    
    
    var sendClickAudio = AVAudioPlayer()
    var sendButtonAudio = AVAudioPlayer()
    var regularClickAudio = AVAudioPlayer()
    
    func prepareButtonAudio() {
        do {
            sendClickAudio.delegate = self
            sendClickAudio = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "messageSent", ofType: "m4a")!))
            sendClickAudio.prepareToPlay()
        } catch {
            //print(error)
        }
        do {
            sendButtonAudio.delegate = self
            sendButtonAudio = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "buttonStartClick", ofType: "m4a")!))
            sendButtonAudio.prepareToPlay()
        } catch {
            //print(error)
        }
        do {
            regularClickAudio.delegate = self
            regularClickAudio = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "addRecipient", ofType: "m4a")!))
            regularClickAudio.enableRate = true
            regularClickAudio.volume = 0.1
            regularClickAudio.rate = 1.5
            regularClickAudio.prepareToPlay()
        } catch {
            //print(error)
        }
    }
    
    
    
    var loadingView: UIView!
    var loadingViewImage: UIImageView!
    var sizeFactor: CGFloat!
    
    func expandLoadView() {
        //create view
        loadingView = UIView(frame: sendButton.frame)
        loadingView.layer.cornerRadius = loadingView.bounds.height/2.0
        loadingView.backgroundColor = UIColor(named: "AppRedColor")
        self.view.addSubview(loadingView)
        
        
        //create image view
        let height = CGFloat(self.sendButton.bounds.width * 0.4)
        let inset = (CGFloat(self.sendButton.bounds.width) - height)/2.0
        let frame = CGRect(x: self.sendButton.frame.minX + inset, y: self.sendButton.frame.minY + inset, width:height, height: height)
        loadingViewImage = UIImageView(frame: frame)
        loadingViewImage.image = UIImage(systemName: "paperplane")!.withTintColor(.white)
        loadingViewImage.tintColor = .white
        self.view.addSubview(loadingViewImage)
        
        //hide the send button
        self.sendButton.isHidden = true
        
        sizeFactor = distance(loadingView.center,(view.superview?.convert(view.frame.origin, to: nil))!)/(loadingView.bounds.height/2)
        
        let newImageWidth = 103.5 as CGFloat
        UIView.animate(withDuration: 0.12, animations: {
            self.loadingView.transform = CGAffineTransform(scaleX: self.sizeFactor, y: self.sizeFactor)
            self.loadingViewImage.frame =  CGRect(x: UIScreen.main.bounds.width/2 - newImageWidth/2, y: UIScreen.main.bounds.height/2 - newImageWidth/2, width:newImageWidth, height: newImageWidth)
        }) { (complete) in
            self.loadingView.layer.cornerRadius = 0
            self.loadingView.frame = self.view.frame
            self.uploadVN()
        }
    }
    
    func uploadVN() {
        let frame = CGRect(x: loadingViewImage.frame.minX - 25, y: loadingViewImage.frame.maxY - 30, width: 30, height: 60)
        let activityIndicator = NVActivityIndicatorView(frame: frame, type: .audioEqualizer, color: .white, padding: 5)
        let degrees = 230 as Double
        activityIndicator.transform = CGAffineTransform(scaleX: 1, y: 3)
        activityIndicator.transform = CGAffineTransform(rotationAngle: CGFloat(degrees * Double.pi/180));
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        wobblePlane()
        
        //label
        let label = UILabel(frame: CGRect(x: 20, y: activityIndicator.frame.maxY + 20, width: UIScreen.main.bounds.width - 40, height: 25))
        let text = "Sending your wakey message..."
        let myAttributes = [ NSAttributedString.Key.font: UIFont(name: "Avenir-heavy", size: 14.0)!, NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        let myAttrString = NSAttributedString(string: text, attributes: myAttributes)
        label.attributedText = myAttrString
        label.textAlignment = .center
        self.view.addSubview(label)
        //upload
        let seconds = 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            // Put your code which should be executed with a delay here
            self.sendClickAudio.play()
            label.attributedText = NSAttributedString(string: "Sent!", attributes: myAttributes)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.homeViewController.loadRecordingUI()
                self.dismiss(animated: true)
            }
        }
        
    }
    
    func wobblePlane() {
        let originalFrame = self.loadingViewImage.frame
        //print(originalFrame)
        //print(originalFrame.width)
        UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse] , animations: {
            self.loadingViewImage.frame = CGRect(x: originalFrame.minX + 2, y: originalFrame.minY - 4, width: originalFrame.width, height: originalFrame.height);
            }) { (completed) in
            }
    }
    
    
    
    func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
    }
    
    
    @IBAction func userPressedExit(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    var isSearching = false

}

extension SelectRecipientsVC: ListAdapterDataSource{
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        var screenItems: [ListDiffable] = []
        if isSearching {
            screenItems = [self.friendsLabelCell, self.searchBar, self.togglePrivacyCell] as [ListDiffable]
            screenItems += filteredAllArray as! [ListDiffable]
        } else {
            if (allArray.count == 0) {
                if fetchingData {
                    screenItems = [self.friendsLabelCell, self.loadingViewCell] as [ListDiffable]
                } else {
                    screenItems = [self.friendsLabelCell, youHaveNoFriendsCell] as [ListDiffable]
                }
            } else {
                screenItems = [self.friendsLabelCell, self.searchBar, self.togglePrivacyCell] as [ListDiffable]
                if !awakeArray.isEmpty {
                    screenItems += [self.awakeSeperator,self.awakeSeperatorDescription] as [ListDiffable]
                    screenItems += self.awakeArray as! [ListDiffable]
                }
                if !asleepArray.isEmpty {
                    screenItems += [self.asleepSeperator,self.asleepSeperatorDescription] as [ListDiffable]
                    screenItems += self.asleepArray as! [ListDiffable]
                }
            
            }
        }
        return screenItems
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if object is recipientModel {
            let sc = recipientCellSC()
            sc.user = (object as! recipientModel)
            return sc
        }
        if (object is String && object as! String == friendsLabelCell) {
            let sc = seperatorCellSC()
            sc.fontSize = 30
            sc.labelText = (object as! String)
            return sc
        }
        if (object is String && object as! String == loadingViewCell) {
            let sc = loadingViewCellSC()
            return sc
        }
        
        if (object is String && object as! String == togglePrivacyCell) {
            let sc = toggleMessagePrivacySC()
            sc.canFavorite = recipientsCanFavorite
            return sc
        }
        
        
        if (object is String && object as! String == searchBar) {
            let sc = searchBarSC()
            sc.placeholderText = "Send to..."
            sc.delegate = self
            return sc
        }
        if (object is String && (object as! String == awakeSeperator || object as! String == asleepSeperator)) {
            let sc = seperatorCellSC()
            sc.labelText = (object as! String)
            sc.fontSize = 20
            return sc
        }
        if (object is String && (object as! String == youHaveNoFriendsCell)) {
            let sc = seperatorCellSC()
            sc.labelText = (object as! String)
            sc.fontSize = 15
            return sc
        }
        
        if (object is String && (object as! String == awakeSeperatorDescription || object as! String == asleepSeperatorDescription)) {
            let sc = seperatorCellSC()
            sc.labelText = (object as! String)
            sc.fontSize = 10
            sc.lightText = true
            return sc
        }
        return ListSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        
        return loadingCollectionView(backgroundColor: UIColor.init(named: "collectionViewBackground")!, indicatorColor: UIColor.init(named: "AppRedColor")!)
    }

}


extension SelectRecipientsVC: searchSCDelegate {
    
    func searchSectionController(_ sectionController: searchBarSC, didChangeText text: String) {
        //print("Searching")
        isSearching = true
        if (text == "") {
            isSearching = false
            self.adapter.performUpdates(animated: true)
            return
        }
        if (!allArray.isEmpty) {
            var filteredUsers: [Any] = []
            for recipientModel in allArray {
                if let recipientModel = recipientModel as? recipientModel {
                    if (recipientModel.user.username.lowercased().contains(text.lowercased())) {
                        filteredUsers.append(recipientModel)
                    }
                }
            }
            self.filteredAllArray = filteredUsers
            self.adapter.performUpdates(animated: true)
        }
    }
    
    
}




