//
//  soundBiteFeedCell.swift
//  Wakey
//
//  Created by Rowan Mockler on 2021/01/03.
//  Copyright © 2021 Wakey. All rights reserved.
//

import UIKit
import LinearProgressBar
import NVActivityIndicatorView

class soundBiteFeedCell: UICollectionViewCell {

    @IBOutlet weak var accountTopLabel: UILabel!
    
    @IBOutlet weak var accountProPic: RoundedProfilePic!
    @IBOutlet weak var accountBottomLabel: UILabel!
    
    
    @IBOutlet weak var soundBiteImage: UIImageView!

    @IBOutlet weak var cellBackgroundView: UIView!
    
    @IBOutlet weak var shadowView: UIView!
    
    
    @IBOutlet weak var soundBiteTopLabel: UIButton!
    @IBOutlet weak var soundBiteMiddleLabel: UIButton!
    
   
    @IBOutlet weak var soundBiteBottomLabel: UILabel!
    
    @IBOutlet weak var soundBitePlayButton: UIButton!
    
   
    @IBOutlet weak var soundBiteSendButton: UIButton!
    
    @IBOutlet weak var numSentLabel: UILabel!
    
    @IBOutlet weak var explicitSymbol: UILabel!
    var sc: soundBiteFeedCellSC!
    
    
    var activityIndicator: NVActivityIndicatorView?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func layoutSubviews() {
        configureShadow()
        cellBackgroundView.layer.cornerRadius = 8.0
        cellBackgroundView.layer.masksToBounds = true
        cellBackgroundView.backgroundColor = UIColor.systemBackground
        soundBiteImage.layer.cornerRadius = 5.0
        soundBiteImage.layer.masksToBounds = true
        soundBiteImage.contentMode = .scaleAspectFill
        explicitSymbol.layer.cornerRadius = 4
        explicitSymbol.layer.masksToBounds = true
        
    }

    private func configureShadow() {
        shadowView.backgroundColor = UIColor.clear
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 1, height: 3)
        shadowView.layer.shadowOpacity = 0.2
        shadowView.layer.shadowRadius = 2.0
        
    }

    
    @IBAction func playSoundBitePressed(_ sender: Any) {
        sc.playButtonPressed(cell: self)
    }
    
    @IBAction func sendSoundBitePressed(_ sender: Any) {
        sc.sendSoundBitePressed(cell: self)
    }
    
    
}
