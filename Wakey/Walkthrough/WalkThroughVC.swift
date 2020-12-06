//
//  WalkThroughVC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/06/12.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit

class WalkThroughVC: UIViewController, WalkThroughPageViewControllerDelegate, UNUserNotificationCenterDelegate,reminderWalkThroughDelegate {
    
    
    
    func timeWasSelected(timeSelected: Double) {
        self.timeSelected = timeSelected
    }
    
    
    // MARK: - Outlets
    var timeSelected: Double = 7.5
    
    
    
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet var nextButton: UIButton! {
        didSet {
            nextButton.layer.cornerRadius = 4
            nextButton.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var skipButton: UIButton!
    
    //MARK: - Properties
    
    var walkThroughPageViewController: WalkThroughPageViewController?
    
    //MARK: - Actions
    
    @IBAction func skipButtonTapped(sender: UIButton) {
        //UserDefaults.standard.set(true, forKey: "hasViewedWalkthrough")
        self.segueHome()
    }
    
    @IBAction func nextButtonTapped(sender: UIButton) {
        if let index = walkThroughPageViewController?.currentIndex {
            switch index {
            case 0...2:
                walkThroughPageViewController?.forwardPage()
                updateUI()
            case 3:
                walkThroughPageViewController?.forwardPage()
                updateUI()
            case 4:
                print("case 4 next tapped")
                //ASK FOR NOTIFICATIONS PERMISSION HERE
                //Check if we can send notifcations to the user
                let center = UNUserNotificationCenter.current()
                center.delegate = self
                let options: UNAuthorizationOptions
                if #available(iOS 12.0, *) {
                    options = [.alert, .badge, .sound, .criticalAlert]
                } else {
                    options = [.alert, .badge, .sound]
                }
                center.requestAuthorization(options: [options]) { (granted, error) in 
                    // Enable or disable features based on authorization.
                    if error != nil {
                        print("error")
                    } else {
                        if granted {
                            //QUEUE A DAILY REMINDER FOR TIMESELECTED TO SET ALARM HERE
                            
                            let notificationRequest = self.getDailyReminderRequest()
                            print("TRIGGER DATE:", notificationRequest.trigger)
                            center.add(notificationRequest) { (error) in
                                if let error = error {
                                    let errorString = String(format: NSLocalizedString("Unable to Add Notification Request %@, %@", comment: ""), error as CVarArg, error.localizedDescription)
                                    print(errorString)
                                }
                                
                                DispatchQueue.main.async {
                                    UserDefaults.standard.set(true, forKey: constants.hasViewedWalkThrough)
                                    self.segueHome()
                                    
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                UserDefaults.standard.set(true, forKey: constants.hasViewedWalkThrough)
                                self.segueHome()
                            }
                            
                        }
                    }
                }
            default: break
            }
        }
    }
    
    
    func segueHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "CenterVC") as! CenterVC
        nextVC.modalPresentationStyle = .fullScreen
        self.present(nextVC, animated: true)
//        let navCon = UINavigationController(rootViewController: nextVC)
//        navCon.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
//        navCon.setNavigationBarHidden(true, animated: false)
//        self.present(navCon, animated: true)
    }
    
    func getDailyReminderRequest() -> UNNotificationRequest {
        var date = DateComponents()
        
        date.hour = Int(timeSelected) + 12
        if timeSelected.truncatingRemainder(dividingBy: 1) == 0 {
            date.minute = 0
        } else {
            date.minute = 30
        }
        date.second = 0
        print("HERE'S THE DATE FOR THE TRIGGER:", date)
        //let triggerInputForHourlyRepeat = Calendar.current.dateComponents([.minute], from: intendedFireDateVariable)
        let trig = UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: date.hour, minute: date.minute), repeats: true)
        //test
        //let trig = UNCalendarNotificationTrigger(dateMatching: DateComponents(second: 40), repeats: true)
        //let triggerDaily = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
        //let trigger = UNCalendarNotificationTrigger(dateMatching: , repeats: true)
        let content = UNMutableNotificationContent()
        content.title = "Alarm reminder 🤪"
        content.body = "Set your alarm before bed to hear your Wakeys in the morning!"
        content.sound = .default

        let notification = UNNotificationRequest(identifier: constants.dailyNotificationIdentifier, content: content, trigger: trig)
        return notification
        
    }
    
    func updateUI() {
        if let index = walkThroughPageViewController?.currentIndex {
            switch index {
            case 0...2:
                nextButton.setTitle("Next", for: .normal)
                skipButton.isHidden = true
            case 3:
                nextButton.setTitle("Next", for: .normal)
                skipButton.isHidden = true
            case 4:
                nextButton.setTitle("Allow notifications", for: .normal)
                skipButton.isHidden = false
                
            default:
                break
            }
            
            pageControl.currentPage = index
        }
    }
    
    func didUpdatePageIndex(currentIndex: Int) {
        updateUI()
    }
    
    // MARK: - View controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        //probs want to change this to be dynamic
        self.skipButton.isHidden = true
        self.pageControl.numberOfPages = 5
        
        //insert cool background
        let bgImageView = UIImageView(frame: self.view.frame)
        bgImageView.image = UIImage(named: "onboardingBackground")!
        bgImageView.contentMode = .scaleAspectFill
        self.view.insertSubview(bgImageView, at: 0)
        // Do any additional setup after loading the view.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let pageViewController = destination as? WalkThroughPageViewController {
            walkThroughPageViewController = pageViewController
            walkThroughPageViewController?.walkthroughDelegate = self
        }
    }
 

}

