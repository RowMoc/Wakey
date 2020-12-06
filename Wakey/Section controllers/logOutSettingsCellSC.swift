//
//  logOutSettingsCellSC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/07/05.
//  Copyright © 2020 Wakey. All rights reserved.
//

import IGListKit
import Foundation
import FBSDKCoreKit
import FBSDKLoginKit


class logOutSettingsCellSC: ListSectionController, settingsDefaultCellDelegate {
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 70)
    }
    
    var dailyReminderIsSet: Bool?
    var dailyReminderTime: Date?
    
    
    enum permsCases {
        case isSetWithoutDate
        case isNotSet
        case isSetWithDate
        case busyDetermining
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(withNibName: String(describing: settingsDefaultCell.self), bundle: Bundle.main, for: self, at: index)
        if let cell = cell as? settingsDefaultCell {
            cell.iconImageView.image = UIImage(systemName: "escape")!
            cell.titleLabel.text = "Log out"
            cell.permissionsSwitch.isHidden = true
        }
        return cell
    }
    
    
    
    
    //Delegate methods
    func switchToggled(turnedOn: Bool, cell: settingsDefaultCell) {
        return
    }
    
    func actionButtonPressed(cell: settingsDefaultCell) {
        //Present a time picker to allow the user to select the time they want their notifcation to be set
        return
    }
    
    
    public override func didUpdate(to object: Any) {
    }
    
    public override func didSelectItem(at index: Int) {
        guard let thisCell = self.cellForItem(at: index) as? settingsDefaultCell else  {
            return
        }
        guard let thisVC = self.viewController as? editProfileVC else {
            return
        }
        thisVC.view.isUserInteractionEnabled = false
        thisCell.activityIndicator.isHidden = false
        thisCell.activityIndicator.startAnimating()
        FirebaseManager.shared.logOut { (error) in
            thisVC.view.isUserInteractionEnabled = true
            if let error = error {
                
                thisCell.activityIndicator.isHidden = false
                thisCell.activityIndicator.startAnimating()
            } else {
                LoginManager().logOut()
                var vc = thisVC.presentingViewController
                if let centerVC = vc as? CenterVC {
                    centerVC.delegate?.userDidLogOut()
                }
                while vc?.presentingViewController != nil {
                    vc = vc?.presentingViewController
                    if let centerVC = vc as? CenterVC {
                        centerVC.delegate?.userDidLogOut()
                    }
                }
                vc?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}
