//
//  UIView.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/21.
//  Copyright © 2020 Wakey. All rights reserved.
//


import UIKit

// 6
extension UIView {
    func fit(to container: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: container.leadingAnchor),
            trailingAnchor.constraint(equalTo: container.trailingAnchor),
            topAnchor.constraint(equalTo: container.topAnchor),
            bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
    }
}
