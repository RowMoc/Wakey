//
//  curateAlarmSC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/12/03.
//  Copyright © 2020 Wakey. All rights reserved.
//

import IGListKit
import Foundation


class curateAlarmSC: ListSectionController {
    
    
    
    override func sizeForItem(at index: Int) -> CGSize {
        var cellHeight = 70.0 as CGFloat
//        if alarm != nil, alarm.curateListCategory == constants.curateAlarmListHeadings.likedMessage {
//            cellHeight = 80.0 as CGFloat
//        }
        guard let width = self.collectionContext?.containerSize.width else {
            return CGSize(width: UIScreen.main.bounds.width, height: cellHeight)
        }
        return CGSize(width: width , height: cellHeight)
    }
    
    var alarm: curateListAlarm!
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(withNibName: String(describing: curateAlarmCell.self), bundle: Bundle.main, for: self, at: index)
        if let cell = cell as? curateAlarmCell {
            cell.alarm = alarm
            cell.sectionController = self
            
            cell.topLabel.text = alarm!.associatedProfile.username
            //Elapsed time since received and length
            var middleLabelText = ""
            
            if alarm.curateListCategory == constants.curateAlarmListHeadings.defaultAlarm {
                middleLabelText = String(Int(alarm.audioLength)) + " seconds"
                cell.profilePic.image = UIImage(named: "wakeyProfilePic")
            } else {
                middleLabelText = alarm.timeReceived.getElapsedInterval() + " ago  •  " + String(Int(alarm.audioLength)) + " seconds"
                cell.profilePic.sd_setImage(with: URL(string: alarm.associatedProfile.profilePicUrl))
            }
            
            
            switch alarm.curateListCategory {
            case constants.curateAlarmListHeadings.unopenedMessage:
                middleLabelText += "  •  Unopened"
            case constants.curateAlarmListHeadings.likedMessage:
                middleLabelText += "  •  Liked"
            case constants.curateAlarmListHeadings.defaultAlarm:
                middleLabelText += "  •  Default"
            default:
                middleLabelText += ""
            }
            cell.middleLabel.text = middleLabelText
            
            if alarm.msgDescription == "" {
                cell.bottomLabel.isHidden = true
            } else {
                cell.bottomLabel.isHidden = false
                cell.bottomLabel.text = alarm.msgDescription
            }
            if alarm.isQueued {
                cell.selectedIconButton.setImage(UIImage.init(systemName: "checkmark.circle.fill"), for: .normal)
            } else {
                cell.selectedIconButton.setImage(UIImage.init(systemName: "circle"), for: .normal)
            }
        }
        return cell
    }
    
    
    public override func didUpdate(to object: Any) {
        //self.alarm = (object as! curateListAlarm)
    }
    
    public override func didSelectItem(at index: Int) {
        //
    }
    
    func cellSelected(cell: curateAlarmCell) {
        guard let vc =  self.viewController as? curateAlarmVC  else {
            return
        }
        let updatedAlarmObject = vc.reorder(thisAlarm: alarm)
        self.alarm = updatedAlarmObject
        cell.alarm = alarm
    }
   
    
}


