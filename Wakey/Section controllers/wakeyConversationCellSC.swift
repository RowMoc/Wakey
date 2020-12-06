//
//  wakeyConversationCellSC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/06/15.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit
import IGListKit
import SDWebImage

class wakeyConversationCellSC: ListSectionController {
    var convo: wakeyConversation!
    var currUserID: String!
    
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 100)
    }
    
    
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(withNibName: String(describing: wakeyConversationCell.self), bundle: Bundle.main, for: self, at: index)
        if let cell = cell as? wakeyConversationCell {
            cell.usernameLabel.text = convo.other_user.username
            cell.profilePic.sd_setImage(with: URL(string: convo.other_user.profilePicUrl))
            
            
            guard let latestMessage = convo.messages.last else {
                return cell
            }
            
            var infoString = NSMutableAttributedString()
            let attributes = [NSAttributedString.Key.foregroundColor: cell.infoLabel.textColor, NSAttributedString.Key.font: UIFont(name: "Avenir-light", size: 14)]
            let bullet = NSMutableAttributedString(string: " • ", attributes: [NSAttributedString.Key.foregroundColor: cell.infoLabel.textColor as Any, NSAttributedString.Key.font: UIFont(name: "Avenir-light", size: 12) as Any] as [NSAttributedString.Key : Any])
            let space = NSMutableAttributedString(string: " ", attributes: attributes as [NSAttributedString.Key : Any])
            var timeString = NSMutableAttributedString(string: latestMessage.timeSent.getElapsedInterval(), attributes: attributes as [NSAttributedString.Key : Any])
            var reactionString = NSMutableAttributedString(string:"" , attributes: attributes as [NSAttributedString.Key : Any])
            if let reaction = latestMessage.reaction {
                reactionString = createStringWithEmoji(text: "", fontSize: 18, emojiName: reaction, textColor: cell.infoLabel.textColor, font: "Avenir-light")
            }
            var descriptionText = NSMutableAttributedString()
            
            
            if currUserID == latestMessage.sender.userID {
                //curr user sent the last message
                if let timeHeard = latestMessage.timeHeard {
                    timeString = NSMutableAttributedString(string: timeHeard.getElapsedInterval(), attributes: attributes as [NSAttributedString.Key : Any])
                    if latestMessage.reaction != nil {
                        descriptionText = NSMutableAttributedString(string: "Reacted ", attributes: attributes as [NSAttributedString.Key : Any])
                    } else {
                        descriptionText = NSMutableAttributedString(string: "Opened", attributes: attributes as [NSAttributedString.Key : Any])
                    }
                    cell.messageStatusImage.image = UIImage(systemName: "paperplane")!
                } else {
                    descriptionText = NSMutableAttributedString(string: "Delivered", attributes: attributes as [NSAttributedString.Key : Any])
                    cell.messageStatusImage.image = UIImage(systemName: "paperplane.fill")!
                }
                
            } else {
                //curr user received the last message
                if let timeHeard = latestMessage.timeHeard {
                    timeString = NSMutableAttributedString(string: timeHeard.getElapsedInterval(), attributes: attributes as [NSAttributedString.Key : Any])
                    if latestMessage.reaction != nil {
                        descriptionText = NSMutableAttributedString(string: "You reacted ", attributes: attributes as [NSAttributedString.Key : Any])
                    } else {
                        descriptionText = NSMutableAttributedString(string: "Opened", attributes:
                            attributes as [NSAttributedString.Key : Any])
                    }
                    cell.messageStatusImage.image = UIImage(systemName: "waveform.circle")!
                } else {
                    descriptionText = NSMutableAttributedString(string: "Received", attributes: attributes as [NSAttributedString.Key : Any])
                    cell.messageStatusImage.image = UIImage(systemName: "waveform.circle.fill")!
                }
            }
            infoString.append(descriptionText)
            infoString.append(space)
            infoString.append(reactionString)
            infoString.append(space)
            infoString.append(bullet)
            infoString.append(space)
            infoString.append(timeString)
            cell.infoLabel.attributedText = infoString
        }
        return cell
    }
    
    public override func didUpdate(to object: Any) {
        self.convo = object as? wakeyConversation
    }
    
    public override func didSelectItem(at index: Int) {
        //go to the chat view
        print("Press wkaey convo")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "wakeyConversationVC") as! wakeyConversationVC
        nextVC.currUserID = currUserID
        nextVC.convo = self.convo
        nextVC.modalPresentationStyle = .fullScreen
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.moveIn
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        if let window = UIApplication.shared.delegate?.window as? UIWindow {
            window.backgroundColor = .clear
        }
        (self.viewController as! personalProfileVC).view.window!.layer.add(transition, forKey: kCATransition)
        (self.viewController as! personalProfileVC).present(nextVC, animated: false, completion: nil)
    }
    
}

