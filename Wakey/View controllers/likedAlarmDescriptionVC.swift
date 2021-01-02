//
//  likedAlarmDescriptionVC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/12/09.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit

class likedAlarmDescriptionVC: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var popUpShadowView: UIView!
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var cancelButtonShadowView: UIView!
    
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var topLabel: UILabel!
    
    @IBOutlet weak var middleLabel: UILabel!
    
    @IBOutlet weak var cancelButtonView: UIView!
    
    @IBOutlet weak var descriptionTF: UITextField!
    
    
    var homeVC: playAlarmVC!
    var likedAlarm: receivedAlarm!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configPopUpUI()
        descriptionTF.delegate = self
        self.descriptionTF.adjustsFontSizeToFitWidth = true
        self.confirmButton.isEnabled = false
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupKeyboardObservers()
        descriptionTF.becomeFirstResponder()
        
    }
    
    
    
    
    func configPopUpUI() {
        popUpShadowView.backgroundColor = UIColor.clear
        popUpShadowView.layer.shadowColor = UIColor.black.cgColor
        popUpShadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
        popUpShadowView.layer.shadowOpacity = 0.4
        popUpShadowView.layer.shadowRadius = 2.0
        
        cancelButtonShadowView.backgroundColor = .clear
        cancelButtonShadowView.layer.shadowColor = UIColor.black.cgColor
        cancelButtonShadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cancelButtonShadowView.layer.shadowOpacity = 0.4
        cancelButtonShadowView.layer.shadowRadius = 2.0
        
        popUpView.layer.cornerRadius = 15.0
        popUpView.layer.masksToBounds = true
        popUpView.backgroundColor = UIColor(named: "cellBackgroud")!
        
        cancelButtonView.layer.cornerRadius = 15.0
        cancelButtonView.layer.masksToBounds = true
        cancelButtonView.backgroundColor = UIColor(named: "cellBackgroud")!
    }
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        completeLikedMessageBackend(description: self.descriptionTF.text ?? "")
        self.homeVC.descriptionViewShadowView?.removeFromSuperview()
        self.dismiss(animated: false) {
            self.homeVC.startAudioAfterOtherViewDismisses()
        }
    }
    
    
    
    
    @IBAction func skipButtonPressed(_ sender: Any) {
        completeLikedMessageBackend(description: "")
        self.homeVC.descriptionViewShadowView?.removeFromSuperview()
        self.dismiss(animated: false) {
            self.homeVC.startAudioAfterOtherViewDismisses()
        }
    }
    
    
    func completeLikedMessageBackend(description: String) {
        FirebaseManager.shared.likeWakeyMessage(thisMessage: likedAlarm, didLikeMessage: true, description: description) { (error) in
            if error == nil {
                
            } else {
                print("Failed to like alarm on the backend")
            }
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
            return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        self.confirmButton.isEnabled = (count > 0)
        return count <= 40
    }
    
    
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func handleKeyboardWillShow(_ notification: Notification) {
        adjustContentForKeyboard(shown: true, notification: notification)
    }
    
    @objc func handleKeyboardWillHide(_ notification: Notification) {
        adjustContentForKeyboard(shown: false, notification: notification)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @IBOutlet weak var heightOfPopUpViewConstraint: NSLayoutConstraint!
    var keyboardIsShown = false
    
    func adjustContentForKeyboard(shown: Bool, notification: Notification) {
        if shown == keyboardIsShown {return}
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue, let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue, let curveValue = (notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue else { return }
        
        var bottSafeInset = 0 as CGFloat
        if #available(iOS 11.0, *) {
            bottSafeInset = view.safeAreaInsets.bottom
        } else {
            bottSafeInset = bottomLayoutGuide.length
        }
        let popUpHeight = self.popUpShadowView.frame.height/2
        let cancelButtonHeight = self.cancelButtonShadowView.frame.height
        let buffers = 30 as CGFloat
        let keyboardMaxY = self.view.frame.height - keyboardFrame.height
        
    
        let cancelButtonMinY = self.view.frame.height/2 + popUpHeight  + cancelButtonHeight + buffers
        
        let curveAnimationOptions = UIView.AnimationOptions(rawValue: curveValue << 16)
        if shown {
            if keyboardMaxY < cancelButtonMinY {
                let frameY = cancelButtonMinY - keyboardMaxY
                
                UIView.animate(withDuration: keyboardDuration, delay: 0, options:curveAnimationOptions, animations: {
                    self.view.frame = CGRect(x: 0, y: -frameY , width: self.view.frame.width, height: self.view.frame.height)
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }
        } else {
            UIView.animate(withDuration: keyboardDuration, delay: 0, options:curveAnimationOptions, animations: {
                self.view.frame = CGRect(x: 0, y: 0 , width: self.view.frame.width, height: self.view.frame.height)
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        self.keyboardIsShown = shown
    }
        
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
