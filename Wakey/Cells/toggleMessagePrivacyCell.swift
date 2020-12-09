//
//  toggleMessagePrivacyCell.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/12/07.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit

class toggleMessagePrivacyCell: UICollectionViewCell {

    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var privacySwitch: UISwitch!
    
    
    var sectionController: toggleMessagePrivacySC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func privacySwitchToggled(_ sender: Any) {
        sectionController.pivacyToggled(cell: self)
    }
    
    

}
