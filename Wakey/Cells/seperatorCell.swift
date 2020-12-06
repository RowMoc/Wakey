//
//  seperatorCell.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/02.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit

class seperatorCell: UICollectionViewCell {

    @IBOutlet weak var seperatorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        seperatorLabel.lineBreakMode = .byWordWrapping // notice the 'b' instead of 'B'
        seperatorLabel.numberOfLines = 0
    }

}
