//
//  setTimeVC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/12/05.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit

class setTimeVC: UIViewController {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var popUpView: UIView!
    
    @IBOutlet weak var topLabel: UILabel!
    
    @IBOutlet weak var timeInfoLabel: UILabel!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var confirmTimeButton: UIButton!
    @IBOutlet weak var cancelButtonShadowView: UIView!
    @IBOutlet weak var cancelButtonView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    var homeVC: ViewController!
    
    
    var timeFromNowLabelTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.timeFromNowLabelTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(self.updateTimeUntilLabel) , userInfo: nil, repeats: true)
        timePicker.addTarget(self, action: #selector(timePickerChanged(picker:)), for: .valueChanged)
        timeInfoLabel.text = calculateTimeUntilAlarm()
        if #available(iOS 13.4, *) {
            timePicker.preferredDatePickerStyle = .wheels
        } else {
        }
        
        timePicker.datePickerMode = .time
        configPopUpUI()
        
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
    
    @objc func timePickerChanged(picker: UIDatePicker) {
        timeInfoLabel.text = calculateTimeUntilAlarm()
    }
    
    @objc func updateTimeUntilLabel() {
        let newTime = calculateTimeUntilAlarm()
        if (timeInfoLabel.text != newTime) {
            self.timeInfoLabel.text = newTime
        }
    }
    
    
    func calculateTimeUntilAlarm() -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: timePicker.date)
        let selectedTimeComponents = DateComponents(year: components.year, month: components.month, day: components.day, hour: components.hour, minute: components.minute, second: 0)
        let selectedTime = Calendar.current.date(from: selectedTimeComponents)!
        let alarmFire = convertSelectedTimeToDate(time: selectedTime)
        let interval = alarmFire.timeIntervalSince(Date())
        return (interval.stringTime + " from now")
    }
    
    
    @IBAction func confirmTimeButtonPressed(_ sender: Any) {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: timePicker.date)
        let selectedTimeComponents = DateComponents(year: components.year, month: components.month, day: components.day, hour: components.hour, minute: components.minute, second: 0)
        let selectedTime = Calendar.current.date(from: selectedTimeComponents)!
        //let alarmText = DateFormatter.localizedString(from: selectedTime, dateStyle: .none, timeStyle: .short)
        //goToSleepButton.setTitle(alarmText, for: .normal)
        let alarmFireDate = convertSelectedTimeToDate(time: selectedTime)
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "curateAlarmVC") as! curateAlarmVC
        nextVC.alarmFireDate = alarmFireDate
        nextVC.homeVC = self.homeVC
        nextVC.modalPresentationStyle = .overFullScreen
        print("TRYING HARD")
        self.dismiss(animated: false) {
            self.homeVC.present(nextVC, animated: true)
        }
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.homeVC.popUpShadeView.removeFromSuperview()
        self.dismiss(animated: true)
    }
}
