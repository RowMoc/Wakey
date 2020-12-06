//
//  seperatorCellSC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/02.
//  Copyright © 2020 Wakey. All rights reserved.
//
import UIKit
import IGListKit
import EasyTipView

class seperatorCellSC: ListSectionController {
    var labelText: String!
    
    var fontSize: CGFloat = 35
    
    var showHelper = false
    
    var helperText = ""
    
    var lightText = false
    
    override func sizeForItem(at index: Int) -> CGSize {
        
        
        
        
        let insets = 40 as CGFloat
        let labelWidth = UIScreen.main.bounds.width - insets
        var font = UIFont(name: "Avenir-heavy", size: fontSize)
        if lightText {
            font = UIFont(name: "Avenir-book", size: fontSize)
        }
        //Work out height of label
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: labelWidth, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = self.labelText
        label.sizeToFit()
        let height = label.frame.height
        //creat cell height dynamically
        
        //determine width
        
        guard let width = self.collectionContext?.containerSize.width else {
            return CGSize(width: UIScreen.main.bounds.width, height: height + 10)
        }
        return CGSize(width: width, height: height + 10)
        
        
    }
    
    
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(withNibName: String(describing: seperatorCell.self), bundle: Bundle.main, for: self, at: index)
        if let cell = cell as? seperatorCell {
            cell.seperatorLabel.text = labelText
            if lightText {
                cell.seperatorLabel.font = UIFont(name: "Avenir-book", size: fontSize)
            } else {
                cell.seperatorLabel.font = UIFont(name: "Avenir-heavy", size: fontSize)
            }
            
            if showHelper {
                if (!UserDefaults.standard.bool(forKey:constants.helperVCKeys.hasHelpedProfileScreen)) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        EasyTipView.show(forView: cell.seperatorLabel ,withinSuperview: self.viewController?.view,
                                         text: self.helperText)
                        UserDefaults.standard.set(true, forKey: constants.helperVCKeys.hasHelpedProfileScreen)
                    }
                }
            }
        }
        return cell
    }
    
    
    
}

