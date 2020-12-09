//
//  recipientCellSC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/02.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit
import IGListKit
import SDWebImage

class recipientCellSC: ListSectionController {
    var user: recipientModel!
    var thisCell: recipientCell!
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 100)
    }
    
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(withNibName: String(describing: recipientCell.self), bundle: Bundle.main, for: self, at: index)
        if let cell = cell as? recipientCell {
            cell.nameLabel.text = self.user.user.username
            
            cell.profilePic.sd_setImage(with: URL(string: self.user.user.profilePicUrl))
            let fontToUse = cell.sleepingStatusLabel.font
            if self.user.user.isAsleep {
                cell.sleepingStatusLabel.attributedText = createStringWithEmoji(text: "", fontSize: fontToUse?.pointSize ?? 40, emojiName: "asleep_face", textColor: .black, font: "Avenir-heavy")
            } else {
                cell.sleepingStatusLabel.attributedText = createStringWithEmoji(text: "", fontSize: fontToUse?.pointSize ?? 40, emojiName: "awake_face", textColor: .black, font: "Avenir-heavy")
            }
            
            if self.user.isSelected {
                cell.cellBackgroundView.backgroundColor = UIColor(named: "AppRedColor")!.withAlphaComponent(0.75)
                cell.profilePic.layer.borderColor = UIColor.white.cgColor
            } else {
                cell.cellBackgroundView.backgroundColor = UIColor.systemBackground
                cell.profilePic.layer.borderColor = UIColor(named: "AppRedColor")!.cgColor
            }
            self.thisCell = cell
        }
        return cell
    }
    
    public override func didUpdate(to object: Any) {
        self.user = object as? recipientModel
    }
    
    public override func didSelectItem(at index: Int) {
        guard let vc = self.viewController as? SelectRecipientsVC else {
            return
        }
        vc.view.endEditing(true)
        print("hit's here")
        if self.user.isSelected {
            (self.viewController as! SelectRecipientsVC).removeRecipient(user: self.user.user)
            thisCell.cellBackgroundView.backgroundColor = UIColor.systemBackground
            thisCell.profilePic.layer.borderColor = UIColor(named: "AppRedColor")!.cgColor
            self.user.isSelected = false
        } else {
            //print("tried changing color")
            (self.viewController as! SelectRecipientsVC).addRecipient(user: self.user.user)
            thisCell.cellBackgroundView.backgroundColor = UIColor(named: "AppRedColor")!.withAlphaComponent(0.75)
            thisCell.profilePic.layer.borderColor = UIColor.white.cgColor
            self.user.isSelected = true
        }
        
    }
    
}



func createStringWithEmoji(text: String, fontSize: CGFloat, emojiName: String, textColor: UIColor, font: String) -> NSMutableAttributedString {
    let attributes = [NSAttributedString.Key.foregroundColor: textColor, NSAttributedString.Key.font: UIFont(name: font, size: fontSize)]
    
    let titleTextString = NSMutableAttributedString(string: text, attributes: attributes as [NSAttributedString.Key : Any])

    let imageAttachment =  NSTextAttachment()
    imageAttachment.image = UIImage(named:emojiName)
    let yPos = (UIFont(name: font, size: fontSize)!.capHeight - fontSize).rounded() / 2
    imageAttachment.bounds = CGRect(x: 0, y: yPos, width: fontSize, height: fontSize)
    let imageAttachmentString = NSMutableAttributedString(attachment: imageAttachment)
    titleTextString.append(imageAttachmentString)
    return titleTextString
}



