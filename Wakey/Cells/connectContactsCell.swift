//
//  connectContactsCell.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/06/27.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit

protocol connectContactsCellDelegate: class {
    func connectPressed()
}

class connectContactsCell: UICollectionViewCell {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var connectButton: UIButton!
    
     weak var delegate: connectContactsCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        configureShadow()
        connectButton.layer.cornerRadius = 4
    }

    private func configureShadow() {
        shadowView.backgroundColor = UIColor.clear
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 1, height: 3)
        shadowView.layer.shadowOpacity = 0.2
        shadowView.layer.shadowRadius = 2.0
        
    }
    
    
    @IBAction func connectPressed(_ sender: Any) {
        delegate?.connectPressed()
    }
    

}
