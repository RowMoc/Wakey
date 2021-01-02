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
import Firebase

class addFriendCellSC: ListSectionController, addFriendCellDelegate{
    
    
    var user: userModel!
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 85)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(withNibName: String(describing: addFriendCell.self), bundle: Bundle.main, for: self, at: index)
        if let cell = cell as? addFriendCell {
            cell.usernameLabel.text = user.username
            cell.usernameLabel.adjustsFontSizeToFitWidth = true
            if (user.fullName == nil || user.fullName == "")  {
                cell.fullNameLabel.isHidden = true
            } else {
                cell.fullNameLabel.text = user.fullName
                cell.fullNameLabel.adjustsFontSizeToFitWidth = true
            }
            cell.profilePic.sd_setImage(with: URL(string: user.profilePicUrl))
            cell.sectionController = self
            cell.delegate = self
            cell.rightButton.isHidden = true
            cell.leftButton.isHidden = true
            self.determineRelationshipStatus(cell: cell)
        }
        return cell
    }
    
    
    func determineRelationshipStatus(cell: addFriendCell) {
        cell.messageActivityIndicator.startAnimating()
        if ((user.friendshipID == nil || user.friendshipID == "") && (user.friendshipStatus == nil || user.friendshipStatus == "")) {
            print("CALLING STATUS ENDPOINT")
            //launch query to find relationshiop status
            FirebaseManager.shared.fetchRelationshipStatus(otherUserID: user.userID) { (error, requestID, status) in
                if error == nil {
                    self.user.friendshipID = requestID
                    self.user.friendshipStatus = status
                    if let vc =  self.viewController as? searchFriendsVC  {
                        vc.userRelationshipStatusDidUpdate(updatedUser: self.user, requestID: requestID, status: status, sc: self)
                    } else if let vc = self.viewController as? viewRequestsVC {
                        //update arrays in viewRequestsVC
                        vc.userRelationshipStatusDidUpdate(updatedUser: self.user, requestID: requestID, status: status, sc: self)
                    }
                    self.configureButtons(cell: cell)
                } else {
                    self.configureButtons(cell: cell)
                }
            }
        } else {
            //we already found the relationship status so we just use the one already in the user object
            self.configureButtons(cell: cell)
        }
        
    }
    
    func configureButtons(cell: addFriendCell) {
        cell.messageActivityIndicator.stopAnimating()
        if let friendStatus = user.friendshipStatus {
            switch friendStatus {
            case constants.friendConditions.areFriends:
                cell.leftButton.isHidden = true
                cell.rightButton.isHidden = false
                setBlank(button: cell.rightButton)
                cell.rightButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
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
                cell.rightButton.setTitle("Requested", for: .normal)
                setUnfilled(button: cell.rightButton)
            default:
                cell.rightButton.isHidden = true
                cell.leftButton.isHidden = true
            }
        } else {
            //determine friendship status with a query
            cell.rightButton.isHidden = true
            cell.leftButton.isHidden = true
        }
    }
    
    
    func setUnfilled(button: UIButton) {
        button.setImage(nil, for: .normal)
        button.layer.borderWidth = 2
        button.backgroundColor = .clear
        button.layer.borderColor = UIColor(named: "AppRedColor")!.cgColor
        button.setTitleColor(UIColor(named: "AppRedColor"), for: .normal)
    }
    
    func setBlank(button: UIButton) {
        button.setImage(nil, for: .normal)
        button.layer.borderWidth = 0
        button.backgroundColor = .clear
        button.setTitle("", for: .normal)
    }
    
    func setFilled(button: UIButton) {
        button.setImage(nil, for: .normal)
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
                print(friendStatus)
                cell.messageActivityIndicator.stopAnimating()
                cell.rightButton.isHidden = false
                //want to remove the friendship
            case constants.friendConditions.arentFriends:
                //pressed follow
                FirebaseManager.shared.requestFriend(otherUser: self.user) { (requestError, requestID, status) in
                    if requestError != nil {
                        self.configureButtons(cell: cell)
                    } else {
                        self.user.friendshipID = requestID
                        self.user.friendshipStatus = status
                        if let vc =  self.viewController as? searchFriendsVC  {
                            vc.userRelationshipStatusDidUpdate(updatedUser: self.user, requestID: requestID, status: status, sc: self)
                        } else if let vc = self.viewController as? viewRequestsVC {
                            //update arrays in viewRequestsVC
                            vc.userRelationshipStatusDidUpdate(updatedUser: self.user, requestID: requestID, status: status, sc: self)
                        }
                        
                        self.configureButtons(cell: cell)
                    }
                }
            case constants.friendConditions.receivedRequest:
                //Accept the request
                if let requestID = self.user.friendshipID, requestID != "" {
                    FirebaseManager.shared.acceptOrDenyFriendRequest(otherUser: self.user, requestID: requestID, acceptedRequest: true) {  (requestError, thisRequestID, status) in
                        if requestError != nil {
                            self.configureButtons(cell: cell)
                        } else {
                            self.user.friendshipID = thisRequestID
                            self.user.friendshipStatus = status
                            if let vc =  self.viewController as? searchFriendsVC  {
                                vc.userRelationshipStatusDidUpdate(updatedUser: self.user, requestID: thisRequestID, status: status, sc: self)
                            } else if let vc = self.viewController as? viewRequestsVC {
                                //update arrays in viewRequestsVC
                                vc.userRelationshipStatusDidUpdate(updatedUser: self.user, requestID: thisRequestID, status: status, sc: self)
                            }
                            self.configureButtons(cell: cell)
                        }
                    }
                } else {
                    self.configureButtons(cell: cell)
                }
            case constants.friendConditions.sentRequest:
                //Cancel the request you sent
                print(friendStatus)
                print(friendStatus)
                cell.messageActivityIndicator.stopAnimating()
                cell.rightButton.isHidden = false
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
                print(friendStatus)
                if let requestID = self.user.friendshipID, requestID != "" {
                    FirebaseManager.shared.acceptOrDenyFriendRequest(otherUser: self.user, requestID: requestID, acceptedRequest: false) {  (requestError, thisRequestID, status) in
                        if requestError != nil {
                            self.configureButtons(cell: cell)
                        } else {
                            self.user.friendshipID = thisRequestID
                            self.user.friendshipStatus = status
                            if let vc =  self.viewController as? searchFriendsVC  {
                                vc.userRelationshipStatusDidUpdate(updatedUser: self.user, requestID: thisRequestID, status: status, sc: self)
                            } else if let vc = self.viewController as? viewRequestsVC {
                                //update arrays in viewRequestsVC
                                vc.userRelationshipStatusDidUpdate(updatedUser: self.user, requestID: thisRequestID, status: status, sc: self)
                            }
                            self.configureButtons(cell: cell)
                        }
                    }
                } else {
                    self.configureButtons(cell: cell)
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
