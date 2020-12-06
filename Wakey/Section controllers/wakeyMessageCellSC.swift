//
//  wakeyMessageCellSC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/06/15.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit
import IGListKit
import SDWebImage

class wakeyMessageCellSC: ListSectionController {
    var message: wakeyMessage!
    var currUserID: String!
    
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 100)
    }
    
    
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(withNibName: String(describing: wakeyMessageCell.self), bundle: Bundle.main, for: self, at: index)
        if let cell = cell as? wakeyMessageCell {
            let topLineAttrbs = [NSAttributedString.Key.foregroundColor: cell.topLabel.textColor, NSAttributedString.Key.font: UIFont(name: "Avenir-medium", size: 14)]
            let attributes = [NSAttributedString.Key.foregroundColor: cell.topLabel.textColor, NSAttributedString.Key.font: UIFont(name: "Avenir-light", size: 14)]
            
            
            cell.profilePic.sd_setImage(with: URL(string: message.sender.profilePicUrl))
            var otherUserRef = ""
            
            if message.sender.userID == currUserID {
                otherUserRef = message.receiver.username
                if let firstPart = message.receiver.username.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true).first {
                    otherUserRef = String(firstPart)
                }
                
            } else {
                otherUserRef = message.sender.username
                if let firstPart = message.sender.username.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true).first {
                    otherUserRef = String(firstPart)
                }
            }
            
            
            
            
            if message.sender.userID == currUserID {
                cell.topLabel.attributedText = NSMutableAttributedString(string: "You sent a Wakey  •  " + message.timeSent.getElapsedInterval(), attributes:topLineAttrbs as [NSAttributedString.Key : Any])
                if message.reaction != nil {
                    let bottomString = NSMutableAttributedString(string:  otherUserRef + " reacted  ", attributes:attributes as [NSAttributedString.Key : Any])
                    bottomString.append(createStringWithEmoji(text: "", fontSize: 18, emojiName: message.reaction!, textColor: cell.bottomLabel.textColor, font: "Avenir-light"))
                    if message.timeHeard != nil {
                        bottomString.append(NSMutableAttributedString(string: "  •  " + message.timeHeard!.getElapsedInterval(), attributes:attributes as [NSAttributedString.Key : Any]))
                    }
                    cell.bottomLabel.attributedText = bottomString
                    cell.messageStatusImage.image = UIImage(systemName: "paperplane")!
                } else {
                    if message.timeHeard != nil {
                        cell.bottomLabel.attributedText = NSMutableAttributedString(string: "Opened  •  " + message.timeHeard!.getElapsedInterval(), attributes:attributes as [NSAttributedString.Key : Any])
                        cell.messageStatusImage.image = UIImage(systemName: "paperplane")!
                    } else {
                        cell.bottomLabel.attributedText = NSMutableAttributedString(string: "Delivered", attributes:attributes as [NSAttributedString.Key : Any])
                        cell.messageStatusImage.image = UIImage(systemName: "paperplane.fill")!
                    }
                }
                
            } else {
                cell.topLabel.attributedText = NSMutableAttributedString(string: otherUserRef + " sent a Wakey  •  " + message.timeSent.getElapsedInterval(), attributes:topLineAttrbs as [NSAttributedString.Key : Any])
                
                if message.reaction != nil {
                    let bottomString = NSMutableAttributedString(string: "You reacted  ", attributes:attributes as [NSAttributedString.Key : Any])
                    bottomString.append(createStringWithEmoji(text: "", fontSize: 18, emojiName: message.reaction!, textColor: cell.bottomLabel.textColor, font: "Avenir-light"))
                    if message.timeHeard != nil {
                        bottomString.append(NSMutableAttributedString(string: "  •  " + message.timeHeard!.getElapsedInterval(), attributes:attributes as [NSAttributedString.Key : Any]))
                    }
                    cell.bottomLabel.attributedText = bottomString
                    cell.messageStatusImage.image = UIImage(systemName: "waveform.circle")!
                } else {
                    if message.timeHeard != nil {
                        cell.bottomLabel.attributedText = NSMutableAttributedString(string: "Opened  •  " + message.timeHeard!.getElapsedInterval(), attributes:attributes as [NSAttributedString.Key : Any])
                        cell.messageStatusImage.image = UIImage(systemName: "waveform.circle")!
                    } else {
                        cell.bottomLabel.attributedText = NSMutableAttributedString(string: "Received", attributes:attributes as [NSAttributedString.Key : Any])
                        cell.messageStatusImage.image = UIImage(systemName: "waveform.circle.fill")!
                    }
                }
            }
        }
        return cell
    }
    
    public override func didUpdate(to object: Any) {
        self.message = object as? wakeyMessage
    }
    
    public override func didSelectItem(at index: Int) {
        //go to the chat view
    }
    
}
