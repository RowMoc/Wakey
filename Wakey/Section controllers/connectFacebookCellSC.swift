//
//  connectFacebookCellSC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/06/27.
//  Copyright © 2020 Wakey. All rights reserved.
//
import IGListKit
import FBSDKCoreKit
import FBSDKLoginKit


class connectFacebookCellSC: ListSectionController, LoginButtonDelegate {
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 60)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(withNibName: String(describing: connectFacebookCell.self), bundle: Bundle.main, for: self, at: index)
        if let cell = cell as? connectFacebookCell {
            //FB login button
            let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 20, height: 40)
            let fbLoginButton = FBLoginButton(frame: frame, permissions: ["public_profile", "email", "user_friends"])
            fbLoginButton.layer.cornerRadius = 4
            let buttonText = NSAttributedString(string: "Add friends from Facebook", attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir-medium", size: 15) as Any])
            fbLoginButton.setAttributedTitle(buttonText, for: .normal)
            fbLoginButton.layoutIfNeeded()
            fbLoginButton.delegate = self
            cell.shadowView.addSubview(fbLoginButton)
        }
        return cell
    }
    
    
    
    
    public override func didUpdate(to object: Any) {
    }
    
    public override func didSelectItem(at index: Int) {
    }
    
    
    
    //FB login
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
            //print(error.localizedDescription)
            return
        }
        guard let currAccessToken = AccessToken.current?.tokenString else {
            return
        }
        let params = ["fields": "id, first_name, last_name, middle_name, name, email, picture"]
        let request = GraphRequest(graphPath: "me/friends", parameters: params)
        request.start { (connection, result, reqError) in
            if let reqError = reqError {
                let errorMessage = reqError.localizedDescription
                //print(errorMessage)
                return
                /* Handle error */
            }
            if let  result = result {
                /*  handle response */
                //print("RESULT FROM FRIENDS")
                //print(result)
            }
        }
        return
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        //log user out
    }
    
}
