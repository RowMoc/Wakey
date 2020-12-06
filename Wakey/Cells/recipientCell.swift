//
//  recipientCell.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/02.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit

class recipientCell: UICollectionViewCell {

    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var profilePic: RoundedProfilePic!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var sleepingStatusLabel: UILabel!
    
    @IBOutlet weak var reactionLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureShadow()
        cellBackgroundView.layer.cornerRadius = 8.0
        cellBackgroundView.layer.masksToBounds = true
    }

    private func configureShadow() {
        shadowView.backgroundColor = UIColor.clear
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 1, height: 3)
        shadowView.layer.shadowOpacity = 0.2
        shadowView.layer.shadowRadius = 2.0
    }
    
    
}
