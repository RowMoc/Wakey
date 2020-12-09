//
//  likedAlarmDescriptionView.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/12/09.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit

class likedAlarmDescriptionView: UIView {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var popUpShadowview: UIView!
    @IBOutlet weak var popUpView: UIView!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    func initSubviews() {
        // standard initialization logic
        Bundle.main.loadNibNamed("likedAlarmDescriptionView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
    }

    
}
