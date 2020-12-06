//
//  customImageView.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/02.
//  Copyright © 2020 Wakey. All rights reserved.
//
import Foundation
import UIKit

class RoundedProfilePic: UIImageView {
    
    override func layoutSubviews() {
        self.layer.borderWidth = 2
        self.layer.masksToBounds = false
        //self.layer.borderColor = UIColor(named: "AppRedColor")!.cgColor
        self.layer.cornerRadius = self.bounds.height/2
        self.clipsToBounds = true
    }
    
    override func  awakeFromNib() {
         super.awakeFromNib()
         self.layer.borderColor = UIColor(named: "AppRedColor")!.cgColor
    }
    
}


class RoundedProfilePicThinBorder: UIImageView {
    
    override func layoutSubviews() {
        self.layer.borderWidth = 0.5
        self.layer.masksToBounds = false
        //self.layer.borderColor = UIColor(named: "AppRedColor")!.cgColor
        self.layer.cornerRadius = self.bounds.height/2
        self.clipsToBounds = true
    }
    
    override func  awakeFromNib() {
         super.awakeFromNib()
         self.layer.borderColor = UIColor(named: "AppRedColor")!.cgColor
    }
    
}

class RoundedProfilePicHomeScreen: UIImageView {
    
    override func layoutSubviews() {
        self.layer.borderWidth = 2.0
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor(named: "AppRedColor")!.cgColor
        self.layer.cornerRadius = self.bounds.height/2
        self.clipsToBounds = true
    }
    
}

