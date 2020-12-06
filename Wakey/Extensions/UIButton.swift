//
//  UIButton.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/21.
//  Copyright © 2020 Wakey. All rights reserved.
//


import UIKit

extension UIButton {
    static func make(_ side: Panel) -> UIButton {
        let button = UIButton()
        button.backgroundColor = .clear
        var buttonHeight: CGFloat!
        switch side {
        case .left:
            button.contentVerticalAlignment = .fill
            button.contentHorizontalAlignment = .fill
            button.backgroundColor = .clear
            button.setImage(UIImage.init(systemName: "person.circle")!, for: .normal)
            //button.imageView?.contentMode = .scaleAspectFill
            buttonHeight = Layout.sideButtonHeight
        case .right:
            button.contentVerticalAlignment = .fill
            button.contentHorizontalAlignment = .fill
            button.setImage(UIImage.init(systemName: "message.circle")!, for: .normal)
            buttonHeight = Layout.sideButtonHeight
        case .center:
            button.layer.masksToBounds = false
            button.layer.shadowColor = UIColor.black.cgColor
            button.backgroundColor = UIColor(named: "AppRedColor")!
            button.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
            button.layer.shadowOpacity = 0.5
            button.layer.shadowRadius = 1.0
            buttonHeight = UIScreen.main.bounds.width*0.4
            button.layer.cornerRadius = buttonHeight/2
            //buttonHeight = Layout.centralButtonHeight
            
            button.layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: buttonHeight, height: buttonHeight), cornerRadius: buttonHeight/2).cgPath
            
            
            let imageHeight = CGFloat(buttonHeight * 0.5)
            let inset = (buttonHeight - imageHeight)/2.0
            let recordImageFrame = CGRect(x: inset, y: inset,width:imageHeight, height: imageHeight)
//            let recordButtonImage = UIImageView(frame: recordImageFrame)
//            recordButtonImage.contentMode = .scaleAspectFit
//            recordButtonImage.image = UIImage(named: "recordSymbol")!
//            recordButtonImage.isUserInteractionEnabled = false
//            button.addSubview(recordButtonImage)
        default: break
        }
        return button
    }
}
