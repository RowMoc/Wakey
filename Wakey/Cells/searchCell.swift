//
//  searchCell.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/20.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit

class searchCell: UICollectionViewCell {

    lazy var searchBar: UISearchBar = {
        let view = UISearchBar()
        view.placeholder = "Search by name or username..."
        view.barTintColor = UIColor.clear
        view.backgroundColor = UIColor.clear
        view.isTranslucent = true
        view.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        
        self.contentView.addSubview(view)
        return view
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        searchBar.frame = contentView.bounds
    }

}

