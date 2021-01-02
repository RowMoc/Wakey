//
//  loginVC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/05/02.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import NVActivityIndicatorView
import Firebase
//FB login
import FBSDKLoginKit


class loginVC: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var logoImageView: UIImageView!
    
    @IBOutlet weak var topLabel: UILabel!
    
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
    
    @IBOutlet weak var confirmPasswordTextField: SkyFloatingLabelTextField!
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    
    @IBOutlet weak var signInVsSignUpButton: UIButton!
    
    @IBOutlet weak var orLabelSeperator: UILabel!
    @IBOutlet weak var leftLineOrSeperator: UIView!
    @IBOutlet weak var topContainerViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var wakeyLogoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var rightLineOrSeperator: UIView!
    enum currModeType {
        case signUpChooseMode, signUpEmail, signInChooseMode, signInEmail
    }
    
    var currMode = currModeType.signUpChooseMode
    
    var didUnwind = false
    var fbLoginButton: FBLoginButton!
    var bottomSafeAreaInset = 0 as CGFloat
    var topSafeAreaInset = 0 as CGFloat
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let bgImageView = UIImageView(frame: self.view.frame)
        bgImageView.image = UIImage(named: "loginBackground")!
        bgImageView.contentMode = .scaleAspectFill
        self.view.insertSubview(bgImageView, at: 0)
        
        //FB login button
        fbLoginButton = FBLoginButton()
        fbLoginButton.permissions = ["public_profile", "email", "user_friends"]
        let buttonText = NSAttributedString(string: "sign in with Facebook", attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir-medium", size: 15) as Any])
        fbLoginButton.setAttributedTitle(buttonText, for: .normal)
        fbLoginButton.delegate = self
        fbLoginButton.frame = CGRect(x: signInButton.frame.minX, y: self.orLabelSeperator.frame.maxY + 10, width: signInButton.frame.width, height: 30)
        view.addSubview(fbLoginButton)
        fbLoginButton.layoutIfNeeded()
        hideUI(state: true)
    }
    
    func setupUI() {
        
        activityIndicator.stopAnimating()
        if #available(iOS 11.0, *) {
            bottomSafeAreaInset = view.safeAreaInsets.bottom
            topSafeAreaInset = view.safeAreaInsets.top
        } else {
            bottomSafeAreaInset = bottomLayoutGuide.length
            topSafeAreaInset = topLayoutGuide.length
        }
        switch currMode {
        case .signUpChooseMode:
            signInButton.isHidden = false
            fbLoginButton.isHidden = false
            backButton.isHidden = true
            emailTextField.isHidden = true
            passwordTextField.isHidden = true
            confirmPasswordTextField.isHidden = true
            signInButton.isHidden = false
            orLabelSeperator.isHidden = false
            leftLineOrSeperator.isHidden = false
            rightLineOrSeperator.isHidden = false
            orLabelSeperator.frame = CGRect(x: view.center.x - 35, y: UIScreen.main.bounds.height/2 - 10, width: 70, height: 20)
            leftLineOrSeperator.frame = CGRect(x: 20, y: UIScreen.main.bounds.height/2 - 1, width: UIScreen.main.bounds.width/2 - 20 - 35, height: 2)
            rightLineOrSeperator.frame = CGRect(x: UIScreen.main.bounds.width/2 + 35, y: UIScreen.main.bounds.height/2 - 1, width: UIScreen.main.bounds.width/2 - 20 - 35, height: 2)
            signInButton.layer.cornerRadius = 3
            signInButton.frame = CGRect(x: view.center.x - 100, y: UIScreen.main.bounds.height/2 - 60, width: 200, height: 40)
            fbLoginButton.frame = CGRect(x: view.center.x - 100, y: orLabelSeperator.frame.maxY + 10, width: 200, height: 40)
            fbLoginButton.layer.cornerRadius = 3
            fbLoginButton.setAttributedTitle(NSAttributedString(string: "sign up with Facebook", attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir-medium", size: 15) as Any]), for: .normal)
            signInButton.isEnabled = true
            signInButton.setTitle("sign up with email", for: .normal)
            topLabel.text = ""
            signInVsSignUpButton.setTitle("Already have an account?", for: .normal)
            signInVsSignUpButton.isHidden = false
        case .signInChooseMode:
            signInButton.isHidden = false
            fbLoginButton.isHidden = false
            
            backButton.isHidden = true
            emailTextField.isHidden = true
            passwordTextField.isHidden = true
            confirmPasswordTextField.isHidden = true
            orLabelSeperator.isHidden = false
            leftLineOrSeperator.isHidden = false
            rightLineOrSeperator.isHidden = false
            orLabelSeperator.frame = CGRect(x: view.center.x - 35, y: view.center.y - 10, width: 70, height: 20)
            leftLineOrSeperator.frame = CGRect(x: 20, y: UIScreen.main.bounds.height/2 - 1, width: UIScreen.main.bounds.width/2 - 20 - 35, height: 2)
            rightLineOrSeperator.frame = CGRect(x: UIScreen.main.bounds.width/2 + 35, y: UIScreen.main.bounds.height/2 - 1, width: UIScreen.main.bounds.width/2 - 20 - 35, height: 2)
            signInButton.layer.cornerRadius = 3
            signInButton.frame = CGRect(x: view.center.x - 100, y: view.center.y - 60, width: 200, height: 40)
            fbLoginButton.frame = CGRect(x: view.center.x - 100, y: orLabelSeperator.frame.maxY + 10, width: 200, height: 40)
            fbLoginButton.layer.cornerRadius = 3
            fbLoginButton.setAttributedTitle(NSAttributedString(string: "sign in with Facebook", attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir-medium", size: 15) as Any]), for: .normal)
            signInButton.isEnabled = true
            signInButton.setTitle("sign in with email", for: .normal)
            topLabel.text = ""
            signInVsSignUpButton.setTitle("Don't yet have an account?", for: .normal)
            signInVsSignUpButton.isHidden = false
        case .signUpEmail:
            signInButton.frame = CGRect(x: view.center.x - 100, y: view.frame.height - bottomSafeAreaInset - 60, width: 200, height: 40)
            signInButton.layer.cornerRadius = 3
            fbLoginButton.isHidden = true
            backButton.isHidden = false
            emailTextField.isHidden = false
            passwordTextField.isHidden = false
            confirmPasswordTextField.isHidden = false
            orLabelSeperator.isHidden = true
            leftLineOrSeperator.isHidden = true
            rightLineOrSeperator.isHidden = true
            signInButton.setTitle("sign up", for: .normal)
            orLabelSeperator.isHidden = true
            leftLineOrSeperator.isHidden = true
            rightLineOrSeperator.isHidden = true
            signInVsSignUpButton.isHidden = true
            
            backButton.isHidden = false
            
        case .signInEmail:
            signInButton.frame = CGRect(x: view.center.x - 100, y: view.frame.height - bottomSafeAreaInset - 60, width: 200, height: 40)
            signInButton.layer.cornerRadius = 3
            fbLoginButton.isHidden = true
            backButton.isHidden = false
            emailTextField.isHidden = false
            passwordTextField.isHidden = false
            confirmPasswordTextField.isHidden = true
            leftLineOrSeperator.isHidden = true
            rightLineOrSeperator.isHidden = true
            signInButton.setTitle("sign in", for: .normal)
            orLabelSeperator.isHidden = true
            leftLineOrSeperator.isHidden = true
            rightLineOrSeperator.isHidden = true
            signInVsSignUpButton.isHidden = true
            
            backButton.isHidden = false
        }
        logoImageView.isHidden = false
        fbLoginButton.layoutIfNeeded()
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
    
    var keyboardIsShown = false
    
    func adjustContentForKeyboard(shown: Bool, notification: Notification) {
        if shown == self.keyboardIsShown {return}
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue, let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue, let curveValue = (notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue else { return }
        //don't want to animate anything when on the choose modes
        if (currMode == .signInChooseMode || currMode == .signUpChooseMode) {return}
        let buffer = 20 as CGFloat
        var bottSafeInset = 0 as CGFloat
        if #available(iOS 11.0, *) {
            bottSafeInset = view.safeAreaInsets.bottom
        } else {
            bottSafeInset = bottomLayoutGuide.length
        }
        let buttonY = shown ? (UIScreen.main.bounds.height - keyboardFrame.height - buffer - self.signInButton.frame.height): (view.frame.height - bottSafeInset - self.signInButton.frame.height - buffer)
        let topContainterY = (shown && topContainerView.frame.height > (buttonY - buffer)) ? (topContainerView.frame.height - buttonY - buffer) : 0
        topContainerViewTopConstraint.constant = topContainterY
        let curveAnimationOptions = UIView.AnimationOptions(rawValue: curveValue << 16)
        UIView.animate(withDuration: keyboardDuration, delay: 0, options:curveAnimationOptions, animations: {
            self.signInButton.frame.origin.y = buttonY
            self.view.layoutIfNeeded()
        }, completion: nil)
        self.keyboardIsShown = shown
    }
    
    
    var loading: NVActivityIndicatorView?
    var centreLogo: UIImageView?
    override func viewDidAppear(_ animated: Bool) {
        setupKeyboardObservers()
        if !didUnwind {
            loading = NVActivityIndicatorView(frame: CGRect(x: view.frame.width/2 - 35, y: view.frame.height/2 - 35, width: 70, height: 70), type: .circleStrokeSpin, color: .white, padding: 0)
            centreLogo = UIImageView(frame: CGRect(x: view.frame.width/2 - 25, y: view.frame.height/2 - 25, width: 50, height: 50))
            centreLogo?.image = UIImage(named: "whiteLogo")
            centreLogo?.contentMode = .scaleAspectFit
            view.addSubview(centreLogo!)
            view.addSubview(loading!)
            loading!.startAnimating()
            let user = Auth.auth().currentUser
            if user != nil {
                self.determineSegueAway(signedUpWithFB: true)
                return
            } else {
                //                if let token = AccessToken.current,!token.isExpired {
                //                    let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
                //                    Auth.auth().signIn(with: credential) { (authResult, error) in
                //                        if let error = error {
                //                            //failed to login
                //                            let authError = error as NSError
                //                            self.topLabel.text = "Facebook login failed."
                //                            //
                //                            return
                //                        }
                //                        print("Facebook user is already logged in")
                //                        //login succesful
                //                        self.determineSegueAway(signedUpWithFB: true)
                //                        return
                //                    }
                //                    return
                //                    // User is logged in, do work such as go to next view controller.
                //
            }
            self.loading?.stopAnimating()
            self.loading?.removeFromSuperview()
            self.centreLogo?.removeFromSuperview()
            self.setUpFirstState()
            return
        } else {
            self.setUpFirstState()
            return
        }
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        setUpFirstState()
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @IBAction func prepareForUnwindWithSegue(segue:UIStoryboardSegue) {
        didUnwind = true
        setUpFirstState()
        //setUpFirstState()
    }
    
    func hideUI(state: Bool) {
        emailTextField.isHidden = state
        passwordTextField.isHidden = state
        confirmPasswordTextField.isHidden = state
        signInVsSignUpButton.isHidden = state
        signInButton.isHidden = state
        topLabel.isHidden = state
        fbLoginButton.isHidden = state
        fbLoginButton.layoutIfNeeded()
        self.backButton.isHidden = state
        self.logoImageView.isHidden = state
    }
    
    func setUpFirstState() {
        //hideUI(state: false)
        if #available(iOS 11.0, *) {
            bottomSafeAreaInset = view.safeAreaInsets.bottom
            topSafeAreaInset = view.safeAreaInsets.top
        } else {
            bottomSafeAreaInset = bottomLayoutGuide.length
            topSafeAreaInset = topLayoutGuide.length
        }
        wakeyLogoTopConstraint.constant = topSafeAreaInset
        signInButton.layer.cornerRadius = 3
        fbLoginButton.layer.cornerRadius = 3
        topLabel.adjustsFontSizeToFitWidth = true
        setUpTextFields(textField: emailTextField, field: "Email")
        setUpTextFields(textField: passwordTextField, field: "Password")
        setUpTextFields(textField: confirmPasswordTextField, field: "Confirm password")
        currMode = currModeType.signUpChooseMode
        setupUI()
        self.view.isUserInteractionEnabled = true
        self.hideKeyboardWhenTappedAround()
        activityIndicator.frame = CGRect(x: view.center.x - 100, y: view.frame.height - bottomSafeAreaInset - 60, width: 200, height: 40)
        //place top label just above activity indicator
        topLabel.frame = CGRect(x: 20, y: view.frame.height - bottomSafeAreaInset - 110, width: self.view.frame.width - 40, height: 25)
        topLabel.text = ""
        topLabel.adjustsFontSizeToFitWidth = true
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
        switch currMode {
        case .signInEmail:
            currMode = .signInChooseMode
            break
        case .signUpEmail:
            currMode = .signUpChooseMode
            break
        case .signInChooseMode, .signUpChooseMode:
            return
        }
        setupUI()
        view.endEditing(true)
        self.emailTextField.text = ""
        self.passwordTextField.text = ""
        self.confirmPasswordTextField.text = ""
    }
    
    
    func setUpTextFields(textField: SkyFloatingLabelTextField, field: String) {
        textField.font = UIFont(name: "Avenir-book", size: 15)!
        textField.placeholderFont = UIFont(name: "Avenir-book", size: 15)!
        textField.titleFont = UIFont(name: "Avenir-heavy", size: 14)!
        textField.placeholder = field
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
        textField.delegate = self
        textField.layer.removeAllAnimations()
    }
    
    //dismiss keyboard with return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func signInButtonPressed(_ sender: Any) {
        print("Hitting the BUTTON")
        view.endEditing(true)
        switch currMode {
        case .signInEmail:
            activityIndicator.isHidden = false
            topLabel.isHidden = false
            topLabel.text = ""
            activityIndicator.startAnimating()
            signInButton.isHidden = true
            self.view.isUserInteractionEnabled = false
            signIn()
            return
        case .signUpEmail:
            activityIndicator.isHidden = false
            topLabel.isHidden = false
            topLabel.text = ""
            activityIndicator.startAnimating()
            signInButton.isHidden = true
            self.view.isUserInteractionEnabled = false
            signUp()
            return
        case .signInChooseMode:
            currMode = .signInEmail
            setupUI()
            return
        case .signUpChooseMode:
            currMode = .signUpEmail
            setupUI()
            return
        }
    }
    
    func signUp() {
        let errorCheckRes = errorsChecked()
        if !errorCheckRes.0 {
            self.view.isUserInteractionEnabled = true
            topLabel.text = errorCheckRes.1
            activityIndicator.stopAnimating()
            signInButton.isHidden = false
            return
        }
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { authResult, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.view.isUserInteractionEnabled = true
                    self.topLabel.text = error.localizedDescription
                    self.signInButton.isHidden = false
                    self.activityIndicator.stopAnimating()
                }
            } else {
                if authResult?.user != nil {
                    DispatchQueue.main.async {
                        self.determineSegueAway(signedUpWithFB: false)
                    }
                }
            }
        }
    }
    
    func signIn() {
        let errorCheckRes = errorsChecked()
        if !errorCheckRes.0 {
            topLabel.text = errorCheckRes.1
            self.activityIndicator.stopAnimating()
            self.signInButton.isHidden = false
            self.view.isUserInteractionEnabled = true
            return
        }
        FirebaseManager.shared.signIn(email: (emailTextField.text ?? ""), password: (passwordTextField.text ?? "")) { (errorString) in
            if let errorString = errorString {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.signInButton.isHidden = false
                    self.topLabel.text = errorString
                    self.view.isUserInteractionEnabled = true
                }
            } else {
                DispatchQueue.main.async {
                    self.determineSegueAway(signedUpWithFB: false)
                }
            }
        }
    }
    
    func determineSegueAway(signedUpWithFB: Bool) {
        //check if signed in user has created a user document. If they have, take them to home screen
        //If they haven't, take them to finishSignUpVC
        print("CHECKING COMPLETED SIGN UP!!!!! ")
        FirebaseManager.shared.checkIfUserHasCompletedSignUp { (err, hasCompleted) in
            self.loading?.stopAnimating()
            self.loading?.removeFromSuperview()
            self.centreLogo?.removeFromSuperview()
            if let err = err {
                self.activityIndicator.stopAnimating()
                self.topLabel.text = "An error occured. Please try again"
                self.view.isUserInteractionEnabled = true
                return
            } else {
                guard let hasCompleted = hasCompleted else {
                    self.activityIndicator.stopAnimating()
                    self.topLabel.text = "An error occured. Please try again"
                    self.view.isUserInteractionEnabled = true
                    return
                }
                if hasCompleted {
                    //has created document; go to homeScreen
                    self.view.isUserInteractionEnabled = true
                    self.segueToHomeVC()
                } else {
                    //hasn't completed sign up; go to finishSignUpVC
                    if signedUpWithFB {
                        self.preparePartialUserWithFB()
                    } else {
                        self.segueToCompleteSignUp(partialUser: nil)
                    }
                }
            }
        }
    }
    
    
    func segueToCompleteSignUp(partialUser: [String: String]?) {
        self.activityIndicator.stopAnimating()
        var userForNextVC: [String: String]!
        if let partialUser = partialUser {
            userForNextVC = partialUser
        } else {
            userForNextVC = ["full_name": "", "profile_pic_url": ""]
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "finishSignUpVC") as! finishSignUpVC
        nextVC.partialUser = userForNextVC
        nextVC.modalPresentationStyle = .fullScreen
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.moveIn
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        if let window = UIApplication.shared.delegate?.window as? UIWindow {
            window.backgroundColor = .clear
        }
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.present(nextVC, animated: false, completion: nil)
    }
    
    
    func segueToHomeVC() {
        self.activityIndicator.stopAnimating()
        if (UserDefaults.standard.bool(forKey: constants.hasViewedWalkThrough)) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let nextVC = storyboard.instantiateViewController(withIdentifier: "CenterVC") as! CenterVC
            nextVC.modalPresentationStyle = .fullScreen
            self.present(nextVC, animated: true)
            
        } else {
            let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
            if let walkthroughViewController = storyboard.instantiateViewController(withIdentifier: "WalkThroughVC") as? WalkThroughVC {
                walkthroughViewController.modalPresentationStyle = .fullScreen
                present(walkthroughViewController, animated: true, completion: nil)
            }
        }
    }
    
    
    
    func preparePartialUserWithFB() {
        let request = GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, picture.type(large)"])
        print("GETS HERE 1")
        let _ = request.start(completionHandler: { (connection, result, error) in
            self.view.isUserInteractionEnabled = true
            print("GETS HERE 2")
            guard let userInfo = result as? [String: Any] else {
                print("GETS HERE 3")
                self.segueToCompleteSignUp(partialUser: nil)
                return
            } //handle the error
            print("GETS HERE 4")
            //The url is nested 3 layers deep into the result so it's pretty messy
            
            let imageURL = ((userInfo["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String ?? ""
            let fullName = userInfo["name"] as? String ?? ""
            let partialUser = ["full_name": fullName, "profile_pic_url": imageURL]
            self.segueToCompleteSignUp(partialUser: partialUser)
            
            return
        })
    }
    
    
    
    func errorsChecked() -> (Bool,String) {
        switch currMode {
        case .signUpEmail:
            if (!self.isValidEmail(email: self.emailTextField.text ?? "")){return (false,"Please enter a valid email")}
            if (passwordTextField.text == ""){ return (false,"Please set your password")}
            if (confirmPasswordTextField.text == ""){return (false,"Please confirm your password")}
            if (passwordTextField.text  != confirmPasswordTextField.text) {return (false,"Please make sure your passwords match")}
            break
        case .signInEmail:
            if (!self.isValidEmail(email: self.emailTextField.text ?? "")){return (false,"Please enter a valid email")}
            if (passwordTextField.text == ""){ return (false,"Please enter your password")}
            break
        default:
            break
        }
        return (true,"No errors")
    }
    
    func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    
    @IBAction func switchSignInSignUpMethod(_ sender: Any) {
        topLabel.text = ""
        switch currMode {
        case .signInChooseMode:
            currMode = .signUpChooseMode
            break
        case .signUpChooseMode:
            currMode = .signInChooseMode
            break
        default:
            return
        }
        setupUI()
    }
    
    
    
    
}

//FB login
extension loginVC: LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        self.view.isUserInteractionEnabled = false
        if let error = error {
            print(error.localizedDescription)
            self.view.isUserInteractionEnabled = true
            return
        }
        guard let currAccessToken = AccessToken.current?.tokenString else {
            self.view.isUserInteractionEnabled = true
            return
        }
        
        self.activityIndicator.isHidden = false
        self.topLabel.isHidden = false
        self.activityIndicator.startAnimating()
        let credential = FacebookAuthProvider.credential(withAccessToken: currAccessToken)
        
        //Copied from Firestore site
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                //failed to login
                DispatchQueue.main.async {
                    let authError = error as NSError
                    self.view.isUserInteractionEnabled = true
                    self.topLabel.text = "Facebook login failed."
                    self.activityIndicator.stopAnimating()
                }
                return
            }
            guard let user = authResult?.user else {
                DispatchQueue.main.async {
                    self.view.isUserInteractionEnabled = true
                    self.topLabel.text = "Facebook login failed."
                    self.topLabel.text = "Facebook login failed."
                    self.activityIndicator.stopAnimating()
                }
                return
            }
//            let params = ["fields": "id, first_name, last_name, middle_name, name, email, picture"]
//            let request = GraphRequest(graphPath: "me/friends", parameters: params)
//            request.start { (connection, result, reqError) in
//                if let reqError = reqError {
//                    let errorMessage = reqError.localizedDescription
//                    print(errorMessage)
//                    return
//                    /* Handle error */
//                }
//                if let  result = result {
//                    /*  handle response */
//                    print("RESULT FROM FRIENDS")
//                    print(result)
//                }
//            }
            
            DispatchQueue.main.async {
                self.topLabel.text = ""
                self.determineSegueAway(signedUpWithFB: true)
            }
            return
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        //log user out
    }
    
    
}




