//
//  loadingViewCell.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/11.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class loadingViewCell: UICollectionViewCell {
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicator.startAnimating()
    }

}
