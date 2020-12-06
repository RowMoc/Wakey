//
//  ReminderWalkThroughContentVC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/06/12.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit

protocol reminderWalkThroughDelegate: class {
    func timeWasSelected(timeSelected: Double)
}
class ReminderWalkThroughContentVC: UIViewController {
    
    weak var delegate: reminderWalkThroughDelegate?

    @IBOutlet var headingLabel: UILabel! {
        didSet {
            headingLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet var subHeadingLabel: UILabel! {
        didSet {
            subHeadingLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet var beforeEightButton: UIButton!
    @IBOutlet var eightThirtyButton: UIButton!
    @IBOutlet var nineButton: UIButton!
    @IBOutlet var nineThirtyButton: UIButton!
    @IBOutlet var tenButton: UIButton!
    @IBOutlet var tenThirtyButton: UIButton!
    @IBOutlet var elevenButton: UIButton!
    @IBOutlet var elevenThirtyButton: UIButton!
    @IBOutlet var twelveButton: UIButton!
    @IBOutlet var afterTwelveButton: UIButton!
    
    
    // MARK: - Properties
    
    var index = 0
    var heading = ""
    var subHeading = ""
    var selectedTime: Double =  7.5
    var aTimeIsSelected = false
    var timeButtons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeButtons = [beforeEightButton, eightThirtyButton, nineButton, nineThirtyButton, tenButton, tenThirtyButton, elevenButton, elevenThirtyButton, twelveButton, afterTwelveButton]
        headingLabel.text = heading
        subHeadingLabel.text = subHeading
        subHeadingLabel.numberOfLines = 0
        defaultConfigButtons()
        beforeEightButton.backgroundColor = UIColor(named: "AppRedColor")!
        beforeEightButton.setTitleColor(.white, for: .normal)
    }
    
    func defaultConfigButtons() {
        for button in timeButtons {
            button.backgroundColor = .systemBackground
            button.layer.cornerRadius = 5
            button.layer.borderWidth = 2
            button.layer.borderColor = UIColor(named: "AppRedColor")!.cgColor
            button.setTitleColor(UIColor(named: "AppRedColor")!, for: .normal)
        }
        
    }
    
    
    @IBAction func timeSelected(_ sender: UIButton) {
        aTimeIsSelected = true
        defaultConfigButtons()
        //edit the button that was selected
        sender.backgroundColor = UIColor(named: "AppRedColor")!
        sender.setTitleColor(.white, for: .normal)
        switch sender {
        case beforeEightButton:
            headingLabel.text = "Bed time: Before 8pm"
            selectedTime = 7.5
        case eightThirtyButton:
            headingLabel.text = "Bed time: 8:30ish"
            selectedTime = 8.5
        case nineButton:
            headingLabel.text = "Bed time: 9ish"
            selectedTime = 9.0
        case nineThirtyButton:
            headingLabel.text = "Bed time: 9:30ish"
            selectedTime = 9.5
        case tenButton:
            headingLabel.text = "Bed time: 10ish"
            selectedTime = 10.0
        case tenThirtyButton:
            headingLabel.text = "Bed time: 10:30ish"
            selectedTime = 10.5
        case elevenButton:
            headingLabel.text = "Bed time: 11ish"
            selectedTime = 11.0
        case elevenThirtyButton:
            headingLabel.text = "Bed time: 11:30ish"
            selectedTime = 11.5
        case twelveButton:
            headingLabel.text = "Bed time: 12ish"
            selectedTime = 12.0
        case afterTwelveButton:
            headingLabel.text = "Bed time: After midnight"
            selectedTime = 12.5
        default:
            break
        }
        delegate?.timeWasSelected(timeSelected: selectedTime)
    }
    
    

}
