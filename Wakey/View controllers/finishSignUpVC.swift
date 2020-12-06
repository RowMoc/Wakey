//
//  finishSignUpVC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/06/16.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import NVActivityIndicatorView
import Firebase
import SDWebImage
import FlagPhoneNumber

class finishSignUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var phoneNumberTF: FPNTextField!
    @IBOutlet weak var logoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    @IBOutlet weak var uploadProfilePicButton: uploadProPicButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var completeSignUpButton: UIButton!
    
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var fullNameTF: SkyFloatingLabelTextField!
    @IBOutlet weak var usernameTF: SkyFloatingLabelTextField!
    //b@IBOutlet weak var containerViewTopConstraint: NSLayoutConstraint!
    
    
    var partialUser: [String: String]!
    var imagePicker = UIImagePickerController()
    var profilePicSet = false
    var phoneNumberIsValid = false
    var didSignUpWithFacebook = false
    let db = Firestore.firestore()
    
    var listController: FPNCountryListViewController = FPNCountryListViewController(style: .grouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let bgImageView = UIImageView(frame: self.view.frame)
        bgImageView.image = UIImage(named: "loginBackground")!
        bgImageView.contentMode = .scaleAspectFill
        self.view.insertSubview(bgImageView, at: 0)
        setUpTextFields(textField: fullNameTF, field: "First and last name")
        setUpTextFields(textField: usernameTF, field: "Username")
        self.hideKeyboardWhenTappedAround()
        //config phone number TF
        configPhoneNumberTF()
        
        //set top view in place
        //self.topContainerView.frame.origin.y = 0
        // Do any additional setup after loading the view.
        completeSignUpButton.layer.cornerRadius = 3
        usernameTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        populateDetails()
    }
    
    
    var phoneNumberTFBorder: CALayer!
    
    func configPhoneNumberTF() {
        phoneNumberTF.borderStyle = .none
        listController.setup(repository: phoneNumberTF.countryRepository)
        listController.didSelect = { [weak self] country in
            self?.phoneNumberTF.setFlag(countryCode: country.code)
        }
        phoneNumberTF.delegate = self
        phoneNumberTF.font = UIFont(name: "Avenir-book", size: 17)
        phoneNumberTF.textColor = .white
        phoneNumberTF.tintColor = .white
        
        // Custom the size/edgeInsets of the flag button
        phoneNumberTF.flagButtonSize = CGSize(width: 35, height: 35)
        phoneNumberTF.flagButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        // The placeholder is an example phone number of the selected country by default. You can add your own placeholder :
        phoneNumberTF.hasPhoneNumberExample = true
        phoneNumberTF.placeholder = "Phone Number"
        phoneNumberTF.setFlag(countryCode: .US)
        //phoneNumberTF.addBottomBorderWithColor(color: .white, width: UIScreen.main.bounds.width - 40)
        
        //adding the bottom line
        phoneNumberTFBorder = CALayer()
        phoneNumberTFBorder.frame = CGRect(x: 0.0, y: phoneNumberTF.frame.height - 1, width: phoneNumberTF.frame.width, height: 1.0)
        phoneNumberTFBorder.backgroundColor = UIColor.white.cgColor
        phoneNumberTF.layer.addSublayer(phoneNumberTFBorder)
    }
    
    
    func configureUI() {
        
        let buffer = 20 as CGFloat
        var topInset = 0 as CGFloat
        var bottomInset = 0 as CGFloat
        if #available(iOS 11.0, *) {
            bottomInset = view.safeAreaInsets.bottom
            topInset = view.safeAreaInsets.top
            self.logoTopConstraint.constant = view.safeAreaInsets.top
        } else {
            bottomInset = bottomLayoutGuide.length
            topInset = topLayoutGuide.length
        }
        self.logoTopConstraint.constant = topInset
        completeSignUpButton.frame = CGRect(x: self.view.frame.midX - 100, y: self.view.frame.height - 40 - bottomInset - buffer, width: 200, height: 40)
        
        self.activityIndicator.frame = completeSignUpButton.frame
        self.errorLabel.frame = CGRect(x: 20, y: self.view.frame.height - 40 - bottomInset - 70, width: self.view.frame.width - 40, height: 33)
        self.errorLabel.lineBreakMode = .byWordWrapping
        self.errorLabel.numberOfLines = 0
    }
    
    func populateDetails() {
        self.fullNameTF.text = partialUser["full_name"] ?? ""
        if let profilePicUrlStr =  partialUser["profile_pic_url"], profilePicUrlStr != "" {
            if let profilePicUrl = URL(string: profilePicUrlStr) {
                self.completeSignUpButton.isHidden = true
                self.activityIndicator.startAnimating()
                self.errorLabel.text = "Fetching your Facebook profile picture..."
                uploadProfilePicButton.sd_setImage(with: profilePicUrl, for: .normal) { (image, error, cacheType, url) in
                    if (error != nil || image == nil) {
                        self.profilePicSet = false
                    } else {
                        self.roundProfilePic()
                        self.profilePicSet = true
                    }
                    self.completeSignUpButton.isHidden = false
                    self.activityIndicator.stopAnimating()
                    self.errorLabel.text = ""
                }
            }
        }
    }
    
    // This will notify us when something has changed on the textfield
    @objc func textFieldDidChange(_ textfield: UITextField) {
        if let text = textfield.text {
            if let tf = textfield as? SkyFloatingLabelTextField {
                
                if text.range(of: "^([a-z0-9_.]){5,30}$", options: .regularExpression, range: nil, locale: nil) != nil || text == "" {
                    //Valid
                    tf.errorMessage = ""
                } else {
                    tf.errorMessage = "Invalid username"
                    
                }
            }
        }
    }
    
    
    @IBAction func uploadProfilePicPressed(_ sender: Any) {
        self.view.endEditing(true)
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            //print("Button capture")
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController (_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        // check if an image was selected,
        // since images are not the only media type that can be selected
        if let image = info[.originalImage] {
            dismiss(animated: true, completion: { () -> Void in
                self.profilePicSet = true
                self.roundProfilePic()
                self.uploadProfilePicButton.setImage((image as! UIImage), for: .normal)
            })
        }
    }
    
    func roundProfilePic() {
        uploadProfilePicButton.backgroundColor = .clear
        uploadProfilePicButton.layer.cornerRadius = self.uploadProfilePicButton.frame.width/2
        uploadProfilePicButton.layer.borderWidth = 1
        uploadProfilePicButton.layer.borderColor = UIColor.white.cgColor
        uploadProfilePicButton.clipsToBounds = true
    }
    
    
    @IBAction func completeSignUpPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.errorLabel.text = ""
        if !profilePicSet {
            self.errorLabel.text = "Please select a profile picture"
            return
        }
        if (fullNameTF.text ?? "") == "" {
            self.errorLabel.text = "Please enter your full name"
            return
        }
        if (!phoneNumberIsValid) {
            self.errorLabel.text = "Please enter a valid phone number"
            return
        }
        self.checkUsername()
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
    
    override func viewDidAppear(_ animated: Bool) {
        setupKeyboardObservers()
        configureUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    var keyboardIsShown = false
    @IBOutlet weak var topContainerViewTopConstraint: NSLayoutConstraint!
    
    func adjustContentForKeyboard(shown: Bool, notification: Notification) {
        if shown == keyboardIsShown {return}
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue, let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue, let curveValue = (notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue else { return }
        let buffer = 20 as CGFloat
        var bottSafeInset = 0 as CGFloat
        if #available(iOS 11.0, *) {
            bottSafeInset = view.safeAreaInsets.bottom
        } else {
            bottSafeInset = bottomLayoutGuide.length
        }
        let buttonY = shown ? (UIScreen.main.bounds.height - keyboardFrame.height - buffer - self.completeSignUpButton.frame.height): (UIScreen.main.bounds.height - bottSafeInset - self.completeSignUpButton.frame.height - buffer)
        let topContainterY = (shown && topContainerView.frame.height > (buttonY - buffer)) ? (topContainerView.frame.height - buttonY - buffer) : 0
        self.topContainerViewTopConstraint.constant = topContainterY
        let curveAnimationOptions = UIView.AnimationOptions(rawValue: curveValue << 16)
        UIView.animate(withDuration: keyboardDuration, delay: 0, options:curveAnimationOptions, animations: {
            self.completeSignUpButton.frame.origin.y = buttonY
            self.view.layoutIfNeeded()
        }, completion: nil)
        self.keyboardIsShown = shown
    }
    
    
    func checkUsername() {
        let username = usernameTF.text ?? ""
        self.view.isUserInteractionEnabled = false
        self.completeSignUpButton.isHidden = true
        self.activityIndicator.startAnimating()
        if username.range(of: "^([a-z0-9_.]){5,30}$", options: .regularExpression, range: nil, locale: nil) != nil {
            self.trySignUserUp(username: username)
        } else {
            self.errorLabel.text = "Ensure username is made up of between 5 and 30 non-special characters"
            self.activityIndicator.stopAnimating()
            self.completeSignUpButton.isHidden = false
            self.view.isUserInteractionEnabled = true
            self.activityIndicator.stopAnimating()
            return
        }
    }
    
    
    func trySignUserUp(username: String) {
        guard let currAuthUser = Auth.auth().currentUser, let profilePic = uploadProfilePicButton.imageView?.image else {
            self.errorLabel.text = "your session is not current. Please try logging in again"
            self.activityIndicator.stopAnimating()
            self.completeSignUpButton.isHidden = false
            self.view.isUserInteractionEnabled = true
            return
        }
        
        FirebaseManager.shared.createNewUser(authUser: currAuthUser, username: username, fullName: fullNameTF.text ?? "" , phoneNumber: phoneNumberTF.getRawPhoneNumber() ?? "", profileImage: profilePic) { (createUserErrString, proPicUploadSuccesfully) in
            if let createUserErrString = createUserErrString {
                self.errorLabel.text = createUserErrString
                self.completeSignUpButton.isHidden = false
                self.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
            } else {
                if proPicUploadSuccesfully {
                    print("Pro pic uploaded succesfully")
                } else {
                    print("Pro pic didn't upload succesfully")
                }
                self.view.isUserInteractionEnabled = true
                self.errorLabel.text = ""
                self.activityIndicator.stopAnimating()
                self.completeSignUpButton.isHidden = false
                self.view.isUserInteractionEnabled = true
                self.segueToHomeViewController()
            }
        }
    }
    
    func setUpTextFields(textField: SkyFloatingLabelTextField, field: String) {
        textField.font = UIFont(name: "Avenir-book", size: 15)!
        textField.placeholderFont = UIFont(name: "Avenir-book", size: 15)!
        textField.titleFont = UIFont(name: "Avenir-heavy", size: 14)!
        textField.placeholder = field
        textField.textErrorColor = .lightGray
        textField.titleErrorColor = .lightGray
        textField.title = field
        textField.tintColor = .white // the color of the blinking cursor
        textField.textColor = .white
        textField.placeholderColor = .white
        textField.lineColor = .white
        textField.selectedTitleColor = .white
        textField.selectedLineColor = .white
        textField.lineHeight = 1.0 // bottom line height in points
        textField.selectedLineHeight = 2.0
        textField.text = ""
        textField.layer.removeAllAnimations()
        textField.delegate = self
    }
    
    
    //dismiss keyboard with return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func segueToHomeViewController() {
        self.activityIndicator.stopAnimating()
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        if let walkthroughViewController = storyboard.instantiateViewController(withIdentifier: "WalkThroughVC") as? WalkThroughVC {
            walkthroughViewController.modalPresentationStyle = .fullScreen
            present(walkthroughViewController, animated: true, completion: nil)
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField == phoneNumberTF) {
            //adding the bottom line
            phoneNumberTFBorder.removeFromSuperlayer()
            phoneNumberTFBorder = CALayer()
            phoneNumberTFBorder.frame = CGRect(x: 0.0, y: phoneNumberTF.frame.height - 2, width: phoneNumberTF.frame.width, height: 2.0)
            phoneNumberTFBorder.backgroundColor = UIColor.white.cgColor
            phoneNumberTF.layer.addSublayer(phoneNumberTFBorder)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField == phoneNumberTF) {
            //adding the bottom line
            phoneNumberTFBorder.removeFromSuperlayer()
            phoneNumberTFBorder = CALayer()
            phoneNumberTFBorder.frame = CGRect(x: 0.0, y: phoneNumberTF.frame.height - 1, width: phoneNumberTF.frame.width, height: 1.0)
            phoneNumberTFBorder.backgroundColor = UIColor.white.cgColor
            phoneNumberTF.layer.addSublayer(phoneNumberTFBorder)
        }
    }
    

}


extension finishSignUpVC: FPNTextFieldDelegate {
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        phoneNumberTF.rightViewMode = .always
        phoneNumberIsValid = isValid
        let rightViewImage = UIImageView(image: isValid ? UIImage.init(systemName: "checkmark.seal.fill")! : UIImage.init(systemName: "xmark.circle")!)
        rightViewImage.image = rightViewImage.image?.withRenderingMode(.alwaysTemplate)
        rightViewImage.tintColor =  isValid ? UIColor(named: "AppGreenColor") : .white
        phoneNumberTF.rightView = rightViewImage
        print(
            isValid,
            phoneNumberTF.getFormattedPhoneNumber(format: .E164) ?? "E164: nil",
            phoneNumberTF.getFormattedPhoneNumber(format: .International) ?? "International: nil",
            phoneNumberTF.getFormattedPhoneNumber(format: .National) ?? "National: nil",
            phoneNumberTF.getFormattedPhoneNumber(format: .RFC3966) ?? "RFC3966: nil",
            phoneNumberTF.getRawPhoneNumber() ?? "Raw: nil"
        )
    }
    
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        print(name, dialCode, code)
    }
    
    
    func fpnDisplayCountryList() {
        let navigationViewController = UINavigationController(rootViewController: listController)
        
        listController.title = "Countries"
        listController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(dismissCountries))
        self.present(navigationViewController, animated: true, completion: nil)
    }
    
    @objc func dismissCountries() {
        listController.dismiss(animated: true, completion: nil)
    }
}
