//
//  goToSleepCell.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/10.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit


protocol goToSleepCellDelegate: class {
    func setAlarm(timeSet: Date, cell: goToSleepCell)
    func exitSleepMode()
    func lockScreenPressed()
}
class goToSleepCell: UICollectionViewCell {
    
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var currentDateLabel: UILabel!
    
    @IBOutlet weak var lockScreenButton: lockScreenButton!
    
    @IBOutlet weak var exitSleepModeButton: exitSleepModeButton!
    @IBOutlet weak var alarmImage: UIImageView!
    
    @IBOutlet weak var setAlarmButton: UIButton!
    
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    weak var delegate: goToSleepCellDelegate?
    
    var timer = Timer()
    override func awakeFromNib() {
        super.awakeFromNib()
        timePicker.setValue(UIColor.white, forKeyPath: "textColor")
        timePicker.datePickerMode = .time
        timePicker.isHidden = true
        cancelButton.isHidden = true
        saveButton.isHidden = true
        lockScreenButton.isHidden = true
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(self.tick) , userInfo: nil, repeats: true)
    }
    
    @IBAction func lockScreenPressed(_ sender: Any) {
        performPressAnimation()
        delegate?.lockScreenPressed()
        
    }
    
    @objc func tick() {
        currentDateLabel.text = DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .none)
    }
    
    @IBAction func setAlarmPressed(_ sender: Any) {
        alarmImage.isHidden = true
        setAlarmButton.isHidden = true
        //timePicker.frame = CGRect(x: 0, y: UIScreen.main.bounds.height*0.8, width: UIScreen.main.bounds.width , height: UIScreen.main.bounds.height*0.2)
        timePicker.isHidden = false
        //cancelButton.frame = CGRect(x: 20, y: timePicker.frame.minY - 25, width: 50, height: 20)
        cancelButton.isHidden = false
        //saveButton.frame = CGRect(x: UIScreen.main.bounds.width - 70, y: timePicker.frame.minY - 25, width: 50, height: 20)
        saveButton.isHidden = false
    }
    
    @IBAction func timeOnPickerChanged(_ sender: Any) {
    }
    
    
    @IBAction func cancelPressed(_ sender: Any) {
        cancelButton.isHidden = true
        saveButton.isHidden = true
        timePicker.isHidden = true
        alarmImage.isHidden = false
        setAlarmButton.isHidden = false
    }
    
    @IBAction func savePressed(_ sender: Any) {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: timePicker.date)
        let selectedTimeComponents = DateComponents(year: components.year, month: components.month, day: components.day, hour: components.hour, minute: components.minute, second: 0)
        let selectedTime = Calendar.current.date(from: selectedTimeComponents)! 
        let alarmText = DateFormatter.localizedString(from: selectedTime, dateStyle: .none, timeStyle: .short)
        setAlarmButton.setTitle(alarmText, for: .normal)
        delegate?.setAlarm(timeSet: selectedTime, cell: self)
        cancelButton.isHidden = true
        saveButton.isHidden = true
        timePicker.isHidden = true
        alarmImage.isHidden = false
        setAlarmButton.isHidden = false
        
    }
    
    
    
    @IBAction func exitSleepModePressed(_ sender: Any) {
        //print("button is hit")
        delegate?.exitSleepMode()
    }
    
    func performPressAnimation() {
        UIButton.animate(withDuration: 0.05,
                         animations: {
                            self.lockScreenButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        },
                         completion: { finish in
                            UIButton.animate(withDuration: 0.05, animations: {
                                self.lockScreenButton.transform = CGAffineTransform.identity
                            })
        })
    }
    
}
