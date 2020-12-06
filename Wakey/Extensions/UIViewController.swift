//
//  UIViewController.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/21.
//  Copyright © 2020 Wakey. All rights reserved.
//


import UIKit

extension UIViewController {
    func addChild(_ controller: UIViewController, toContainer container: UIView) {
        guard let subView = controller.view else { return }
        addChild(controller)
        container.addSubview(subView)
        controller.didMove(toParent: self)
        subView.fit(to: container)
        container.clipsToBounds = true
    }
}
