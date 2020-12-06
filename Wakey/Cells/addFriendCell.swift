//
//  addFriendCell.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/20.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

protocol addFriendCellDelegate: class {
    func rightButtonPressed(cell: addFriendCell)
    func leftButtonPressed(cell: addFriendCell)
}

class addFriendCell: UICollectionViewCell {

    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var profilePic: RoundedProfilePic!
    
    @IBOutlet weak var messageActivityIndicator: NVActivityIndicatorView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var rightButton: UIButton!
    
    @IBOutlet weak var leftButton: UIButton!
    
    var sectionController: addFriendCellSC!
    
    weak var delegate: addFriendCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.adjustsFontSizeToFitWidth = true
        
        leftButton.layer.cornerRadius = 4
        leftButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        rightButton.layer.cornerRadius = 4
        rightButton.titleLabel?.adjustsFontSizeToFitWidth = true
        // Initialization code
    }
    
    override func layoutSubviews() {
        configureShadow()
        cellBackgroundView.layer.cornerRadius = 8.0
        cellBackgroundView.layer.masksToBounds = true
        cellBackgroundView.backgroundColor = UIColor.systemBackground
    }

    private func configureShadow() {
        shadowView.backgroundColor = UIColor.clear
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 1, height: 3)
        shadowView.layer.shadowOpacity = 0.2
        shadowView.layer.shadowRadius = 2.0
        
    }
    
    
    @IBAction func rightButtonPressed(_ sender: Any) {
        delegate?.rightButtonPressed(cell: self)
    }
    
    @IBAction func leftButtonPressed(_ sender: Any) {
        delegate?.leftButtonPressed(cell: self)
    }
    
    
    
}
