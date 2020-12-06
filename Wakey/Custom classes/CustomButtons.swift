//
//  roundOutlineButton.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/02.
//  Copyright © 2020 Wakey. All rights reserved.
//

import Foundation
import UIKit


class RoundedButtonWithShadow: UIButton {
    
    let widthToScreenRatio = 0.4 as CGFloat
    
    override func awakeFromNib() {
        self.layer.masksToBounds = false
        self.layer.cornerRadius = (UIScreen.main.bounds.width * widthToScreenRatio)/2
        let shadowColor = UIColor.black
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * widthToScreenRatio, height: UIScreen.main.bounds.width * widthToScreenRatio), cornerRadius: self.layer.cornerRadius).cgPath
        self.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 4.0
    }
    
    
}


class SendButton: UIButton {
    var imageViewElem: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.layer.masksToBounds = false
        
    }
    
    override func layoutSubviews() {
        if let imageViewElem = imageViewElem {
            imageViewElem.removeFromSuperview()
        }
        //self.backgroundColor = .clear
        self.layer.cornerRadius = self.frame.height/2
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor(named: "AppGreenColor")?.cgColor
        let height = CGFloat(self.bounds.width * 0.4)
        let inset = (CGFloat(self.bounds.width) - height)/2.0
        let frame = CGRect(x: inset, y: inset,width:height, height: height)
        imageViewElem = UIImageView(frame: frame)
        imageViewElem!.image = UIImage(systemName: "paperplane")!.withTintColor(UIColor(named: "AppGreenColor")!)
        self.addSubview(imageViewElem!)
        //add shadow
        let shadowColor = UIColor.black
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.width), cornerRadius: self.layer.cornerRadius).cgPath
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowOpacity = 0.4
        self.layer.shadowRadius = 2
    }
}

class uploadProPicButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.layer.masksToBounds = false
        self.layer.cornerRadius = self.frame.height/2
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.white.cgColor
        
        let height = CGFloat(self.bounds.width * 0.4)
        let inset = (CGFloat(self.bounds.width) - height)/2.0
        let frame = CGRect(x: inset, y: inset + 4, width:height, height: height - 8)
        let image = UIImageView(frame: frame)
        image.image = UIImage(systemName: "photo")!.withTintColor(.white)
        self.addSubview(image)
    }
}



class exitSleepModeButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.init(named: "AppRedColor")?.cgColor
    }
}

class setAlarmButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 5
    }
}


class SendToRecipientsButton: UIButton {
    
    var innerImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.masksToBounds = false
        self.layer.cornerRadius = self.frame.height/2
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        self.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 1.0
        self.backgroundColor = UIColor.init(named: "AppGreenColor")
        
        
        let height = CGFloat(self.bounds.width * 0.4)
        let inset = (CGFloat(self.bounds.width) - height)/2.0
        let frame = CGRect(x: inset, y: inset,width:height, height: height)
        let innerImageView = UIImageView(frame: frame)
        innerImageView.image = UIImage(systemName: "paperplane")!.withTintColor(.white)
        self.addSubview(innerImageView)
    }
    
}


class lockScreenButton: UIButton {
    
    var innerImageView: UIImageView!
    
    let widthToScreenRatio = 0.4 as CGFloat
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let width = (UIScreen.main.bounds.width * widthToScreenRatio)
        self.layer.masksToBounds = false
        self.layer.cornerRadius = width/2
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: width, height: width), cornerRadius: self.layer.cornerRadius).cgPath
        self.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 1.0
        
        
        let height = width * 0.4
        let inset = (width - height)/2.0
        let frame = CGRect(x: inset, y: inset,width:height, height: height)
        let innerImageView = UIImageView(frame: frame)
        innerImageView.image = UIImage(systemName: "moon.zzz")!.withTintColor(.white)
        self.addSubview(innerImageView)
    }
    
    override func layoutSubviews() {
        
    }
    
}


class RoundedProfilePicButton: UIButton {
    
    override func layoutSubviews() {
        
    }
    
    func addImage(image: UIImage) {
        self.layer.borderWidth = 2.0
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor(named: "AppRedColor")!.cgColor
        self.layer.cornerRadius = self.bounds.height/2
        self.clipsToBounds = true
        self.setImage(image, for: .normal)
    }
    
}


class TrashButton: UIButton {
    
    var imageViewElem: UIImageView?
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.layer.masksToBounds = false
    }
    
    override func layoutSubviews() {
        if let imageViewElem = imageViewElem {
            imageViewElem.removeFromSuperview()
        }
        //self.backgroundColor = .clear
        self.layer.cornerRadius = self.frame.height/2
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor(named: "AppRedColor")?.cgColor
        let height = CGFloat(self.bounds.width * 0.4)
        let inset = (CGFloat(self.bounds.width) - height)/2.0
        let frame = CGRect(x: inset, y: inset,width:height, height: height)
        let image = UIImageView(frame: frame)
        image.image = UIImage(systemName: "trash")!.withTintColor(UIColor(named: "AppRedColor")!)
        self.addSubview(image)
        
        //add shadow
        let shadowColor = UIColor.black
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.width), cornerRadius: self.layer.cornerRadius).cgPath
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowOpacity = 0.4
        self.layer.shadowRadius = 2
    }
}
