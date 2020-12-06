//
//  profileHeaderCellCollectionViewCell.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/03.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit

protocol profileHeaderCellCollectionViewCellDelegate: class {
}

class profileHeaderCellCollectionViewCell: UICollectionViewCell {
    
    
    weak var delegate: profileHeaderCellCollectionViewCellDelegate?
    
    @IBOutlet weak var profilePic: RoundedProfilePic!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var fullNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        usernameLabel.adjustsFontSizeToFitWidth = true
        fullNameLabel.adjustsFontSizeToFitWidth = true
        // Initialization code
    }
    
    
    
    
    

}
