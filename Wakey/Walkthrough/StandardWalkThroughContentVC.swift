//
//  StandardWalkThroughVC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/06/12.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit

class StandardWalkThroughContentVC: UIViewController {

    @IBOutlet var headingLabel: UILabel! {
        didSet {
            headingLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet var subHeadingLabel: UILabel! {
        didSet {
            subHeadingLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet var contentImageView: UIImageView!
    
    // MARK: - Properties
    
    var index = 0
    var heading = ""
    var subHeading = ""
    var imageFile = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        headingLabel.text = heading
        subHeadingLabel.text = subHeading
        subHeadingLabel.numberOfLines = 0
        let inset = UIScreen.main.bounds.width/8
        contentImageView.image = UIImage(named: imageFile)!.withAlignmentRectInsets(UIEdgeInsets(top: -inset, left: -inset, bottom: -inset, right: -inset))
    }

}
