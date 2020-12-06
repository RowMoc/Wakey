//
//  selectedCurateAlarmCell.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/12/03.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit



class curateAlarmCell: UICollectionViewCell {
    
    var alarm: curateListAlarm!
    
   
    @IBOutlet weak var profilePic: RoundedProfilePic!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var middleLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var selectedIconButton: UIButton!
    
    var sectionController: curateAlarmSC!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func selectIconButtonPressed(_ sender: Any) {
        if alarm.isQueued {
            selectedIconButton.setImage(UIImage.init(systemName: "circle"), for: .normal)
        } else {
            selectedIconButton.setImage(UIImage.init(systemName: "checkmark.circle.fill"), for: .normal)
        }
        sectionController.cellSelected(cell: self)
    }
    
    
    

}
