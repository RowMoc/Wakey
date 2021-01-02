//
//  addFriendsMainVC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/20.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit
import IGListKit
import NVActivityIndicatorView
import AVFoundation
import Alamofire
import Firebase
import FBSDKLoginKit
import Contacts
import InstantSearch

class addFriendsMainVC: UIViewController {
    
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var gradientView: UIView!
    
    
    var centerVC: CenterVC!
    //var segments = ["Search", "Friends", "Requests"]
    var segments = ["Search", "Requests"]
    //must match above
    var searchUserSegment = "Search"
    var requestsSegment = "Requests"
    
    private lazy var searchVC: searchFriendsVC = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "searchFriendsVC") as! searchFriendsVC

        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        return viewController
    }()

    private lazy var requestsVC: viewRequestsVC = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "viewRequestsVC") as! viewRequestsVC

        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)

        return viewController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        let font: [AnyHashable : Any] = [NSAttributedString.Key.font : UIFont(name: "Avenir-heavy", size: 16) as Any]
        segmentControl.setTitleTextAttributes(font as? [NSAttributedString.Key : Any], for: .normal)
        segmentControl.selectedSegmentIndex = 0
        addGradientView()
        updateView()
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChild(viewController)

        // Add Child View as Subview
        view.addSubview(viewController.view)

        // Configure Child View
//        viewController.view.frame = CGRect(x: 0, y: segmentControl.frame.minY + 5, width: self.view.frame.width, height: <#T##CGFloat#>)
//        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        viewController.view.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 5).isActive = true
        viewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        viewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }

    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParent: nil)

        // Remove Child View From Superview
        viewController.view.removeFromSuperview()

        // Notify Child View Controller
        viewController.removeFromParent()
    }
    
    private func updateView() {
        if segmentControl.selectedSegmentIndex == 0 {
            remove(asChildViewController: requestsVC)
            add(asChildViewController: searchVC)
        } else {
            remove(asChildViewController: searchVC)
            add(asChildViewController: requestsVC)
        }
    }
    
    
    func addGradientView() {
        let gradientViewHeight = self.view.frame.height * 0.18
        self.gradientView.frame = CGRect(x: 0, y: self.view.frame.height - gradientViewHeight, width: self.view.frame.width, height: gradientViewHeight)
        let gradientLayer = CAGradientLayer()
        gradientView.backgroundColor = .clear
        gradientView.layer.masksToBounds = false
        gradientLayer.frame = self.gradientView.bounds
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.00675).cgColor, UIColor.black.withAlphaComponent(0.0125).cgColor, UIColor.black.withAlphaComponent(0.025).cgColor,UIColor.black.withAlphaComponent(0.05).cgColor,UIColor.black.withAlphaComponent(0.07).cgColor, UIColor.black.withAlphaComponent(0.09).cgColor, UIColor.black.withAlphaComponent(0.11).cgColor,UIColor.black.withAlphaComponent(0.14).cgColor,UIColor.black.withAlphaComponent(0.17).cgColor,UIColor.black.withAlphaComponent(0.2).cgColor, UIColor.black.withAlphaComponent(0.22).cgColor,UIColor.black.withAlphaComponent(0.24).cgColor, UIColor.black.withAlphaComponent(0.26).cgColor, UIColor.black.withAlphaComponent(0.28).cgColor, UIColor.black.withAlphaComponent(0.3).cgColor, UIColor.black.withAlphaComponent(0.32).cgColor, UIColor.black.withAlphaComponent(0.35).cgColor,UIColor.black.withAlphaComponent(0.37).cgColor]
        self.gradientView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            FirebaseManager.shared.getCurrentUser { (error, user) in
                if let user = user {
                    Analytics.logEvent("navigated_to_add_friends_page", parameters: ["username": user.username])
                }
            }
        }
    }
    
    
    @IBAction func segmentControlValueChanged(_ sender: Any) {
        //change which  view controller we put in
        self.updateView()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        self.resignFirstResponder()
    }
    
}
