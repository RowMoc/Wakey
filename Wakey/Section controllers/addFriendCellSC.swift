//
//  addFriendCellSC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/20.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit
import IGListKit
import SDWebImage

class addFriendCellSC: ListSectionController, addFriendCellDelegate{
    
    
    var user: userModel!
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 100)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(withNibName: String(describing: addFriendCell.self), bundle: Bundle.main, for: self, at: index)
        if let cell = cell as? addFriendCell {
            cell.nameLabel.text = user.username
            cell.nameLabel.adjustsFontSizeToFitWidth = true
            cell.profilePic.sd_setImage(with: URL(string: user.profilePicUrl))
            cell.sectionController = self
            cell.delegate = self
            self.configureButtons(cell: cell)
        }
        return cell
    }
    
    func configureButtons(cell: addFriendCell) {
        cell.messageActivityIndicator.stopAnimating()
        if let friendStatus = user.friendshipStatus {
            switch friendStatus {
            case constants.friendConditions.areFriends:
                cell.leftButton.isHidden = true
                cell.rightButton.isHidden = false
                cell.rightButton.setTitle("Unfriend", for: .normal)
                setUnfilled(button: cell.rightButton)
            case constants.friendConditions.arentFriends:
                cell.leftButton.isHidden = true
                cell.rightButton.isHidden = false
                cell.rightButton.setTitle("Add friend", for: .normal)
                setFilled(button: cell.rightButton)
            case constants.friendConditions.receivedRequest:
                cell.leftButton.isHidden = false
                cell.rightButton.isHidden = false
                cell.leftButton.setTitle("Decline", for: .normal)
                setUnfilled(button: cell.leftButton)
                cell.rightButton.setTitle("Accept", for: .normal)
                setFilled(button: cell.rightButton)
            case constants.friendConditions.sentRequest:
                cell.leftButton.isHidden = true
                cell.rightButton.isHidden = false
                cell.rightButton.setTitle("Cancel request", for: .normal)
                setUnfilled(button: cell.rightButton)
            default:
                cell.rightButton.isHidden = true
                cell.leftButton.isHidden = true
            }
        } else {
            cell.rightButton.isHidden = true
            cell.leftButton.isHidden = true
        }
    }
    
    
    func setUnfilled(button: UIButton) {
        button.layer.borderWidth = 2
        button.backgroundColor = .clear
        button.layer.borderColor = UIColor(named: "AppRedColor")!.cgColor
        button.setTitleColor(UIColor(named: "AppRedColor"), for: .normal)
    }
    
    func setFilled(button: UIButton) {
        button.layer.borderWidth = 0
        button.backgroundColor = UIColor(named: "AppRedColor")!
        button.setTitleColor(UIColor.white, for: .normal)
    }
    
    
    public override func didUpdate(to object: Any) {
        self.user = object as? userModel
    }
    
    func rightButtonPressed(cell: addFriendCell) {
        cell.rightButton.isHidden = true
        cell.leftButton.isHidden = true
        cell.messageActivityIndicator.startAnimating()
        if let friendStatus = user.friendshipStatus {
            switch friendStatus {
            case constants.friendConditions.areFriends:
                //want to remove the friendship
                FirebaseManager.shared.unfriend(requestID: user.friendshipID ?? "") { (unfriendErr) in
                    if unfriendErr != nil {
                        self.configureButtons(cell: cell)
                    } else {
                        self.user.friendshipStatus = constants.friendConditions.arentFriends
                        self.configureButtons(cell: cell)
                    }
                    return
                }
            case constants.friendConditions.arentFriends:
                //pressed follow
                FirebaseManager.shared.sendFriendRequest(receiver: user) { (err_one, newFriendshipStatus) in
                    if err_one != nil {
                        self.configureButtons(cell: cell)
                    } else {
                        self.user.friendshipStatus = newFriendshipStatus
                        self.configureButtons(cell: cell)
                    }
                    return
                }
            case constants.friendConditions.receivedRequest:
                //Accept the request
                FirebaseManager.shared.acceptFriendRequest(requestID: user.friendshipID ?? "", sender: user) { (err_4, newStatus) in
                    if err_4 != nil {
                        self.configureButtons(cell: cell)
                    } else {
                        self.user.friendshipStatus = newStatus
                        self.configureButtons(cell: cell)
                    }
                    return
                }
            case constants.friendConditions.sentRequest:
                //Cancel the request you sent
                FirebaseManager.shared.unfriend(requestID: user.friendshipID ?? "") { (revokeError) in
                    if revokeError != nil {
                        self.configureButtons(cell: cell)
                    } else {
                        self.user.friendshipStatus = constants.friendConditions.arentFriends
                        self.configureButtons(cell: cell)
                    }
                    return
                }
            default:
                cell.messageActivityIndicator.stopAnimating()
                cell.rightButton.isHidden = true
                cell.leftButton.isHidden = true
            }
        } else {
            cell.messageActivityIndicator.stopAnimating()
            cell.rightButton.isHidden = true
            cell.leftButton.isHidden = true
        }
    }
    
    func leftButtonPressed(cell: addFriendCell) {
        cell.rightButton.isHidden = true
        cell.leftButton.isHidden = true
        cell.messageActivityIndicator.startAnimating()
        if let friendStatus = user.friendshipStatus {
            switch friendStatus {
            case constants.friendConditions.receivedRequest:
                //Decline the request
                FirebaseManager.shared.denyFriendRequest(requestID: user.friendshipID ?? "") { (denyErr) in
                    if denyErr != nil {
                         self.configureButtons(cell: cell)
                    } else {
                        self.user.friendshipStatus = constants.friendConditions.arentFriends
                        self.configureButtons(cell: cell)
                    }
                    return
                }
            default:
                cell.messageActivityIndicator.stopAnimating()
                cell.rightButton.isHidden = true
                cell.leftButton.isHidden = true
            }
        } else {
            cell.messageActivityIndicator.stopAnimating()
            cell.rightButton.isHidden = true
            cell.leftButton.isHidden = true
        }
    }
    
    
   
    
}
