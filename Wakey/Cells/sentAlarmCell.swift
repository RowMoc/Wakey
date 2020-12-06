//
//  sentAlarmCell.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/03.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit

class sentAlarmCell: UICollectionViewCell {

    @IBOutlet weak var shadowView: UIView!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var profilePic: RoundedProfilePic!
    
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var timeSentLabel: UILabel!
    
    @IBOutlet weak var messageStatusImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    override func layoutSubviews() {
        configureShadow()
        containerView.layer.cornerRadius = 8.0
        containerView.layer.masksToBounds = true
        containerView.backgroundColor = UIColor.systemBackground
    }

    private func configureShadow() {
        shadowView.backgroundColor = UIColor.clear
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 1, height: 3)
        shadowView.layer.shadowOpacity = 0.2
        shadowView.layer.shadowRadius = 2.0
        
    }

}
