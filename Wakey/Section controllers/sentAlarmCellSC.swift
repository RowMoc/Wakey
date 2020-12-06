//
//  sentAlarmCellSC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/03.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit
import IGListKit
import SDWebImage

class sentAlarmCellSC: ListSectionController {
    var sentAlarm: sentAlarm!
    
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 100)
    }
    
    
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(withNibName: String(describing: sentAlarmCell.self), bundle: Bundle.main, for: self, at: index)
        if let cell = cell as? sentAlarmCell {
            cell.usernameLabel.text = sentAlarm.user.username
            cell.profilePic.sd_setImage(with: URL(string: sentAlarm.user.profilePicUrl))
            if sentAlarm.hasBeenHeard {
                cell.messageStatusImage.image = UIImage(systemName: "waveform.circle")!
            } else {
                cell.messageStatusImage.image = UIImage(systemName: "waveform.circle.fill")!
            }
            
            let attributes = [NSAttributedString.Key.foregroundColor: cell.timeSentLabel.textColor, NSAttributedString.Key.font: UIFont(name: "Avenir-light", size: 20)]
            
            
            
            if sentAlarm.reaction != nil && sentAlarm.reaction! != "" {
                let attrString = createStringWithEmoji(text: "", fontSize: 26, emojiName: sentAlarm.reaction!, textColor: cell.timeSentLabel.textColor, font: "Avenir-light")
                let finalString = NSMutableAttributedString()
                finalString.append(attrString)
                let attributes2 = [NSAttributedString.Key.foregroundColor: cell.timeSentLabel.textColor, NSAttributedString.Key.font: UIFont(name: "Avenir-light", size: 15)]
                let space = NSMutableAttributedString(string: " ", attributes: attributes as [NSAttributedString.Key : Any])
                let bullet = NSMutableAttributedString(string: " • ", attributes: attributes2 as [NSAttributedString.Key : Any])
                let timeString = NSMutableAttributedString(string:" " + sentAlarm.timeSent.getElapsedInterval(), attributes: attributes as [NSAttributedString.Key : Any])
                finalString.append(space)
                finalString.append(bullet)
                finalString.append(timeString)
                
                
                
                cell.timeSentLabel.attributedText = finalString
            } else {
                let timeString = NSMutableAttributedString(string: sentAlarm.timeSent.getElapsedInterval(), attributes: attributes as [NSAttributedString.Key : Any])
                cell.timeSentLabel.attributedText = timeString
            }
        }
        return cell
    }
    
    public override func didUpdate(to object: Any) {
        self.sentAlarm = object as? sentAlarm
    }
    
    public override func didSelectItem(at index: Int) {
        
    }
    
}



extension Date {
    
    func getElapsedInterval() -> String {
        let interval = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self, to: Date())
        
        if let days = interval.day, days/7 > 0 {
            let weeks = days/7
            return "\(weeks)" + "w"
        } else if let day = interval.day, day > 0 {
            return "\(day)" + "d"
        } else if let hour = interval.hour, hour > 0 {
           return "\(hour)"  + "h"
            
        } else if let min = interval.minute, min > 0 {
           return "\(min)" + "m"
            
        } else if let secs = interval.second {
           return "\(secs)" + "s"
        }
        return ""
    }
}
