//
//  loadingViewCellSC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/11.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit
import IGListKit
import SDWebImage

class loadingViewCellSC: ListSectionController {
    
    override func sizeForItem(at index: Int) -> CGSize {
        
        guard let width = self.collectionContext?.containerSize.width else {
            return CGSize(width: UIScreen.main.bounds.width, height: 100)
        }
        return CGSize(width: width , height: 100)
    }
    
    
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(withNibName: String(describing: loadingViewCell.self), bundle: Bundle.main, for: self, at: index)
        if let cell = cell as? loadingViewCell {
        }
        return cell
    }
    
    
    
}
