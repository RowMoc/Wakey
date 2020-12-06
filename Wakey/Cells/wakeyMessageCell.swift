//
//  wakeyMessageCell.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/06/15.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit

class wakeyMessageCell: UICollectionViewCell {

    @IBOutlet weak var profilePic: RoundedProfilePic!
    @IBOutlet weak var topLabel: UILabel!
    
    @IBOutlet weak var bottomLabel: UILabel!
    
    @IBOutlet weak var messageStatusImage: UIImageView!
    
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        bgView.layer.cornerRadius = 8.0
        bgView.layer.masksToBounds = true
        bgView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.4)
        bgView.isOpaque = false
    }


}
