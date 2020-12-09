//
//  toggleMessagePrivacySC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/12/07.
//  Copyright © 2020 Wakey. All rights reserved.
//

import IGListKit
import Foundation


class toggleMessagePrivacySC: ListSectionController {
    
    var canFavorite: Bool!
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let width = self.collectionContext?.containerSize.width else {
            return CGSize(width: UIScreen.main.bounds.width, height: 60)
        }
        return CGSize(width: width , height: 60)
    }
    
    var alarm: curateListAlarm!
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(withNibName: String(describing: toggleMessagePrivacyCell.self), bundle: Bundle.main, for: self, at: index)
        if let cell = cell as? toggleMessagePrivacyCell {
            cell.sectionController = self
            cell.privacySwitch.isOn = canFavorite
            if canFavorite {
                cell.label.text = "Recipients will be able to favorite this wakey"
            } else {
                cell.label.text = "Recipients will only hear this wakey once"
            }
        }
        return cell
    }
    
    
    public override func didUpdate(to object: Any) {
    }
    
    public override func didSelectItem(at index: Int) {
        //
    }
    
    func pivacyToggled(cell: toggleMessagePrivacyCell) {
        guard let vc =  self.viewController as? SelectRecipientsVC  else {
            return
        }
        self.canFavorite = cell.privacySwitch.isOn
        vc.recipientsCanFavorite = self.canFavorite
        if cell.privacySwitch.isOn {
            cell.label.text = "Recipients will be able to favorite this wakey"
        } else {
            cell.label.text = "Recipients will only hear this wakey once"
        }
    }
   
    
}

