//
//  ButtonController.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/23.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit

protocol ButtonsDelegate: class {
    func scroll(to panel: Panel)
    func backToCamera()
}

class ButtonsController: UIViewController {

    weak var delegate: ButtonsDelegate?

    private var leftButton = UIButton.make(.left)
    private var centerButton = UIButton.make(.center)
    private var rightButton = UIButton.make(.right)

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        leftButton.tag = 0
        leftButton.addTarget(self, action: #selector(changePanel(_:)), for: .touchUpInside)
        view.addSubview(leftButton)
        NSLayoutConstraint.activate([
            //leftButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: Layout.distanceFromYCenter),
            leftButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 70),
            leftButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -UIScreen.main.bounds.width / 2 + Layout.sideButtonMargin)
            ])

        centerButton.tag = 1
        centerButton.addTarget(self, action: #selector(changePanel(_:)), for: .touchUpInside)
        view.addSubview(centerButton)
        NSLayoutConstraint.activate([
            //centerButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -Layout.distanceFromYCenter),
            centerButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -250),
            centerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])

        rightButton.tag = 2
        rightButton.addTarget(self, action: #selector(changePanel(_:)), for: .touchUpInside)
        view.addSubview(rightButton)
        NSLayoutConstraint.activate([
            //rightButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: Layout.distanceFromYCenter),
            rightButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 70),
            rightButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: UIScreen.main.bounds.width / 2 - Layout.sideButtonMargin)
            ])
    }

    @objc private func changePanel(_ sender: UIButton) {
        switch sender.tag {
        case 0: delegate?.scroll(to: .left)
        case 1: delegate?.scroll(to: .center)
        case 2: delegate?.scroll(to: .right)
        default: break
        }
    }

    func animateButtons(_ offset: CGFloat) {
        let buttonsSpacing: CGFloat = UIScreen.main.bounds.width / 2 - Layout.centralButtonHeight / 2 - Layout.sideButtonMargin * 2 - Layout.sideButtonHeight / 2

        leftButton.center.x = (Layout.sideButtonMargin + Layout.sideButtonHeight) / 2 + buttonsSpacing * abs(offset)
        rightButton.center.x = UIScreen.main.bounds.width - (Layout.sideButtonMargin + Layout.sideButtonHeight) / 2 - buttonsSpacing * abs(offset)
        let toScale = (view.frame.width*0.4)/Layout.centralButtonHeight
        centerButton.transform = CGAffineTransform(scaleX: 1/(1 + ((toScale - 1)*abs(offset))), y:1/(1 + ((toScale - 1)*abs(offset))))
        //centerButton
        //centerButton.center.y = (view.frame.height / 2 - Layout.distanceFromYCenter) + Layout.distanceFromYCenter * abs(offset)
        centerButton.center.y = (view.frame.height / 2 - Layout.distanceFromYCenter) + 60 * abs(offset)
    }
}

