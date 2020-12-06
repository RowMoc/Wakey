//
//  settingActionButtonCell.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/07/06.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

protocol settingActionButtonCellDelegate: class {
    func actionButtonPressed(cell: settingActionButtonCell)
}

class settingActionButtonCell: UICollectionViewCell {
    
    
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    weak var delegate: settingActionButtonCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.adjustsFontSizeToFitWidth = true
        
        // Initialization code
    }
    
    override func layoutSubviews() {
        configureShadow()
        containerView.layer.cornerRadius = 8.0
        containerView.layer.masksToBounds = true
    }
    
    private func configureShadow() {
        shadowView.backgroundColor = UIColor.clear
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 1, height: 3)
        shadowView.layer.shadowOpacity = 0.2
        shadowView.layer.shadowRadius = 2.0
        
    }
    
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        delegate?.actionButtonPressed(cell: self)
    }
    
}
