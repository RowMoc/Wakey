//
//  profileHeaderCellSC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/03.
//  Copyright © 2020 Wakey. All rights reserved.
//


import UIKit
import IGListKit
import SDWebImage
import FBSDKLoginKit

class profileHeaderCellSC: ListSectionController, profileHeaderCellCollectionViewCellDelegate {
    
    
    var user: userModel!
    
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 190)
    }
    
    
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(withNibName: String(describing: profileHeaderCellCollectionViewCell.self), bundle: Bundle.main, for: self, at: index)
        if let cell = cell as? profileHeaderCellCollectionViewCell {
            cell.usernameLabel.text = user.username
            cell.fullNameLabel.text = user.fullName
            cell.delegate = self
            cell.profilePic.sd_setImage(with: URL(string: user.profilePicUrl))
        }
        return cell
    }
    
    public override func didUpdate(to object: Any) {
        self.user = object as? userModel
    }
    
    public override func didSelectItem(at index: Int) {
        
    }
}

